function W = darcyLateralFlow_discrete(W, Zgrid, mask, z_above)
% darcyLateralFlow_discrete: discrete water flow from terrain contact layer to neighbors
% Inputs:
%   W       - full 3D water volume (MxNxZ)
%   Zgrid   - terrain surface
%   mask    - logical mask of active water pixels in z_above
%   z_above - the current layer (index) where water is processed
% Output:
%   W       - updated after lateral flow

    [rows, cols, z_max] = size(W);
    directions = [0 1; 0 -1; 1 0; -1 0];

    % Candidate layer to write lateral movement
    z_target = z_above;
    W_next = W(:,:,z_target);
    written = false(rows, cols);

    [ix, iy] = find(mask);
    for k = 1:length(ix)
        x = ix(k);
        y = iy(k);
        if W(x, y, z_above) == 0, continue; end

        minSlope = 0;
        bestDir = [];

        for d = 1:4
            dx = directions(d,1);
            dy = directions(d,2);
            xn = x + dx;
            yn = y + dy;

            if xn < 1 || xn > rows || yn < 1 || yn > cols
                continue;
            end

            if W(xn, yn, z_target) > 0 || written(xn, yn)
                continue;
            end

            slope = (Zgrid(x, y) + 1) - Zgrid(xn, yn);
            if slope > minSlope
                minSlope = slope;
                bestDir = [dx, dy];
            end
        end

        if ~isempty(bestDir)
            xn = x + bestDir(1);
            yn = y + bestDir(2);

            % Move water only if no other source already moved here
            W(x, y, z_above) = 0;
            W(xn, yn, z_target) = 1;
            written(xn, yn) = true;
        end
    end
end
