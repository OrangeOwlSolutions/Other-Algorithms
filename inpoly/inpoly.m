function isInPolygon = inpoly(testPoints, nodes)

TOL = 1.e-12;

numNodes = size(nodes, 1);

edge = [(1:numNodes-1)' (2:numNodes)'; numNodes 1];
numPoints   = size(testPoints,1);
numEdges    = size(edge, 1);

% --- Choose the direction with the biggest range as the "y-coordinate". This should ensure that the sorting is done along the best
% direction for long and skinny problems wrt either the x or y axes.
dxy = max(testPoints, [], 1) - min(testPoints, [], 1);
if dxy(1) > dxy(2)
   % --- Flip coordinates if x range is bigger
   testPoints = testPoints(:, [2, 1]);
   nodes = nodes(:, [2, 1]);
end
tol = TOL * min(dxy);

% --- Sort test points by y-value
[y, indices] = sort(testPoints(:, 2));
x      = testPoints(indices, 1);

%%%%%%%%%%%%%
% MAIN LOOP %
%%%%%%%%%%%%%
% --- Initializing to a boolean variable indicating if the test points are
% inside a polygon or not.
isInPolygon = false(numPoints, 1);     
isOnEdge    = isInPolygon;
for k = 1 : numEdges         % --- Loop through edges

    % --- Nodes in current edge
    n1 = edge(k, 1);
    n2 = edge(k, 2);

    % --- Endpoints
    %     The endpoints are sorted so that the edge nodes (x1, y1) and (x2, y2) have y1 <= y2
    y1 = nodes(n1, 2);
    y2 = nodes(n2, 2);
    if y1 < y2 % --- We are in the right order
        x1 = nodes(n1, 1);
        x2 = nodes(n2, 1);
    else
        % --- Swap y1 and y2
        yt = y1;
        y1 = y2;
        y2 = yt;
        % --- Define x1 and x2 in the right order
        x1 = nodes(n2, 1);
        x2 = nodes(n1, 1);
    end
    if x1 > x2
        xmin = x2;
        xmax = x1;
    else
        xmin = x1;
        xmax = x2;
    end

    % --- Binary search to find first point with y >= y1 for current edge.
    % Recall that y is sorted in ascending order
    if y(1) >= y1 % --- The first point has already y >= y1: start from here
        start = 1;
    elseif y(numPoints) < y1    % --- There is no point with y >= y1
        start = numPoints + 1;       
    else
        lower = 1;
        upper = numPoints;
        for j = 1 : numPoints
            start = round(0.5 * (lower + upper));
            if y(start) < y1
                lower = start;
            elseif y(start-1) < y1
                break;
            else
                upper = start;
            end
        end
    end

    % --- Loop through the points for which y >= y1
    for j = start : numPoints
        ycurrent = y(j);   
        if ycurrent <= y2     % --- We are in the segment (y1, y2) -> go for x
            xcurrent = x(j);   
            if xcurrent >= xmin
                if xcurrent <= xmax  % --- xmin <= x <= xmax & y1 <= y <= y2 

                    % --- Check if the point is isOnEdge the edge
                    isOnEdge(j) = isOnEdge(j) || (abs((y2 - ycurrent) * (x1 - xcurrent) - (y1 - ycurrent) * (x2 - xcurrent)) < tol);

                    % --- Do the intersection test
                    if (ycurrent < y2) && ((y2 - y1) * (xcurrent - x1) < (ycurrent - y1) * (x2 - x1))
                        isInPolygon(j) = ~isInPolygon(j);
                    end

                end
            elseif ycurrent < y2   % Deal with points exactly at vertices
                % Has to cross edge
                isInPolygon(j) = ~isInPolygon(j);
            end
        else
            % --- Due to the sorting, no points with > y value need to be checked
            break
        end
    end
end

% --- Re-index to undo the sorting
isInPolygon(indices) = isInPolygon | isOnEdge;

end      
