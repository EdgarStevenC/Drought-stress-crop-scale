function plotDualAxisComparison(rpi_values_vector, TWI_values_vector)
% Plot RPI vs TWI with dual Y-axes and point representations

% Validate inputs
if length(rpi_values_vector) ~= 8 || length(TWI_values_vector) ~= 8
    error('Both input vectors must have 8 elements');
end

% Point labels and descriptions
point_labels = {'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'P8'};
point_descriptions = {'Crater\nMinimum', 'Crater\nCurvature', 'Mountain\nMaximum', 'Mountain\nCurvature', ...
                     'Wave\nMaximum', 'Wave\nMinimum', 'Strong\nSlope', 'Flat\nReference'};
point_zones = {'Zone 1\n(Concave)', 'Zone 1\n(Concave)', 'Zone 2\n(Convex)', 'Zone 2\n(Convex)', ...
              'Zone 3\n(Undulations)', 'Zone 3\n(Undulations)', 'Zone 4\n(Slope)', 'Zone 1\n(Flat)'};

% Terrain feature symbols for each point
terrain_symbols = {'Crater', 'Rim', 'Peak', 'Base', 'Wave+', 'Wave-', 'Slope', 'Flat'};

% Create figure
figure('Position', [100, 100, 1400, 700], 'Color', 'white');

% Create the main plot with dual axes
yyaxis left
h1 = plot(1:8, rpi_values_vector, 'b-o', 'LineWidth', 3.5, 'MarkerSize', 12, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'darkblue');
ylabel('RPI (Runoff Potential Index)', 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'blue');
set(gca, 'YColor', 'blue');
grid on;

% Add RPI value annotations
for i = 1:8
    text(i-0.15, rpi_values_vector(i), sprintf('%.3f', rpi_values_vector(i)), ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
         'FontSize', 10, 'Color', 'blue', 'FontWeight', 'bold');
end

yyaxis right
h2 = plot(1:8, TWI_values_vector, 'r-s', 'LineWidth', 3.5, 'MarkerSize', 12, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'darkred');
ylabel('TWI (Topographic Wetness Index)', 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'red');
set(gca, 'YColor', 'red');

% Add TWI value annotations
for i = 1:8
    text(i+0.15, TWI_values_vector(i), sprintf('%.3f', TWI_values_vector(i)), ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
         'FontSize', 10, 'Color', 'red', 'FontWeight', 'bold');
end

% Format x-axis
set(gca, 'XTick', 1:8, 'XTickLabel', point_descriptions, 'FontSize', 11);
xlim([0.5, 8.5]);
xlabel('Strategic Points', 'FontSize', 14, 'FontWeight', 'bold');

% Add main title
title('Topographic Index Comparison: RPI vs TWI at Strategic Terrain Features', ...
      'FontSize', 16, 'FontWeight', 'bold', 'Pad', 20);

% Add legend
legend([h1, h2], {'RPI (Left Axis)', 'TWI (Right Axis)'}, ...
       'Location', 'north', 'FontSize', 12, 'Box', 'on');

% Enhance grid
set(gca, 'GridAlpha', 0.3, 'GridLineStyle', '-');
set(gca, 'LineWidth', 1.2);

% Add point representation annotations below x-axis
y_offset_factor = 0.05; % Adjust this to position annotations properly
yyaxis left % Get left axis limits for positioning
ylims_left = ylim;
yyaxis right % Get right axis limits for positioning
ylims_right = ylim;

% Calculate position for annotations (below the plot)
annotation_y = -0.15; % Relative position below x-axis

% Add point representations and zone info
for i = 1:8
    % Add terrain symbol
    text(i, annotation_y, terrain_symbols{i}, 'HorizontalAlignment', 'center', ...
         'FontSize', 12, 'Units', 'normalized', 'FontWeight', 'bold');
    
    % Add zone information
    text(i, annotation_y - 0.08, point_zones{i}, 'HorizontalAlignment', 'center', ...
         'FontSize', 9, 'Units', 'normalized', 'Color', [0.4, 0.4, 0.4], 'FontWeight', 'bold');
end

% Add zone background colors
yyaxis left
hold on;
% Zone 1: Light blue background
fill([0.5, 2.5, 2.5, 0.5], [ylims_left(1), ylims_left(1), ylims_left(2), ylims_left(2)], ...
     'blue', 'FaceAlpha', 0.05, 'EdgeColor', 'none');
% Zone 2: Light red background  
fill([2.5, 4.5, 4.5, 2.5], [ylims_left(1), ylims_left(1), ylims_left(2), ylims_left(2)], ...
     'red', 'FaceAlpha', 0.05, 'EdgeColor', 'none');
% Zone 3: Light green background
fill([4.5, 6.5, 6.5, 4.5], [ylims_left(1), ylims_left(1), ylims_left(2), ylims_left(2)], ...
     'green', 'FaceAlpha', 0.05, 'EdgeColor', 'none');
% Zone 4 & Flat: Light yellow background
fill([6.5, 8.5, 8.5, 6.5], [ylims_left(1), ylims_left(1), ylims_left(2), ylims_left(2)], ...
     'yellow', 'FaceAlpha', 0.05, 'EdgeColor', 'none');

% Add zone labels at the top
text(1.5, ylims_left(2)*0.95, 'ZONE 1: Concave Depression', 'HorizontalAlignment', 'center', ...
     'FontSize', 10, 'FontWeight', 'bold', 'Color', 'blue', 'BackgroundColor', 'white');
text(3.5, ylims_left(2)*0.95, 'ZONE 2: Convex Mountain', 'HorizontalAlignment', 'center', ...
     'FontSize', 10, 'FontWeight', 'bold', 'Color', 'red', 'BackgroundColor', 'white');
text(5.5, ylims_left(2)*0.95, 'ZONE 3: Undulations', 'HorizontalAlignment', 'center', ...
     'FontSize', 10, 'FontWeight', 'bold', 'Color', 'green', 'BackgroundColor', 'white');
text(7.5, ylims_left(2)*0.95, 'ZONE 4: Strong Slope', 'HorizontalAlignment', 'center', ...
     'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.8, 0.6, 0], 'BackgroundColor', 'white');

% Print detailed summary
fprintf('\n=== DUAL-AXIS INDEX COMPARISON ===\n');
fprintf('%-15s | %-10s | %-10s | %-15s | %s\n', 'Point', 'RPI', 'TWI', 'Terrain Feature', 'Zone');
fprintf('%-15s | %-10s | %-10s | %-15s | %s\n', repmat('-', 1, 15), repmat('-', 1, 10), repmat('-', 1, 10), repmat('-', 1, 15), repmat('-', 1, 20));
features = {'Crater Min', 'Crater Curv', 'Mountain Max', 'Mountain Curv', 'Wave Max', 'Wave Min', 'Strong Slope', 'Flat Ref'};
zones = {'Zone 1', 'Zone 1', 'Zone 2', 'Zone 2', 'Zone 3', 'Zone 3', 'Zone 4', 'Zone 1'};
for i = 1:8
    fprintf('%-15s | %10.3f | %10.3f | %-15s | %s\n', ...
            point_labels{i}, rpi_values_vector(i), TWI_values_vector(i), features{i}, zones{i});
end

end