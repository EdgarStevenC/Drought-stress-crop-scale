function [Xgrid, Ygrid, Zgrid] = interpolateToGrid(XYZ, rows, sigma)
% interpolateToGrid: interpolates a point cloud to a grid and applies optional Gaussian smoothing
% Inputs:
%   XYZ   - point cloud (Nx3)
%   rows  - grid resolution
%   sigma - (optional) Gaussian smoothing std deviation
% Outputs:
%   Xgrid, Ygrid - spatial grid
%   Zgrid        - interpolated (and optionally smoothed) elevation grid

    X = XYZ(:,1);
    Y = XYZ(:,2);
    Z = XYZ(:,3);

    % Grid limits
    xlin = linspace(min(X), max(X), rows);
    ylin = linspace(min(Y), max(Y), rows);
    [Xgrid, Ygrid] = meshgrid(xlin, ylin);

    % Interpolate point cloud onto grid
    Zgrid = griddata(X, Y, Z, Xgrid, Ygrid, 'natural');

    % Optional: smooth with Gaussian filter if sigma provided
    if nargin > 2 && sigma > 0
        % Fill NaNs temporarily
        Zmean = mean(Zgrid(:), 'omitnan');
        Zgrid(isnan(Zgrid)) = Zmean;

        % Apply Gaussian smoothing
        Zgrid = imgaussfilt(Zgrid, sigma, 'FilterSize', 11);
    end
end



% function [Xgrid, Ygrid, Zgrid] = interpolateToGrid(pcXYZ, gridRes)
% % INTERPOLATETOGRID - Interpolate point cloud (XYZ) to regular grid (DEM)
% %
% % INPUTS:
% %   pcXYZ   - n x 3 matrix of [X, Y, Z] point cloud
% %   gridRes - scalar, number of grid points per axis (e.g., 200)
% %
% % OUTPUTS:
% %   Xgrid, Ygrid - meshgrid coordinates
% %   Zgrid        - interpolated elevation grid (DEM)
% 
%     % Extract X, Y, Z
%     X = pcXYZ(:,1);
%     Y = pcXYZ(:,2);
%     Z = pcXYZ(:,3);
% 
%     % Create grid domain
%     xlin = linspace(min(X), max(X), gridRes);
%     ylin = linspace(min(Y), max(Y), gridRes);
%     [Xgrid, Ygrid] = meshgrid(xlin, ylin);
% 
%     % Interpolate using 'natural' method (good for elevation)
%     Zgrid = griddata(X, Y, Z, Xgrid, Ygrid, 'natural');
% 
%     % Plot for verification
%     figure;
%     surf(Xgrid, Ygrid, Zgrid, 'EdgeColor', 'none');
%     title('Interpolated Terrain (DEM)');
%     xlabel('X'); ylabel('Y'); zlabel('Elevation');
%     colormap parula; colorbar;
%     view(45, 30); axis tight; grid on;
% 
%     colormap turbo
%     f1.Position= [786.3333 405.6667 719.3333 554];
% end
