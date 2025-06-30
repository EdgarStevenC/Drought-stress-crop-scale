function [values_vector] = getStrategicPoints(Z_matrix)
% GETSTRATEGICPOINTS
% Extracts values at 8 strategic point locations from a 200x200 matrix
% Input: Z_matrix - 200x200 matrix covering 1km x 1km terrain
% Output: values_vector - 8x1 vector with values at strategic locations

% Validate input
if ~isequal(size(Z_matrix), [200, 200])
    error('Input must be a 200x200 matrix');
end

% Grid parameters: 200x200 grid covers 1000m x 1000m
% So each cell = 5m x 5m
grid_resolution = 1000 / 200; % 5 meters per cell

% Strategic point coordinates in meters (from terrain design)
strategic_coords_m = [
    250, 750;  % P1: Crater minimum
    310, 750;  % P2: Crater curvature (60m from center)
    750, 750;  % P3: Mountain maximum  
    690, 750;  % P4: Mountain curvature (60m from center)
    250, 150;  % P5: Wave maximum (sin=1, cos=1) - should be POSITIVE
    150, 75;   % P6: Wave minimum (sin=-1, cos=1) - should be NEGATIVE  
    750, 125;  % P7: Strong slope
    370, 750   % P8: Flat reference (120m from crater)
];

% Convert coordinates from meters to matrix indices
% MATLAB matrix indexing: (row, col) where row=1 is top, col=1 is left
% Our terrain: X=[0,1000], Y=[0,1000] but Y=1000 is top, Y=0 is bottom
strategic_indices = zeros(8, 2);
for i = 1:8
    x_m = strategic_coords_m(i, 1);  % X coordinate in meters [0-1000]
    y_m = strategic_coords_m(i, 2);  % Y coordinate in meters [0-1000]
    
    % Convert to matrix indices (1-based)
    % X coordinate -> column index (left to right)
    col_idx = round(x_m / grid_resolution) + 1;
    
    % Y coordinate -> row index (top to bottom, Y flipped)
    % Y=1000 (top) -> row=1, Y=0 (bottom) -> row=200
    row_idx = round((1000 - y_m) / grid_resolution) + 1;
    
    % Ensure indices are within bounds [1, 200]
    col_idx = max(1, min(200, col_idx));
    row_idx = max(1, min(200, row_idx));
    
    strategic_indices(i, :) = [row_idx, col_idx];
end

% Debug: Print the mapping for verification
fprintf('\n=== COORDINATE MAPPING DEBUG ===\n');
point_names = {'P1_crater_min', 'P2_crater_curv', 'P3_mountain_max', 'P4_mountain_curv', ...
               'P5_wave_max', 'P6_wave_min', 'P7_slope_strong', 'P8_flat_ref'};

for i = 1:8
    fprintf('%s: (%.0f,%.0f)m -> [%d,%d] matrix\n', point_names{i}, ...
            strategic_coords_m(i,1), strategic_coords_m(i,2), ...
            strategic_indices(i,1), strategic_indices(i,2));
end

% Extract values from the matrix
values_vector = zeros(8, 1);
for i = 1:8
    row_idx = strategic_indices(i, 1);
    col_idx = strategic_indices(i, 2);
    values_vector(i) = Z_matrix(row_idx, col_idx);
end

% Display results with expected signs for verification
fprintf('\n=== STRATEGIC POINTS VALUES ===\n');
expected_signs = {'NEG', 'POS', 'NEG', 'POS', 'NEG', 'POS', 'VAR', 'ZERO'};
for i = 1:8
    fprintf('%s: %.3f (expected: %s) at [%d,%d]\n', point_names{i}, values_vector(i), ...
            expected_signs{i}, strategic_indices(i,1), strategic_indices(i,2));
end

% Additional verification for Zone 3 (ondulations)
fprintf('\n=== ZONE 3 VERIFICATION ===\n');
fprintf('P5 (Wave Max): %.3f (should be NEGATIVE - convex curvature)\n', values_vector(5));
fprintf('P6 (Wave Min): %.3f (should be POSITIVE - concave curvature)\n', values_vector(6));
if values_vector(5) > 0 || values_vector(6) < 0
    fprintf('WARNING: Zone 3 signs are incorrect! Check RPI calculation or coordinate mapping.\n');
else
    fprintf('Zone 3 signs are correct!\n');
end

end