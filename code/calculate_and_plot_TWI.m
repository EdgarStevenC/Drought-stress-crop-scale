function [TWI, Xgrid, Ygrid, Zgrid] = calculate_and_plot_TWI(z, cellsize, plot_3d)
% Calculate Topographic Wetness Index (TWI) and create 3D visualization
% 
% INPUTS:
%   z        - elevation matrix (height values)
%   cellsize - cell size in meters
%   plot_3d  - boolean, true to create 3D plot (default: true)
%
% OUTPUTS:
%   TWI      - Topographic Wetness Index matrix
%   Xgrid    - X coordinate grid for plotting
%   Ygrid    - Y coordinate grid for plotting
%   Zgrid    - Z coordinate grid (elevation) for plotting
%
% EXAMPLE:
%   [TWI, X, Y, Z] = calculate_and_plot_TWI(elevation_matrix, 10, true);

if nargin < 3
   plot_3d = true;
end

[rows, cols] = size(z);

%% 1. CALCULATE SLOPE
[fx, fy] = gradient(z, cellsize); % Gradients in x and y directions
slope = atan(sqrt(fx.^2 + fy.^2)); % Slope in radians
slope(slope == 0) = 1e-6; % Avoid division by zero

%% 2. CALCULATE FLOW DIRECTION (D8 algorithm)
% Direction to neighboring cell with steepest descent
flow_dir = zeros(rows, cols);

% Vectors for 8 directions (N, NE, E, SE, S, SW, W, NW)
dx = [0, 1, 1, 1, 0, -1, -1, -1];
dy = [-1, -1, 0, 1, 1, 1, 0, -1];
distances = [cellsize, cellsize*sqrt(2), cellsize, cellsize*sqrt(2), ...
            cellsize, cellsize*sqrt(2), cellsize, cellsize*sqrt(2)];

for i = 2:rows-1
   for j = 2:cols-1
       max_gradient = -Inf;
       flow_direction = 0;
       
       for k = 1:8
           ni = i + dy(k);
           nj = j + dx(k);
           
           if ni >= 1 && ni <= rows && nj >= 1 && nj <= cols
               gradient_val = (z(i,j) - z(ni,nj)) / distances(k);
               if gradient_val > max_gradient
                   max_gradient = gradient_val;
                   flow_direction = k;
               end
           end
       end
       flow_dir(i,j) = flow_direction;
   end
end

%% 3. CALCULATE FLOW ACCUMULATION
flow_accum = ones(rows, cols); % Initialize with 1 (each cell counts itself)

% Sort cells by elevation (highest to lowest)
[~, sort_idx] = sort(z(:), 'descend');
[sort_i, sort_j] = ind2sub([rows, cols], sort_idx);

% Process cells in elevation order
for idx = 1:length(sort_idx)
   i = sort_i(idx);
   j = sort_j(idx);
   
   direction = flow_dir(i,j);
   if direction > 0
       % Find downstream cell
       ni = i + dy(direction);
       nj = j + dx(direction);
       
       if ni >= 1 && ni <= rows && nj >= 1 && nj <= cols
           flow_accum(ni,nj) = flow_accum(ni,nj) + flow_accum(i,j);
       end
   end
end

%% 4. CALCULATE SCA (Specific Catchment Area)
SCA = flow_accum * cellsize; % Convert to area in square meters

%% 5. CALCULATE TWI
TWI = log(SCA ./ tan(slope));

% Handle infinite/NaN values
TWI(isinf(TWI) | isnan(TWI)) = 0;

%% 6. CREATE COORDINATE GRIDS FOR PLOTTING
[X, Y] = meshgrid(1:cols, 1:rows);
Xgrid = X * cellsize; % Convert to real coordinates
Ygrid = Y * cellsize;
Zgrid = z; % Elevation grid

%% 7. CREATE 3D VISUALIZATION
if plot_3d
   figure('Name', 'Topographic Wetness Index - 3D Visualization', ...
          'Position', [100, 100, 1200, 800]);
   
   % Main 3D surface plot
   subplot(2,2,[1,2]);
   surf(Xgrid, Ygrid, Zgrid, TWI, 'EdgeColor', 'none', 'FaceAlpha', 0.8);
   
   % Customize 3D plot
   colormap(jet);
   colorbar('Label', 'TWI Values');
   xlabel('X Distance (m)');
   ylabel('Y Distance (m)');
   zlabel('Elevation (m)');
   title('3D Terrain Surface colored by Topographic Wetness Index');
   view(45, 30); % Set viewing angle
   grid on;
   axis tight;
   lighting phong;
   shading interp;
   
   % Add lighting for better visualization
   light('Position', [1, 1, 1], 'Style', 'infinite');
   
   % TWI 2D map
   subplot(2,2,3);
   imagesc(Xgrid(1,:), Ygrid(:,1), TWI);
   colormap(gca, jet);
   colorbar('Label', 'TWI Values');
   xlabel('X Distance (m)');
   ylabel('Y Distance (m)');
   title('TWI - Top View');
   axis equal tight;
   
   % Elevation contour map
   subplot(2,2,4);
   contour(Xgrid, Ygrid, Zgrid, 20, 'LineWidth', 1);
   colormap(gca, gray);
   colorbar('Label', 'Elevation (m)');
   xlabel('X Distance (m)');
   ylabel('Y Distance (m)');
   title('Elevation Contours');
   axis equal tight;
   
   % Print TWI statistics
   fprintf('\n=== TWI STATISTICS ===\n');
   fprintf('TWI Range: %.2f to %.2f\n', min(TWI(:)), max(TWI(:)));
   fprintf('TWI Mean: %.2f\n', mean(TWI(:)));
   fprintf('TWI Std: %.2f\n', std(TWI(:)));
   fprintf('High TWI areas (>%.1f): %.1f%% of terrain\n', ...
           mean(TWI(:)) + std(TWI(:)), ...
           100 * sum(TWI(:) > mean(TWI(:)) + std(TWI(:))) / numel(TWI));
   fprintf('Low TWI areas (<%.1f): %.1f%% of terrain\n', ...
           mean(TWI(:)) - std(TWI(:)), ...
           100 * sum(TWI(:) < mean(TWI(:)) - std(TWI(:))) / numel(TWI));
end

end