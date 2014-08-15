-- EaMathUtils
-- Author: Pazyryk
-- DateCreated: 12/11/2012 9:07:12 PM
--------------------------------------------------------------
local PlotDistance = Map.PlotDistance

function GetDistanceMatrix(pts, pts2)
	print("Running GetDistanceMatrix")
	--Returns distance matrix; if pts2 == nil then returns a symmetric matrix with zero diagonal
	--Any tables can be supplied as long as their elements have .x, .y

	local pts2 = pts2 or pts
	local dMatrix = {}
	for k, v in pairs(pts) do
		dMatrix[k] = {}
		for k2, v2 in pairs(pts2) do
			dMatrix[k][k2] = PlotDistance(v.x, v.y, v2.x, v2.y)
		end
	end
	return dMatrix

	--[[	generalized above to work for any non-array tables
	if pts2 then	--asymmetric matrix
		for i = 1, #pts do
			dMatrix[i] = {}
			for j = 1, #pts2 do
				dMatrix[i][j] = PlotDistance(pts[i].x, pts[i].y, pts2[j].x, pts2[j].y)
			end
		end
	else			--symmetric matrix
		local size = #pts
		for i = 1, size do
			dMatrix[i] = {}
			for j = 1, size do
				if i == j then
					dMatrix[i][j] = 0	
				elseif dMatrix[j] and dMatrix[j][i] then
					dMatrix[i][j] = dMatrix[j][i]
				else
					dMatrix[i][j] = PlotDistance(pts[i].x, pts[i].y, pts[j].x, pts[j].y)
				end
			end
		end
	end
	return dMatrix
	]]
end

--------------------------------------------------------------
-- DBSCAN Clustering
--------------------------------------------------------------
-- This is a clustering algorithm to identify clusters of units for AI
-- Use:
-- eps = 4		--min distance bewteen
-- minPts = 4		--min number in cluster

local neighbors = {}
local neighborsPos = 0
local ptVisited = {}

function DBSCAN_Cluster(pts, eps, minPts)  --unitPositions, unitUnitDistMatrix, 4, 4
	print("Running DBSCAN_Cluster ", pts, eps, minPts)
	local size = #pts
	for i = 1, size do
		ptVisited[i] = false
	end
	local ptsDistMatrix = GetDistanceMatrix(pts, nil)
	local clusters = {}
	local c = 0
	for i = 1, size do
		if not ptVisited[i] then
			ptVisited[i] = true
			neighborsPos = 0
			local ptsAdded = RegionQuery(ptsDistMatrix, i, eps)
			local pt = pts[i]
			if ptsAdded >= minPts or pt.boss then	--boss counts as cluster by itself
				c = c + 1
				pt.cluster = c
				local cluster = {i}	--point i is first point in cluster
				clusters[c] = cluster
				print("DBSCAN made new cluster ", c, ptsAdded)
				ExpandCluster(pts, ptsDistMatrix, c, cluster, eps, minPts)
			end
		end
	end

	--done clustering; now find central pt for each cluster
	for i = 1, c do
		--print("Finding central point in cluster #", i)
		local cluster = clusters[i]
		--find pt with min distance to farthest other member
		local size = #cluster
		local minDistToFarthest = 1000
		local centerPt = 1
		for j = 1, size do
			local jPt = cluster[j]
			local farthestPt = 0
			for k = 1, size do
				local kPt = cluster[k]
				local distance = ptsDistMatrix[jPt][kPt]
				if farthestPt < distance then
					farthestPt = distance
				end
			end
			if farthestPt < minDistToFarthest then
				minDistToFarthest = farthestPt
				centerPt = jPt
			end
		end
		local pt = pts[centerPt]
		cluster.x, cluster.y = pt.x, pt.y

		print("Cluster info: ", size, minDistToFarthest, cluster.x, cluster.y)

	end
	return clusters
end

function ExpandCluster(pts, ptsDistMatrix, c, cluster, eps, minPts)
	print("DBSCAN ExpandCluster", neighborsPos)
	local j = 0
	local clusterIndex = #cluster
	while j < neighborsPos do
		j = j + 1
		local ptPrimeIndex = neighbors[j]
		local ptPrime = pts[ptPrimeIndex]
		if not ptVisited[ptPrimeIndex] then
			ptVisited[ptPrimeIndex] = true
			local ptsAdded = RegionQuery(ptsDistMatrix, ptPrimeIndex, eps)
			if ptsAdded < minPts and not ptPrime.boss then
				print("DBSCAN did not expand cluster ", ptsAdded)
				neighborsPos = neighborsPos - ptsAdded	--effectively drops new points from end
			else
				print("DBSCAN expanding cluster ", ptsAdded)
			end
		end
		if ptPrime.cluster == 0 then	--0 means not in cluster
			print("DBSCAN adding ptPrime to cluster ", ptPrimeIndex)
			ptPrime.cluster = c
			clusterIndex = clusterIndex + 1
			cluster[clusterIndex] = ptPrimeIndex
		end
	end
end

function RegionQuery(ptsDistMatrix, ptIndex, eps)
	local oldNeighborsPos = neighborsPos
	local ptsAdded = 0
	local distances = ptsDistMatrix[ptIndex]
	for i = 1, #ptsDistMatrix do
		if distances[i] <= eps and i ~= ptIndex then
			local bAdd = true
			for j = 1, oldNeighborsPos do
				if i == neighbors[j] then
					bAdd = false
					break
				end
			end
			if bAdd then
				ptsAdded = ptsAdded + 1
				neighborsPos = neighborsPos + 1
				neighbors[neighborsPos] = i
			end
		end
	end
	return ptsAdded
end
