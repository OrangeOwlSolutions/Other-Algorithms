function hullIndices = quickHullRecursion(segmentStart, segmentEnd, x, y, indices)
	
    numPoints = length(indices);

	% --- If there is only one point, it must belong to the convex hull
	if numPoints <= 1
		hullIndices = indices;
		return;
	end

	% --- Calculate the direction perpendicular to the split line
	segmentVector           = segmentEnd - segmentStart;
	segmentPerpendicular    = [segmentVector(2) -segmentVector(1)];

	% --- Determine the point, on one side of the line, with the maximum distance from the line. The two points found before along with this one form 
    %     a triangle.
	maximumDistance = -1;                   % --- Initialization
	pointWithMaximumDistanceIdx = -1;       % --- Initialization
	for i = 1 : numPoints
		idx = indices(i);
		currentPoint = [x(idx) y(idx)];
		toPoint = currentPoint - segmentStart;
		dist = abs(dot(segmentPerpendicular, toPoint));
		if dist > maximumDistance
			maximumDistance = dist;
			pointWithMaximumDistanceIdx = idx;
		end
	end
	pointWithMaximumDistance = [x(pointWithMaximumDistanceIdx) y(pointWithMaximumDistanceIdx)];

	% --- Split the points into the two halves
	indicesA = [];
	indicesB = [];

	for i = 1:numPoints
		idx = indices(i);
		if idx ~= pointWithMaximumDistanceIdx
			currentPoint = [x(idx) y(idx)];
			if whichSide(segmentEnd, pointWithMaximumDistance, currentPoint) == 'r'
				indicesA = [indicesA idx];
			elseif whichSide(pointWithMaximumDistance, segmentStart, currentPoint) == 'r'
				indicesB = [indicesB idx];
			end
		end
    end    

	% Recurse and re-combine
	hullIndicesA = quickHullRecursion(pointWithMaximumDistance, segmentEnd, x, y, indicesA);
	hullIndicesB = quickHullRecursion(segmentStart, pointWithMaximumDistance, x, y, indicesB);

	hullIndices = [hullIndicesA pointWithMaximumDistanceIdx hullIndicesB];