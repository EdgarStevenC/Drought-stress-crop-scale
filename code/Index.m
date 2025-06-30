function [] = Index(Xgrid, Ygrid, Zgrid)

    %% No.1 _ DEM 
    f1 = figure; subplot(2,3,1)
    surf(Xgrid, Ygrid, Zgrid, 'EdgeColor', 'none');
    title('Interpolated Terrain (DEM)');
    xlabel('X'); ylabel('Y'); zlabel('Elevation');
    colormap turbo; colorbar;
    view(-45, 45); axis tight; grid on;
    %% No.2 _ Scaled gradient vectors

    [dzdx, dzdy] = gradient(Zgrid);
    % Reduce density for clarity
    step = 10;
    Xs = Xgrid(1:step:end, 1:step:end);
    Ys = Ygrid(1:step:end, 1:step:end);
    Zs = Zgrid(1:step:end, 1:step:end);
    U = -dzdx(1:step:end, 1:step:end);
    V = -dzdy(1:step:end, 1:step:end);
    W = zeros(size(U));  % Flat arrows

    % Compute magnitudes
    mag = sqrt(U.^2 + V.^2);
    % === Limit large vectors ===
    max_mag = prctile(mag(:), 95);   % Clip extreme 5%
    mag = min(mag, max_mag);
    % Recalculate scaled vectors with preserved direction
    scale = 0.05;  % Visual scale
    U = (U ./ (sqrt(U.^2 + V.^2) + eps)) .* mag * scale;
    V = (V ./ (sqrt(U.^2 + V.^2) + eps)) .* mag * scale;

    % Plot surface
    hold on;  subplot(2,3,1)
    surf(Xgrid, Ygrid, Zgrid, 'EdgeColor', 'none', 'FaceAlpha', 0.8); hold on;
    % Plot arrows
    quiver3(Xs, Ys, Zs, U, V, W, 1, 'Color', 'k', 'LineWidth', 2);
    title('Gradient Vectors');
    xlabel('X'); ylabel('Y'); zlabel('Elevation');
    view(-45, 45); axis tight; grid on;

    %% No.3 _ Slope Angle 
    [dzdx, dzdy, slope_mag, slope_angle] = computeGradientMetrics(Zgrid, 5);

    hold on;  subplot(2,3,2)
    surf(Xgrid, Ygrid, Zgrid, slope_angle, 'EdgeColor', 'none','FaceAlpha', 1);
    colormap turbo;
    h = colorbar;
    ylabel(h, 'Slope Angle (°)');
    title('Slope Angle -> arctangent( sqrt( (∂Z/∂x)^2 + (∂Z/∂y)^2 ) )');
    xlabel('X'); ylabel('Y'); zlabel('Elevation');
    view(-45, 45); axis tight; grid on;
    %% No.4 _ Curvature
    curvature = computeCurvature(Zgrid);
    hold on;  subplot(2,3,3)
    surf(Xgrid, Ygrid, Zgrid, curvature,'EdgeColor', 'none', 'FaceAlpha', 1);
    colormap turbo
    h = colorbar;
    xlabel('X');
    ylabel('Y');
    zlabel('Elevation');
    title('3D Terrain Curvature -> (∂²Z/∂x²) + (∂²Z/∂y²)');
    axis tight;
    grid on;
    view(-45, 45); ylabel(h, 'curvature');
    %% No.5 _ Inverse slope magnitude
    flowAcc = computeFlowAccumulation2(Zgrid); 
    % hold on; subplot(2,3,4)
    % surf(Xgrid, Ygrid, Zgrid, flowAcc,'EdgeColor', 'none', 'FaceAlpha', 1);
    % colormap(turbo);
    % colorbar;
    % title('Inverse slope magnitude -> (1 ./ sqrt( (∂Z/∂x)^2 + (∂Z/∂y)^2 ) + ε )');
    % xlabel('X'); ylabel('Y'); zlabel('Elevation');
    % view(-45, 45); grid on; axis tight;

   
    %% No.7 _ RPI Upland-Lowland
    [M, N] = size(Zgrid);
    % Compute first derivatives (gradient components)
    [dZdx, dZdy] = gradient(Zgrid);
    % Slope magnitude
    slopeMag = sqrt(dZdx.^2 + dZdy.^2);
    % Slope angle (in degrees)
    slopeAngle = rad2deg(atan(slopeMag));
    % Laplacian 
    lap = del2(Zgrid);  % Approximate ∇²z
    % RPI: Laplacian divided by gradient magnitude + epsilon
    epsilon = 1e-3;
    rpi = (lap ./ (slopeMag + epsilon));

    % RPI rescaled between 2nd and 98th percentile
    lowP = prctile(rpi(:), 2);
    highP = prctile(rpi(:), 98);
    rpi = min(max(rpi, lowP), highP);


    hold on; subplot(2,3,6)
    surf(Xgrid, Ygrid, Zgrid, rpi, 'EdgeColor', 'none');
    colormap turbo; h = colorbar;
    title('RPI -> Upland vs Lowland');
    xlabel('X'); ylabel('Y'); zlabel('Elevation');
    view(45, 30); axis tight; grid on;
    colormap turbo
    ylabel(h, 'Runoff Potential Index (RPI)');
    view(-45, 45);

    %% No.6 _ RPI
    [M, N] = size(Zgrid);
    % Compute first derivatives (gradient components)
    [dZdx, dZdy] = gradient(Zgrid);
    % Slope magnitude
    slopeMag = sqrt(dZdx.^2 + dZdy.^2);
    % Slope angle (in degrees)
    slopeAngle = rad2deg(atan(slopeMag));
    % Laplacian 
    lap = del2(Zgrid);  % Approximate ∇²z
    % RPI: Laplacian divided by gradient magnitude + epsilon
    epsilon = 1e-3;
    RPI = (lap ./ (slopeMag + epsilon));


    hold on; subplot(2,3,5)
    surf(Xgrid, Ygrid, Zgrid, RPI, 'EdgeColor', 'none');
    colormap turbo; h = colorbar;
    title('RPI -> ( (∂²Z/∂x²)+(∂²Z/∂y²) ./ sqrt((∂Z/∂x)^2 +(∂Z/∂y)^2)+ε )');
    xlabel('X'); ylabel('Y'); zlabel('Elevation');
    view(45, 30); axis tight; grid on;
    ylabel(h, 'Runoff Potential Index (RPI)');
    view(-45, 45);

    %% No.8 _ TWI
    [TWI, ~, ~, ~] = calculate_and_plot_TWI(Zgrid, size(Zgrid,1), false);
    % Create custom 3D plot
    hold on; subplot(2,3,4),
    surf(Xgrid, Ygrid, Zgrid, TWI, 'EdgeColor', 'none', 'FaceAlpha', 0.8);
    
    % Customize 3D plot
    colormap(jet);
    c1 = colorbar;
    c1.Label.String = 'Topographic Wetness Index (TWI)'; % Correct way to set colorbar label
    xlabel('X Distance (m)');
    ylabel('Y Distance (m)');
    zlabel('Elevation (m)');
    title('TWI -> ln(Drainage Area / Slope)');
    view(-45, 45); 
    axis tight;
    lighting phong;
    shading interp;
    % Add lighting for better visualization
    light('Position', [1, 1, 1], 'Style', 'infinite');
    f1.Position = [1.0, 49.0, 1706.7, 946.0];


% [rpi_values, twi_values] = getStrategicPointsFixed(RPI, TWI, Xgrid, Ygrid);
% plotDualAxisComparison(rpi_values, twi_values);

% (X,Y)
P1 = [150, 51];   % [150, 50]
P2 = [125, 51];   % [150, 60]
P3 = [150, 150];  % [50, 50]
P4 = [125, 150];  % [50, 60]
P5 = [16, 11];    % [150, 125]
P6 = [31, 11];    % [150, 140]
P7 = [110, 150];  % [50, 90]
P8 = [105, 108];  % (60,  150) - [50, 140]

points = [P1; P2; P3; P4; P5; P6; P8];

rpi_values = zeros(7, 1);
twi_values = zeros(7, 1);

for i = 1:7
    row = points(i, 1);
    col = points(i, 2);
    rpi_values(i) = RPI(row, col);
    twi_values(i) = TWI(row, col);
end

% Crear la gráfica bonita con ejes duales
plotDualAxisComparison_7points(rpi_values, twi_values);
% f1 = gcf;
% f1.Position = [1.0  49.0 1706.7 946.0];
end

