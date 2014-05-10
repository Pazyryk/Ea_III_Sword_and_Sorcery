--
-- Rivers and RiverSegments
--
-- Copyright 2013  (c)  William Howard
--
-- Determines if a river route exists between two plots/cities
--
-- Permission granted to re-distribute this file as part of a mod
-- on the condition that this comment block is preserved in its entirety
--
-- The Civ5 river system is described on the 2kGames wiki (http://wiki.2kgames.com/civ5/index.php/River_system_overview)
-- if you don't understand that description, you stand no chance with what follows ;)
--
-- A River is one or more contiguous RiverSegments.
-- A river has a "known" headwaters and outflow (which may not be the actual headwaters/outflow if tiles have not been revealed)
-- A river flows from the headwaters to the outflow, it may have upstream branches (tributaries) and downstream branches (typically, but not necessarily, in deltas)
--
-- A RiverSegment is a single section of a River that flows between two adjacent tiles
-- A segment has both a primary tile (the one it is attached to) and an adjacent segment (which may be null if off the edge of the map)
-- A segment has a flow direction and can ascertain the next segment(s) both downstream and upstream.
-- A segment with no (known) upstream segment(s) is a headwater, one with no (known) downstream segment(s) is an outflow
--
-- A lake is treated as having a river flowing clockwise around its shoreline
--
-- Rivers and lakes are assumed to be immutable, users of IGE take note!!!
-- (use riverManager:rescanMap() after editing terrain/features/rivers to update the internal cache)
--
-- *** Sample usage
--
--   -- Get the river manager, only caring about passable terrain, not if the player can pass
--   local riverManager = RiverManager:new(isPlotPassableTerrain)
--   
--   -- Get the common rivers to the start and end plots
--   local rivers = riverManager:getCommonRivers(iStartX, iStartY, iEndX, iEndY)
--   
--   if (#rivers > 0) then
--     -- Get the route between the plots on the first river
--     local route = riverManager:getRiverRoute(rivers[1], iStartX, iStartY, iEndX, iEndY)
--     
--     if (route) then
--       -- Get the traversable plots along the bank of the shortest route from the start to the end plot
--       -- (if there are more than one rivers between the plots, this may not be on the first river)
--       local bankPlots = riverManager:getRiverBankRoute(iStartX, iStartY, iEndX, iEndY)
--     end
--   end
--
-- *** API details
--
-- Get the river manager ...
--   ... assuming all plots are passable
--   riverManager = RiverManager:new()
--   ... fnPassable(pPlot) will be called to ascertain if a plot is passable
--   riverManager = RiverManager:new(fnPassable)
--
-- Rescan the map (presumably after some terraforming event(s))
--   riverManager:rescanMap()
--
-- Get the number of distinct river systems on the map
--   iTotalRivers = riverManager:getRiversCount()
-- Get a river by id (1 to iTotalRivers)
--   river = riverManager:getRiverById(iRiver)
--
-- Get all the rivers around the given plot
--   rivers = riverManager:getRivers(iPlotX, iPlotY)
-- Get the river at the given plot that flows along the specific edge (eg DirectionTypes.DIRECTION_WEST)
--   river = riverManager:getRiver(iPlotX, iPlotY, iDirection)
--
-- Get the common rivers on the start and end plots
--   rivers = riverManager:getCommonRivers(iStartX, iStartY, iEndX, iEndY)
-- Get all river routes between the start and end plots,
--   if bAllTerminalSegments is true, all segments around the start and end plots will be included (ie longest route)
--   otherwise just the ones nearest to the other plot (ie shortest route)
--   routes = riverManager:getRiverRoutes(iStartX, iStartY, iEndX, iEndY, bAllTerminalSegments)
-- Get the river route between the start and end plots along the given river, or nil if no passable route
--   route = riverManager:getRiverRoute(iRiver, iStartX, iStartY, iEndX, iEndY, bAllTerminalSegments)
-- Get the bank plots along the shortest river route between the start and end plots
--   bankPlots = riverManager:getRiverBankRoute(iStartX, iStartY, iEndX, iEndY)
-- Get the length of the bank route from the previous call to getRiverBankRoute()
--   iBankLength = riverManager:getRiverBankLength()
--
-- Debug helper methods
-- Colour all the banks of the given the river the specified colour ("Red", "Green", "Black", "Cyan", "Yellow", "Magenta" or (default) "Blue")
--   riverManager:colourRiver(iRiver, sColour)
-- Colour the left/right banks of the given river the specified colours (default Green/Red)
--   riverManager:colourBanks(iRiver, sRightColour, sLeftColour)
--
--
-- Get the id of the river
--   iRiver = river:getRiverId()
-- Get all the bank plots of the river
--   bankPlots = river:getBankPlots()
--
--
-- Helper functions for standard "is plot passable" tests
--   isPlotPassableTerrain(pPlot) - the plot is impassable if ...
--     ... marked as impassable (eg a natural wonder)
--     ... salt-water (should never happen)
--     ... a mountain
--   isPlotPassablePlayer(pPlot, pPlayer) - the plot is impassable for the given player if ...
--     ... isPlotPassableTerrain(pPlot) return false, unless the plot is a mountain and a trait makes them passable
--     ... water (lakes) without the embark technology
--     ... not revealed to the player
--     ... occupied by a hostile unit
--     ... a hostile city (or in its ZOC)
--   isPlotPassableActivePlayer(pPlot) - same as isPlotPassablePlayer(pPlot, Players[Game.GetActivePlayer()])
--

include("FLuaVector")
-- The next line is ONLY needed when debugging outside of Civ5
--dofile "MapSupport.lua"
local Map = Map

--
-- NOTE: Functions with a leading underscore (_) should be treated as private and not called from outside this file
--

--
-- Standard "is plot passable" tests
--

function isPlotPassablePlayer(pPlot, pPlayer)
  -- A plot is impassable if it is ...
  if (pPlot:IsImpassable()) then
    -- ... marked as impassable (eg a natural wonder)
    return false
  elseif (pPlot:IsWater() and not pPlot:IsLake()) then
    -- ... salt-water (should never happen)
    return false
  elseif (pPlot:IsMountain()) then
    -- ... a mountain (unless a trait overrides this)
    if (pPlayer and pPlayer:GetGreatGeneralsCreated() > 0) then
      for row in DB.Query("SELECT t.CrossesMountainsAfterGreatGeneral FROM Civilization_Leaders cl, Leader_Traits lt, Traits t WHERE cl.CivilizationType = ? AND cl.LeaderheadType = lt.LeaderType AND lt.TraitType = t.Type", GameInfo.Civilizations[pPlayer:GetCivilizationType()].Type) do
        if (row.CrossesMountainsAfterGreatGeneral == 1) then
          return true
        end
      end
    end

    return false
  elseif (pPlot:IsLake()) then
    -- ... water without the embark technology
    if (pPlayer and not Teams[pPlayer:GetTeam()]:CanEmbark()) then
      return false
    end
  elseif (pPlayer) then
    if (not pPlot:IsRevealed(pPlayer:GetTeam())) then
      -- ... not revealed to the player
      return false
    elseif (pPlot:GetNumUnits() > 0) then
      -- ... occupied by a hostile unit
      local iPlayer = pPlayer:GetID()
      local pTeam = Teams[pPlayer:GetTeam()]

      for i = 0, pPlot:GetNumUnits()-1, 1 do
        local pUnit = pPlot:GetUnit(i)

        if (pUnit:GetOwner() ~= iPlayer and pUnit:GetDomainType() ~= DomainTypes.DOMAIN_AIR and pTeam:IsAtWar(Players[pUnit:GetOwner()]:GetTeam())) then
          return false
        end
      end
    elseif (_isHostileCity(pPlayer, pPlot) or _isAdjacentHostileCity(pPlayer, pPlot)) then
      -- ... a hostile city (or in its ZOC)
      return false
    end
  end

  return true
end

function isPlotPassableActivePlayer(pPlot)
  return isPlotPassablePlayer(pPlot, Players[Game.GetActivePlayer()])
end

function isPlotPassableTerrain(pPlot)
  return isPlotPassablePlayer(pPlot)
end

-- Helper functions for the standard isPlotPassable test functions
function _isHostileCity(pPlayer, pPlot)
  return (pPlot:GetOwner() ~= pPlayer:GetID() and pPlot:IsCity() and Teams[pPlayer:GetTeam()]:IsAtWar(Players[pPlot:GetOwner()]:GetTeam()))
end

function _isAdjacentHostileCity(pPlayer, pPlot)
  for iDirection = 0, DirectionTypes.NUM_DIRECTION_TYPES-1, 1 do
    local pOtherPlot = Map.PlotDirection(pPlot:GetX(), pPlot:GetY(), iDirection)

    if (pOtherPlot and _isHostileCity(pPlayer, pOtherPlot)) then
      return true
    end
  end

  return false
end


--
-- Helper functions for highlighting plots
--

-- Array of highlight colours
highlights = { Red     = Vector4(1.0, 0.0, 0.0, 1.0),
               Green   = Vector4(0.0, 1.0, 0.0, 1.0),
               Blue    = Vector4(0.0, 0.0, 1.0, 1.0),
               Cyan    = Vector4(0.0, 1.0, 1.0, 1.0),
               Yellow  = Vector4(1.0, 1.0, 0.0 ,1.0),
               Magenta = Vector4(1.0, 0.0, 1.0, 1.0),
               Black   = Vector4(0.5, 0.5, 0.5, 1.0)}

function clearPlots()
  Events.ClearHexHighlights()
end

function colourPlots(pPlots, sColour)
  for _, pPlot in pairs(pPlots) do
    colourPlot(pPlot, sColour)
  end
end

function colourPlot(pPlot, sColour)
  if (pPlot) then
    Events.SerialEventHexHighlight(ToHexFromGrid({x=pPlot:GetX(), y=pPlot:GetY()}), true, highlights[sColour or "Blue"] or highlights.Blue)
  end
end


--
-- Helper functions to fix a bug with IsRiverCrossing and include lakes within the flow of rivers
-- Treat a lake as having a clockwise flowing river around the shore line
--

function HasRiverOnSide(pPlot, iDirection)
  if (iDirection == DirectionTypes.DIRECTION_EAST) then
    return pPlot:IsWOfRiver()
  elseif (iDirection == DirectionTypes.DIRECTION_SOUTHEAST) then
    return pPlot:IsNWOfRiver()
  elseif (iDirection == DirectionTypes.DIRECTION_SOUTHWEST) then
    return pPlot:IsNEOfRiver()
  else
    local pAdjacentPlot = Map.PlotDirection(pPlot:GetX(), pPlot:GetY(), iDirection)

    if (pAdjacentPlot) then
      if (iDirection == DirectionTypes.DIRECTION_WEST) then
        return pAdjacentPlot:IsWOfRiver()
      elseif (iDirection == DirectionTypes.DIRECTION_NORTHWEST) then
        return pAdjacentPlot:IsNWOfRiver()
      elseif (iDirection == DirectionTypes.DIRECTION_NORTHEAST) then
        return pAdjacentPlot:IsNEOfRiver()
      end
    end
  end

  return false
end

function _isRiverCrossing(pPlot, iDirection)
  if (HasRiverOnSide(pPlot, iDirection)) then
    -- A normal "land-river-land" crossing
    return true
  else
    -- Is this a "land-shore-lake" type crossing?
    local pAdjacentPlot = Map.PlotDirection(pPlot:GetX(), pPlot:GetY(), iDirection)
    if (pAdjacentPlot and pPlot:IsLake() ~= pAdjacentPlot:IsLake()) then
      return true
    end
  end
end

function _isRiverCrossingFlowClockwise(pPlot, iDirection)
  -- Is this "land-river-land" or "land-shore-lake"
  if (HasRiverOnSide(pPlot, iDirection)) then
    -- "land-river-land" can be handled by the API call as IsRiverCrossingFlowClockwise() doesn't use IsRiverCrossing() so isn't bugged
    return pPlot:IsRiverCrossingFlowClockwise(iDirection)
  end

  -- "land-shore-lake" is always "clockwise around the lake" but we need to bear in mind that segments only have E, SE and SW sides
  if (pPlot:IsLake()) then
    return (iDirection == DirectionTypes.DIRECTION_EAST or iDirection == DirectionTypes.DIRECTION_SOUTHEAST or iDirection == DirectionTypes.DIRECTION_SOUTHWEST)
  else
    return (iDirection == DirectionTypes.DIRECTION_WEST or iDirection == DirectionTypes.DIRECTION_NORTHWEST or iDirection == DirectionTypes.DIRECTION_NORTHEAST)
  end
end


--
-- Below here is only for the brave (or fool-hardy)!
-- Pseudo-classes, factories and recursive routines abound!
--

--
-- RiverManager and River classes
--

RiverManager = {
  new = function(self, passable)
    local me = {}
    setmetatable(me, self)
    self.__index = self

    me.segmentManager = RiverSegmentManager:new(passable)

    me.lastBankLength = 0

    me:rescanMap()

    return me
  end,

  rescanMap = function(self)
    self.rivers = nil
  end,

  _rescanMap = function(self)
    local startTime = os.clock()
    local iRiver = 1

    self.rivers = {}
    self.segmentManager:_clear()

    for iPlotLoop = 0, Map.GetNumPlots()-1, 1 do
      local pPlot = Map.GetPlotByIndex(iPlotLoop)

      for iDirection = 0, DirectionTypes.NUM_DIRECTION_TYPES-1, 1 do
        if (_isRiverCrossing(pPlot, iDirection)) then
          local segment = self.segmentManager:getRiverSegment(pPlot:GetX(), pPlot:GetY(), iDirection, iRiver)

          if (segment and segment:getRiverId() == iRiver) then
            self.rivers[iRiver] = River:new(iRiver, self.segmentManager)
            iRiver = iRiver + 1
          end
        end
      end
    end

    print(string.format("Map scan took %.4f seconds for %i plots finding %i rivers with a total of %i segments", (os.clock() - startTime), Map.GetNumPlots(), self:getRiversCount(), self:getRiverSegmentsCount()))
  end,

  _getRivers = function(self)
    if (self.rivers == nil) then
      self:_rescanMap()
    end

    return self.rivers
  end,

  _getSegmentManager = function(self)
    self:_getRivers()

    return self.segmentManager
  end,

  getRiversCount = function(self)
    return #self:_getRivers()
  end,

  getRiverSegmentsCount = function(self)
    return self:_getSegmentManager():getRiverSegmentsCount()
  end,

  -- Get all the rivers that pass around this plot
  getRivers = function(self, iPlotX, iPlotY)
    local plotRivers = {}
    local temp = {}

    local rivers = self:_getRivers()

    for _,segment in pairs(self:_getSegmentManager():getRiverSegments(iPlotX, iPlotY)) do
      temp[segment:getRiverId()] = rivers[segment:getRiverId()]
    end

    for _,river in pairs(temp) do
      table.insert(plotRivers, river)
    end

    return plotRivers
  end,

  -- Get the river that passes this plot in the given direction
  getRiver = function(self, iPlotX, iPlotY, iDirection)
    local segment = self:_getSegmentManager():getRiverSegment(iPlotX, iPlotY, iDirection)

    if (segment) then
      return self:_getRivers()[segment:getRiverId()]
    end

    return nil
  end,

  getRiverById = function(self, iRiver)
    return self:_getRivers()[iRiver]
  end,

  colourRiver = function(self, iRiver, sColour)
    self:getRiverById(iRiver):colourRiver(sColour)
  end,

  colourBanks = function(self, iRiver, sRightColour, sLeftColour)
    self:getRiverById(iRiver):colourBanks(sRightColour, sLeftColour)
  end,
  
  getCommonRivers = function(self, iStartX, iStartY, iEndX, iEndY)
    local startRivers = self:getRivers(iStartX, iStartY)
    local endRivers = self:getRivers(iEndX, iEndY)

    local rivers = {}

    for _, startRiver in ipairs(startRivers) do
      for _, endRiver in ipairs(endRivers) do
        if (startRiver:getRiverId() == endRiver:getRiverId()) then
          rivers[startRiver:getRiverId()] = startRiver:getRiverId()
        end
      end
    end

    return rivers
  end,

  getRiverRoutes = function(self, iStartX, iStartY, iEndX, iEndY, bAllTerminalSegments)
    local routes = {}

    for _, iRiver in pairs(self:getCommonRivers(iStartX, iStartY, iEndX, iEndY)) do
      table.insert(routes, self:getRiverRoute(iRiver, iStartX, iStartY, iEndX, iEndY, bAllTerminalSegments))
    end

    return routes
  end,

  getRiverRoute = function(self, iRiver, iStartX, iStartY, iEndX, iEndY, bAllTerminalSegments)
    local route = {}
    local startSegments = {}
    local endSegments = {}

    for _, segment in pairs(self:_getSegmentManager():getRiverSegments(iStartX, iStartY)) do
      if (segment:getRiverId() == iRiver) then
        table.insert(startSegments, segment)
      end
    end
    for _, segment in pairs(self:_getSegmentManager():getRiverSegments(iEndX, iEndY)) do
      if (segment:getRiverId() == iRiver) then
        table.insert(endSegments, segment)
      end
    end

    -- We can start on any segment of iRiver that borders (iStartX, iStartY), so choose the first
    local startSegment = startSegments[1]

    -- print("Looking UPSTREAM from ", startSegment:toString())
    local upstreamRoute = self:_getPartialRoute(startSegment, endSegments, true, false, route)
    if (upstreamRoute ~= nil) then
      route = upstreamRoute
    else
      -- print("Looking DOWNSTREAM from ", startSegment:toString())
      local downstreamRoute = self:_getPartialRoute(startSegment, endSegments, false, false, route)
      if (downstreamRoute ~= nil) then
        route = downstreamRoute
      end
    end

    if (#route > 0) then
      if (bAllTerminalSegments) then
        -- Add all unused start and end segments onto the route
        route = self:_concatRoute(self:_filterRoute(startSegments, route), route)
        route = self:_concatRoute(route, self:_filterRoute(endSegments, route))
      else
        -- Trim the route to just a single start/end segment that contains the start/end plot
        while (#route > 2 and route[2]:_containsPlot(iStartX, iStartY)) do
          table.remove(route, 1)
        end

        while (#route > 2 and route[#route-1]:_containsPlot(iEndX, iEndY)) do
          table.remove(route)
        end
      end
    else
      route = nil
    end

    return route
  end,

  getRiverBankLength = function(self)
    return self.lastBankLength
  end,

  getRiverBankRoute = function(self, iStartX, iStartY, iEndX, iEndY)
    local plots = {}
    local routes = self:getRiverRoutes(iStartX, iStartY, iEndX, iEndY, false)

    -- find the shortest route
    for _, route in ipairs(routes) do
      local temp = self:_getBankRoute(route, iStartX, iStartY, iEndX, iEndY)

      if (#plots == 0 or #temp < #plots) then
        plots = temp
      end
    end

    self.lastBankLength = #plots
    return plots
  end,

  -- Find a route along the river banks from the start plot to the end plot
  -- Favour staying on the same bank, only switching side if necessary (and not to find the shortest route)
  _getBankRoute = function(self, route, iStartX, iStartY, iEndX, iEndY)
    local plots = {}
    local bRightBank = true

    local segmentManager = self:_getSegmentManager()
    local segment = route[1]

    local pStartPlot = segment:getBankPlot(bRightBank)
    if (not (pStartPlot:GetX() == iStartX and pStartPlot:GetY() == iStartY)) then
      -- OK, so it's on the left bank!
      bRightBank = false
      pStartPlot = segment:getBankPlot(bRightBank)
    end

    table.insert(plots, pStartPlot)

    for i = 2, #route, 1 do
      segment = route[i]

      if (route[i-1]:getTraversal() ~= segment:getTraversal()) then
        -- Switch from downstream to upstream, so we need to switch bank
        bRightBank = not bRightBank
      end

      local pNextPlot = segment:getBankPlot(bRightBank)

      -- If this bank is impassable, switch sides
      if (not segmentManager:isPlotPassable(pNextPlot)) then
        bRightBank = not bRightBank
        pNextPlot = segment:getBankPlot(bRightBank)
      end

      if (not(pNextPlot:GetX() == pStartPlot:GetX() and pNextPlot:GetY() == pStartPlot:GetY())) then
        table.insert(plots, pNextPlot)
        pStartPlot = pNextPlot
      end
    end

    if (not(pStartPlot:GetX() == iEndX and pStartPlot:GetY() == iEndY)) then
      table.insert(plots, Map.GetPlot(iEndX, iEndY))
    end

    return self:_deloopPlots(plots)
  end,

  _getPartialRoute = function(self, startSegment, endSegments, bUpStream, bTrimStem, routeToDate)
    -- print(string.format("_getPartialRoute: %s, %i, %s, %s, %i", startSegment:toString(), #endSegments, (bUpStream and "up" or "down"), (bTrimStem and "trim" or "no trim"), #routeToDate))
    local partialRoute = {}

    while (startSegment:isPassable()) do
      for _, endSegment in pairs(endSegments) do
        if (startSegment:getIndex() == endSegment:getIndex()) then
          -- We've reached the destination
          return self:_concatRoute(routeToDate, partialRoute, bTrimStem, endSegment:setTraversal(bUpStream))
        end
      end

      local upstreamSegments = self:_filterRoute(startSegment:getUpstreamSegments(), routeToDate, partialRoute)
      local downstreamSegments = self:_filterRoute(startSegment:getDownstreamSegments(), routeToDate, partialRoute)
      if (bUpStream) then
        -- print(string.format("  at %s going upstream, %i upstream routes, no downstream routes", startSegment:toString(), #upstreamSegments))
      else
        -- print(string.format("  at %s going downstream, %i downstream routes, %i upstream routes", startSegment:toString(), #downstreamSegments, #upstreamSegments))
      end

      if ((#upstreamSegments + #downstreamSegments) == 0) then
        -- Nowhere to go
        return nil
      elseif ((#upstreamSegments + #downstreamSegments) == 1) then
        -- Only one (unexplored) segment, so follow it
        table.insert(partialRoute, startSegment:setTraversal(bUpStream))
        startSegment = upstreamSegments[1] or downstreamSegments[1]
        bUpStream = (#upstreamSegments == 1)
      else
        -- We've come to a fork, time to recurse!
        local routeSoFar = self:_concatRoute(routeToDate, partialRoute, bTrimStem, startSegment:setTraversal(bUpStream))

        -- We could get creative and merge the two halves of this if statement, but that would make it harder for a human to read and follow
        if (bUpStream) then
          -- Upstream

          -- Try upstream first, there will always be at least one branch
          local branchRoute = self:_getPartialRoute(upstreamSegments[1], endSegments, bUpStream, false, routeSoFar)
          if (branchRoute ~= nil) then
            -- Yes, so return the route
            return branchRoute
          else
            -- No, so is it along any other upstream branch
            branchRoute = upstreamSegments[2] and self:_getPartialRoute(upstreamSegments[2], endSegments, bUpStream, false, routeSoFar)
            if (branchRoute ~= nil) then
              return branchRoute
            else
              -- No, so did it try to sneak in behind us (there can only be one downstream branch joining in as we must have come up the other one!)
              branchRoute = downstreamSegments[1] and self:_getPartialRoute(downstreamSegments[1], endSegments, false, true, routeSoFar)
              if (branchRoute ~= nil) then
                return branchRoute
              else
                return nil
              end
            end
          end
        else
          -- Downstream

          -- Try downstream first, there will always be at least one branch
          local branchRoute = self:_getPartialRoute(downstreamSegments[1], endSegments, bUpStream, false, routeSoFar)
          if (branchRoute ~= nil) then
            -- Yes, so return the route
            return branchRoute
          else
            -- No, so is it along any other downstream branch
            branchRoute = downstreamSegments[2] and self:_getPartialRoute(downstreamSegments[2], endSegments, bUpStream, false, routeSoFar)
            if (branchRoute ~= nil) then
              return branchRoute
            else
              -- No, so did it try to sneak in behind us (there can only be one upstream branch joining in as we must have come down the other one!)
              branchRoute = upstreamSegments[1] and self:_getPartialRoute(upstreamSegments[1], endSegments, true, true, routeSoFar)
              if (branchRoute ~= nil) then
                return branchRoute
              else
                return nil
              end
            end
          end
        end
      end
    end

    return nil
  end,


  _concatRoute = function(self, route1, route2, bTrimStem, segment)
    local route = {}

    local iLastSegment = #route1

    if (bTrimStem and iLastSegment > 1 and #route2 > 0) then
      -- Basically we've come into a Y down one of the arms and traversed into the stem (this is route1), found no onward route
      -- and then backed up the other arm (this is route2), so we could have gone straight from one arm to the other,
      -- that is, we don't need the last plot in route1
      iLastSegment = iLastSegment - 1
    end

    if (route1) then
      for i = 1, iLastSegment, 1 do
        table.insert(route, route1[i])
      end
    end

    if (route2) then
      for i = 1, #route2, 1 do
        table.insert(route, route2[i])
      end
    end

    if (segment) then
      table.insert(route, segment)
    end

    return route
  end,

  _filterRoute = function(self, newRoute, oldRoute, partialRoute)
    local route = {}

    for _, newSegment in ipairs(newRoute) do
      local newIndex = newSegment:getIndex()
      local bInclude = true

      -- These loops are done backwards as an optimisation, as it's far more likely
      -- that the route just passed through the last segment than the first!
      if (partialRoute) then
        for i = #partialRoute, 1, -1 do
          if (newIndex == partialRoute[i]:getIndex()) then
            bInclude = false
            break
          end
        end
      end

      if (bInclude) then
        for i = #oldRoute, 1, -1 do
          if (newIndex == oldRoute[i]:getIndex()) then
            bInclude = false
            break
          end
        end
      end

      if (bInclude) then
        table.insert(route, newSegment)
      end
    end

    return route
  end,

  _deloopPlots = function(self, pPlots)
    local first = 1

    -- Can we short-cut across the lakes?
    while (first < #pPlots) do
      local pPlot = pPlots[first]

      if (pPlot:IsLake()) then
        local last = #pPlots
        while (last > first) do
          if (pPlot:GetX() == pPlots[last]:GetX() and pPlot:GetY() == pPlots[last]:GetY()) then
            for p = last, first+1, -1 do
              table.remove(pPlots, p)
            end

            last = first
          else
            last = last - 1
          end
        end
      end

      first = first + 1
    end

    -- There is also the case of "land-lake-land" where the two land plots abut, the lake plot can be removed
    first = 2
    while (first < #pPlots-1) do
      local pPlot = pPlots[first]

      if (pPlot:IsLake()) then
        local pPrevPlot = pPlots[first-1]
        local pNextPlot = pPlots[first+1]

        if (not pPrevPlot:IsLake() and not pNextPlot:IsLake()) then
          if (Map.PlotDistance(pPrevPlot:GetX(), pPrevPlot:GetY(), pNextPlot:GetX(), pNextPlot:GetY()) == 1) then
            table.remove(pPlots, first)
            -- No need to decrement first (to allow for the removed plot) as we know it points to land which we're not interested in
          end
        end
      end

      first = first + 1
    end


    return pPlots
  end,
}

River = {
  new = function(self, iRiver, segmentManager)
    local me = {}
    setmetatable(me, self)
    self.__index = self

    me.iRiver = iRiver
    me.segmentManager = segmentManager

    return me
  end,

  getRiverId = function(self)
    return self.iRiver
  end,

  colourRiver = function(self, sColour)
    for _, pPlot in pairs(self:getBankPlots()) do
      colourPlot(pPlot, sColour or "Yellow")
    end
  end,

  colourBanks = function(self, sRightColour, sLeftColour)
    for _, segment in pairs(self.segmentManager:getAllSegments()) do
      if (segment:getRiverId() == self.iRiver) then
        segment:colourBanks(sRightColour, sLeftColour)
      end
    end
  end,

  getBankPlots = function(self)
    local temp = {}

    for _, segment in pairs(self.segmentManager:getAllSegments()) do
      if (segment:getRiverId() == self.iRiver and not segment:isLakeSegment()) then
        for _, pPlot in ipairs(segment:getBankPlots()) do
          temp[pPlot:GetPlotIndex()] = pPlot
        end
      end
    end

    local plots = {}
    for _, plot in pairs(temp) do
      table.insert(plots, plot)
    end

    return plots
  end,
}


--
-- RiverSegmentManager and RiverSegment classes
--

RiverSegmentManager = {
  new = function(self, passable)
    local me = {}
    setmetatable(me, self)
    self.__index = self

    me.passable = passable

    me:_clear()

    return me
  end,

  _clear = function(self)
    self.segments = {}
  end,

  getAllSegments = function(self)
    return self.segments
  end,

  getRiverSegmentsCount = function(self)
    local count = 0;

    for _, _ in pairs(self:getAllSegments()) do
      count = count + 1
    end

    return count
  end,

  -- Get all the segments (if any) around this plot
  getRiverSegments = function(self, iPlotX, iPlotY)
    local riverSegments = {}

    for iDirection = 0, DirectionTypes.NUM_DIRECTION_TYPES-1, 1 do
      local riverSegment = self:getRiverSegment(iPlotX, iPlotY, iDirection)
      if (riverSegment) then
        table.insert(riverSegments, riverSegment)
      end
    end

    return riverSegments
  end,

  -- Get the river segment (if any) on the specified edge of this plot
  getRiverSegment = function(self, iPlotX, iPlotY, iDirection, iRiver)
    local pPlot = Map.GetPlot(iPlotX, iPlotY)

    if (pPlot) then
      -- Is the requested segment located on the adjacent plot?
      if (iDirection == DirectionTypes.DIRECTION_WEST) then
        pPlot = Map.PlotDirection(iPlotX, iPlotY, iDirection)
        iDirection = DirectionTypes.DIRECTION_EAST
      elseif (iDirection == DirectionTypes.DIRECTION_NORTHWEST) then
        pPlot = Map.PlotDirection(iPlotX, iPlotY, iDirection)
        iDirection = DirectionTypes.DIRECTION_SOUTHEAST
      elseif (iDirection == DirectionTypes.DIRECTION_NORTHEAST) then
        pPlot = Map.PlotDirection(iPlotX, iPlotY, iDirection)
        iDirection = DirectionTypes.DIRECTION_SOUTHWEST
      end

      if (pPlot and _isRiverCrossing(pPlot, iDirection)) then
        local iSegmentIndex = RiverSegment:getIndex(pPlot, iDirection)

        if (self.segments[iSegmentIndex] == nil and iRiver ~= nil) then
          local segment = RiverSegment:new(pPlot:GetX(), pPlot:GetY(), iDirection, iRiver, self)
          self.segments[iSegmentIndex] = segment

          -- By caching these values we also force the entire river to be processed
          -- WARNING: Only call these methods AFTER the segment is in the manager's cache!!!
          segment:cacheUpstreamSegments()
          segment:cacheDownstreamSegments()
        end

        return self.segments[iSegmentIndex]
      end
    end

    return nil
  end,

  isSegmentPassable = function(self, segment)
    for _, pBankPlot in ipairs(segment:getBankPlots()) do
      if (self:isPlotPassable(pBankPlot)) then
        return true
      end
    end

    return false
  end,

  isPlotPassable = function(self, pPlot)
    if (self.passable) then
      return self.passable(pPlot)
    end

    return true
  end,
}

RiverSegment = {
  new = function(self, iPlotX, iPlotY, iDirection, iRiver, segmentManager)
    local me = {}
    setmetatable(me, self)
    self.__index = self

    me.iRiver = iRiver
    me.segmentManager = segmentManager

    me.iPrimaryX = iPlotX
    me.iPrimaryY = iPlotY
    me.iSide = iDirection

    local pPlot = Map.GetPlot(iPlotX, iPlotY)
    me.bClockwise = _isRiverCrossingFlowClockwise(pPlot, iDirection)
    me.iIndex = RiverSegment:getIndex(pPlot, iDirection)

    local pAdjacentPlot = Map.PlotDirection(iPlotX, iPlotY, iDirection)

    if (pAdjacentPlot) then
      me.iAdjacentX = pAdjacentPlot:GetX()
      me.iAdjacentY = pAdjacentPlot:GetY()
    else
      me.iAdjacentX = -1
      me.iAdjacentY = -1
    end

    return me
  end,

  toString = function(self)
    return string.format("RiverSegment: (%i, %i), side=%i, flow=%sclockwise", self.iPrimaryX, self.iPrimaryY, self.iSide, (self:isClockwise() and "" or "anti-"))
  end,

  getIndex = function(self, pPlot, iDirection)
    if (pPlot) then
      return pPlot:GetPlotIndex() * 10 + iDirection
    else
      return self.iIndex
    end
  end,

  getRiverId = function(self)
    return self.iRiver
  end,

  colourBanks = function(self, sRightColour, sLeftColour)
    colourPlot(self:getBankPlot(true), sRightColour or "Red")
    colourPlot(self:getBankPlot(false), sLeftColour or "Green")
  end,

  isClockwise = function(self)
    return self.bClockwise
  end,

  isLakeSegment = function(self)
    return not HasRiverOnSide(Map.GetPlot(self.iPrimaryX, self.iPrimaryY), self.iSide)
  end,

  getBankPlots = function(self)
    local plots = {Map.GetPlot(self.iPrimaryX, self.iPrimaryY)}

    local plot = Map.GetPlot(self.iAdjacentX, self.iAdjacentY)
    if (plot) then
      table.insert(plots, plot)
    end

    return plots
  end,

  getBankPlot = function(self, bRight)
    if (self.bClockwise == bRight) then
      return Map.GetPlot(self.iPrimaryX, self.iPrimaryY)
    else
      return Map.GetPlot(self.iAdjacentX, self.iAdjacentY)
    end
  end,

  isHeadWaters = function(self)
    return (self.up1 == nil and self.up2 == nil)
  end,

  isOutflow = function(self)
    return (self.down1 == nil and self.down2 == nil)
  end,

  getDistanceFromHeadwaters = function (self)
    local iDistance = 0
    local up = self:getUpstreamSegments()

    while (true) do
      if (#up == 0) then
        return iDistance
      elseif (#up == 2) then
        return math.max(self.up1:getDistanceFromHeadwaters(), self.up2:getDistanceFromHeadwaters()) + iDistance
      else
        iDistance = iDistance + 1
        up = up[1]:getUpstreamSegments()
      end
    end
  end,

  getDistanceFromOutflow = function (self)
    local iDistance = 0
    local down = self:getDownstreamSegments()

    while (true) do
      if (#down == 0) then
        return iDistance
      elseif (#down == 2) then
        return math.min(self.up1:getDistanceFromOutflow(), self.up2:getDistanceFromOutflow()) + iDistance
      else
        iDistance = iDistance + 1
        down = down[1]:getDownstreamSegments()
      end
    end
  end,

  getTraversal = function(self)
    return self.traversal
  end,

  setTraversal = function(self, bUpstream)
    -- In my usual multi-threaded server environment storing state data on an object would be a really bad idea, but here ...
    self.traversal = bUpstream

    return self
  end,

  isPassable = function(self)
    return self.segmentManager:isSegmentPassable(self)
  end,

  cacheUpstreamSegments = function(self)
    self.up1, self.up2 = self:_getUpstreamSegments()
  end,

  cacheDownstreamSegments = function(self)
    self.down1, self.down2 = self:_getDownstreamSegments()
  end,

  getUpstreamSegments = function(self)
    local segments = {}

    if (self.up1) then table.insert(segments, self.up1) end
    if (self.up2) then table.insert(segments, self.up2) end

    return segments
  end,

  getDownstreamSegments = function(self)
    local segments = {}

    if (self.down1) then table.insert(segments, self.down1) end
    if (self.down2) then table.insert(segments, self.down2) end

    return segments
  end,

  -- Private methods
  _getSegment = function(self, iPlotX, iPlotY, iDirection, bRequiredFlow)
    local segment = self.segmentManager:getRiverSegment(iPlotX, iPlotY, iDirection, self.iRiver)

    if (segment and segment:isClockwise() == bRequiredFlow) then
        return segment
    end

    return nil
  end,

  _getUpstreamSegments = function(self)
    local iPrimaryDirection, iPrimaryFlow = DirectionTypes.NO_DIRECTION, true
    local iAdjacentDirection, iAdjacentFlow = DirectionTypes.NO_DIRECTION, true

    if (self.iSide == DirectionTypes.DIRECTION_EAST and self.bClockwise) then
      iPrimaryDirection, iPrimaryFlow = DirectionTypes.DIRECTION_NORTHEAST, false
      iAdjacentDirection, iAdjacentFlow = DirectionTypes.DIRECTION_NORTHWEST, true
    elseif (self.iSide == DirectionTypes.DIRECTION_EAST and not self.bClockwise) then
      iPrimaryDirection, iPrimaryFlow = DirectionTypes.DIRECTION_SOUTHEAST, false
      iAdjacentDirection, iAdjacentFlow = DirectionTypes.DIRECTION_SOUTHWEST, true
    elseif (self.iSide == DirectionTypes.DIRECTION_SOUTHEAST and self.bClockwise) then
      iPrimaryDirection, iPrimaryFlow = DirectionTypes.DIRECTION_EAST, true
      iAdjacentDirection, iAdjacentFlow = DirectionTypes.DIRECTION_NORTHEAST, true
    elseif (self.iSide == DirectionTypes.DIRECTION_SOUTHEAST and not self.bClockwise) then
      iPrimaryDirection, iPrimaryFlow = DirectionTypes.DIRECTION_SOUTHWEST, false
      iAdjacentDirection, iAdjacentFlow = DirectionTypes.DIRECTION_WEST, false
    elseif (self.iSide == DirectionTypes.DIRECTION_SOUTHWEST and self.bClockwise) then
      iPrimaryDirection, iPrimaryFlow = DirectionTypes.DIRECTION_SOUTHEAST, true
      iAdjacentDirection, iAdjacentFlow = DirectionTypes.DIRECTION_EAST, false
    elseif (self.iSide == DirectionTypes.DIRECTION_SOUTHWEST and not self.bClockwise) then
      iPrimaryDirection, iPrimaryFlow = DirectionTypes.DIRECTION_WEST, true
      iAdjacentDirection, iAdjacentFlow = DirectionTypes.DIRECTION_NORTHWEST, false
    end

    return self:_getSegment(self.iPrimaryX, self.iPrimaryY, iPrimaryDirection, iPrimaryFlow), self:_getSegment(self.iAdjacentX, self.iAdjacentY, iAdjacentDirection, iAdjacentFlow)
  end,

  _getDownstreamSegments = function(self)
    local iPrimaryDirection, iPrimaryFlow = DirectionTypes.NO_DIRECTION, true
    local iAdjacentDirection, iAdjacentFlow = DirectionTypes.NO_DIRECTION, true

    if (self.iSide == DirectionTypes.DIRECTION_EAST and self.bClockwise) then
      iPrimaryDirection, iPrimaryFlow = DirectionTypes.DIRECTION_SOUTHEAST, true
      iAdjacentDirection, iAdjacentFlow = DirectionTypes.DIRECTION_SOUTHWEST, false
    elseif (self.iSide == DirectionTypes.DIRECTION_EAST and not self.bClockwise) then
      iPrimaryDirection, iPrimaryFlow = DirectionTypes.DIRECTION_NORTHEAST, true
      iAdjacentDirection, iAdjacentFlow = DirectionTypes.DIRECTION_NORTHWEST, false
    elseif (self.iSide == DirectionTypes.DIRECTION_SOUTHEAST and self.bClockwise) then
      iPrimaryDirection, iPrimaryFlow = DirectionTypes.DIRECTION_SOUTHWEST, true
      iAdjacentDirection, iAdjacentFlow = DirectionTypes.DIRECTION_WEST, true
    elseif (self.iSide == DirectionTypes.DIRECTION_SOUTHEAST and not self.bClockwise) then
      iPrimaryDirection, iPrimaryFlow = DirectionTypes.DIRECTION_EAST, false
      iAdjacentDirection, iAdjacentFlow = DirectionTypes.DIRECTION_NORTHEAST, false
    elseif (self.iSide == DirectionTypes.DIRECTION_SOUTHWEST and self.bClockwise) then
      iPrimaryDirection, iPrimaryFlow = DirectionTypes.DIRECTION_WEST, false
      iAdjacentDirection, iAdjacentFlow = DirectionTypes.DIRECTION_NORTHWEST, true
    elseif (self.iSide == DirectionTypes.DIRECTION_SOUTHWEST and not self.bClockwise) then
      iPrimaryDirection, iPrimaryFlow = DirectionTypes.DIRECTION_SOUTHEAST, false
      iAdjacentDirection, iAdjacentFlow = DirectionTypes.DIRECTION_EAST, true
    end

    return self:_getSegment(self.iPrimaryX, self.iPrimaryY, iPrimaryDirection, iPrimaryFlow), self:_getSegment(self.iAdjacentX, self.iAdjacentY, iAdjacentDirection, iAdjacentFlow)
  end,

  _containsPlot = function(self, iPlotX, iPlotY)
    return (self.iPrimaryX == iPlotX and self.iPrimaryY == iPlotY) or (self.iAdjacentX == iPlotX and self.iAdjacentY == iPlotY)
  end,
}
