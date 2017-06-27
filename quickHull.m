function hullIndices = quickHull(x, y)
	
    numPoints = length(x);

	% --- If the number of points is less or equal to 2, then the convex
	% hull degenerates into the set of points itself.
    if (numPoints <= 2)
		hullIndices = 1 : numPoints;
		return;
	end

	% --- 1. Find the points with minimum and maximum x coordinates, as these will always be part of the convex hull.
	[minx minIdxx] = min(x);
	[maxx maxIdxx] = max(x);
	
    
    % --- 2. Use the line formed by the two points to divide the set in two subsets of points, which will be processed recursively.
    segmentStart    = [x(maxIdxx) y(maxIdxx)];
	segmentEnd      = [x(minIdxx) y(minIdxx)];

	rightIndices = [];
	leftIndices  = [];

	for idx = 1:numPoints
		if idx ~= minIdxx && idx ~= maxIdxx
			currentPoint = [x(idx) y(idx)];
			if (whichSide(segmentStart, segmentEnd, currentPoint) == 'r')
				rightIndices = [rightIndices idx];
			else
				leftIndices = [leftIndices idx];
			end
		end
	end

	% --- Recursion. Remember to orientate segments counterclockwise
	rightHulls = quickHullRecursion(segmentEnd, segmentStart, x, y, rightIndices);
	leftHulls  = quickHullRecursion(segmentStart, segmentEnd, x, y, leftIndices);

	hullIndices = [maxIdxx rightHulls minIdxx leftHulls];
    