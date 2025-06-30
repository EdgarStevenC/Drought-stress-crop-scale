function [dzdx, dzdy, slope_mag, slope_angle] = computeGradientMetrics(Zgrid, cellsize)
% COMPUTEGRADIENTMETRICS - Calculates terrain slope from a DEM
%
% INPUTS:
%   Zgrid    - Elevation grid
%   cellsize - Spatial resolution (e.g., meters per pixel)
%
% OUTPUTS:
%   dzdx        - Gradient in X direction
%   dzdy        - Gradient in Y direction
%   slope_mag   - Magnitude of gradient (unitless)
%   slope_angle - Slope in degrees

    if nargin < 2
        cellsize = 1; % Default to 1 if resolution not provided
    end

    % Estimate partial derivatives (account for cell size)
    [dzdy, dzdx] = gradient(Zgrid, cellsize);  % Y first due to MATLAB grid order

    % Compute gradient magnitude (slope)
    slope_mag = sqrt(dzdx.^2 + dzdy.^2);  % unitless slope (rise/run)

    % Compute slope angle in degrees
    slope_angle = atan(slope_mag);        % radians
    slope_angle = rad2deg(slope_angle);   % degrees
end
