function [pcXYZ] = createConceptualTerrain_pc()
% CREATECONCEPTUALTERRAIN_PC
% Returns a synthetic point cloud [X, Y, Z] with clean transitions between quadrants

    % Grid size
    nx = 200; ny = 200;
    [Xgrid, Ygrid] = meshgrid(linspace(0, 1, nx), linspace(0, 1, ny));
    Zgrid = zeros(ny, nx);

    % Quadrant masks
    Q1 = Xgrid <= 0.5 & Ygrid >= 0.5;  % Top-left
    Q2 = Xgrid >  0.5 & Ygrid >= 0.5;  % Top-right
    Q3 = Xgrid <= 0.5 & Ygrid <  0.5;  % Bottom-left
    Q4 = Xgrid >  0.5 & Ygrid <  0.5;  % Bottom-right

    % Define base elevations
    Zgrid(Q1) = 30;
    Zgrid(Q2) = 60 + 10 * sin(10 * Xgrid(Q2));
    Zgrid(Q3) = 10;
    Zgrid(Q4) = 50;

    % Add local curvature
    Zgrid(Q1) = Zgrid(Q1) - (Xgrid(Q1) - 0.25).^2 * 100 - (Ygrid(Q1) - 0.75).^2 * 100;
    Zgrid(Q2) = Zgrid(Q2) + (Xgrid(Q2) - 0.75).^2 * 50  + (Ygrid(Q2) - 0.75).^2 * 50;
    Zgrid(Q3) = Zgrid(Q3) - (Xgrid(Q3) - 0.25).^2 * 150 - (Ygrid(Q3) - 0.25).^2 * 150;
    Zgrid(Q4) = Zgrid(Q4) + (Xgrid(Q4) - 0.75).^2 * 80  + (Ygrid(Q4) - 0.25).^2 * 80;

    % Smooth transitions further
    Zgrid = imgaussfilt(Zgrid, 3);      % Local smoothing
    Zgrid = imgaussfilt(Zgrid, 6);      % Global smoothing for transitions

    % Rescale to smoother elevation range
    Zgrid = rescale(Zgrid, 2, 8);       % Adjust min/max elevation

    % Point cloud output
    pcXYZ = [Xgrid(:), Ygrid(:), Zgrid(:)];

    % Preview
    figure;
    scatter3(pcXYZ(:,1), pcXYZ(:,2), pcXYZ(:,3), 6, pcXYZ(:,3), 'filled');
    title('Smoothed Conceptual Terrain (pcXYZ)');
    xlabel('X'); ylabel('Y'); zlabel('Elevation');
    axis equal; grid on; view(45, 30);
    colormap turbo; colorbar;
end
