function side = whichSide(segmentStart, segmentEnd, currentPoint)
	
    direction       = [(segmentEnd - segmentStart) 0];
	toPoint         = [(currentPoint - segmentStart) 0];
	vectorProduct   = cross(direction, toPoint);
	
    if vectorProduct(3) > 0         % --- Side is left
		side = 'l';
	elseif vectorProduct(3) == 0    % --- Side is co-linear
		side = 'c';
    else                            % --- Side is right
		side = 'r';
	end
