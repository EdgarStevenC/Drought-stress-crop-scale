function visualizeWaterSimple(W, Xgrid, Ygrid, Zgrid, Zmin, dz, t)
% visualizeWaterSimple: 3D view of water voxels and terrain (geo-referenced)
% Inputs:
%   W      - 3D water volume (MxNxZ)
%   Xgrid  - meshgrid of X coordinates (longitude or easting)
%   Ygrid  - meshgrid of Y coordinates (latitude or northing)
%   Zgrid  - terrain elevation (MxN)
%   Zmin   - minimum terrain elevation
%   dz     - voxel vertical resolution
%   t      - current timestep index

    f1 = clf;
    hold on;

    % === Terrain surface ===
    surf(Xgrid, Ygrid, Zgrid, ...
        'EdgeColor', 'none', ...
        'FaceAlpha', 0.6, ...
        'FaceColor', 'interp');
    colormap turbo;
    shading interp;

    % === Water voxels ===
    [ix, iy, iz] = ind2sub(size(W), find(W > 0));
    if ~isempty(ix)
        Zpos = Zmin + (iz - 1) * dz;
        Xpos = Xgrid(sub2ind(size(Xgrid), ix, iy));
        Ypos = Ygrid(sub2ind(size(Ygrid), ix, iy));
        scatter3(Xpos, Ypos, Zpos, 5, [0.2 0.5 1], ...
            'filled', 'MarkerEdgeColor', 'none');
    end

    % === View settings ===
    z_max = size(W, 3);
    zlim([Zmin, Zmin + dz * z_max]);
    daspect([1 1 0.05]);  % Adjust if vertical exaggeration is needed
    xlabel('Longitude'); ylabel('Latitude'); zlabel('Elevation (m)');
    title(['🌧️ Water + Terrain - Step ', num2str(t)]);
    colorbar;
    view(-45,89);  % view(-30,35); %
    f1.Position = [1.0    49.0    1706.7    946.0]
    drawnow; 
end
