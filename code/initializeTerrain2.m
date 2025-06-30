function [Xgrid, Ygrid, Zgrid, Z_index, dz] = initializeTerrain2(rows, dz)
% initializeTerrain: generates the base terrain
% Inputs:
%   rows  - number of grid rows (resolution)
%   dz    - vertical resolution (layer thickness)
% Outputs:
%   Xgrid, Ygrid - spatial grid
%   Zgrid        - elevation values (terrain)
%   Z_index      - discretized terrain index
%   dz           - returned for consistency

    % 1. Generate conceptual terrain as point cloud OR SELECT YOURS ''
    % pcXYZ = createConceptualTerrain_pc();
    pcXYZ = createTerrain_RPI_vs_TWI();
    
    % load('xyzPoints1.mat');  % Load your XYZ matrix --> FETpc1(:,1:3) in [deg, deg, km]
    % pcXYZ = xyzPoints;

    view(-45, 45);
    % 2. Interpolate to regular grid
    [Xgrid, Ygrid, Zgrid] = interpolateToGrid(pcXYZ, rows);
    view(-45, 45);
    % 3. Convert Z to voxel-based index (bottom of stack)
    Zmin = min(Zgrid(:));
    Z_index = ceil((Zgrid - Zmin) / dz) + 1;

    % 4. Optional: view and save terrain
    % figure;
    % surf(Xgrid, Ygrid, Zgrid, 'EdgeColor', 'none');
    % colormap turbo;
    % view(-45, 45);
    % title('Digital Elevation Model (DEM)');
    % axis equal tight;
    % xlabel('X'); ylabel('Y'); zlabel('Elevation');
    savefig('1.DEM.fig');

end
