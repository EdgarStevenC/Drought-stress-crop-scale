function plotDualAxisComparison_7points_improved(rpi_values_vector, TWI_values_vector)
% Plot RPI vs TWI with dual Y-axes and point representations (7 points, no P7)
% IMPROVED VERSION with better number visibility and cleaner legend

% Validate inputs
if length(rpi_values_vector) ~= 7 || length(TWI_values_vector) ~= 7
    error('Both input vectors must have 7 elements');
end

% Point labels and descriptions (without P7)
point_labels = {'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P8'};
point_descriptions = {'Crater\nMinimum', 'Crater\nCurvature', 'Mountain\nMaximum', 'Mountain\nCurvature', ...
                     'Wave\nMaximum', 'Wave\nMinimum', 'Flat\nReference'};
point_zones = {'Zone 1\n(Concave)', 'Zone 1\n(Concave)', 'Zone 2\n(Convex)', 'Zone 2\n(Convex)', ...
              'Zone 3\n(Undulations)', 'Zone 3\n(Undulations)', 'Zone 1\n(Flat)'};

% Terrain feature symbols for each point
terrain_symbols = {'Crater', 'Rim', 'Peak', 'Base', 'Wave+', 'Wave-', 'Flat'};

% Create figure with larger size for better readability
figure('Position', [100, 100, 1600, 800], 'Color', 'white');

% Create the main plot with dual axes
yyaxis left
h1 = plot(1:7, rpi_values_vector, 'b-o', 'LineWidth', 4, 'MarkerSize', 14, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', [0 0 0.5]);
ylabel('RPI (Runoff Potential Index)', 'FontSize', 16, 'FontWeight', 'bold', 'Color', 'blue');
set(gca, 'YColor', 'blue');

% Set concentrated Y-axis limits for RPI (with some padding around data)
rpi_min = min(rpi_values_vector);
rpi_max = max(rpi_values_vector);
rpi_range = rpi_max - rpi_min;
ylim([rpi_min - 0.3*rpi_range, rpi_max + 0.4*rpi_range]); % Extra space at top for title

grid on;

% Get Y-axis limits for better annotation positioning
ylims_left = ylim;
y_range_left = ylims_left(2) - ylims_left(1);

% Add RPI value annotations with improved positioning and styling
for i = 1:7
    % Calculate vertical offset based on data point position (reduced offset)
    if rpi_values_vector(i) > 0
        v_offset = y_range_left * 0.04; % Reduced from 0.08 to 0.04
        v_align = 'bottom';
    else
        v_offset = -y_range_left * 0.04; % Reduced from 0.08 to 0.04
        v_align = 'top';
    end
    
    % Special handling for specific problematic points
    if i == 1  % P1 (Crater Minimum) - move more to the left
        h_offset = -0.25;
        v_offset = y_range_left * 0.06; % Slightly higher
    elseif i == 3  % P3 (Mountain Maximum) - put above the point
        h_offset = -0.1;
        v_offset = y_range_left * 0.06; % Above point
        v_align = 'bottom';
    elseif i == 6  % P6 (Wave Minimum) - move closer to point
        h_offset = -0.15;
        v_offset = -y_range_left * 0.05; % Closer separation
        v_align = 'top';
    elseif i == 7  % P7 (Flat Reference) - put above the point
        h_offset = -0.1;
        v_offset = y_range_left * 0.06; % Above point
        v_align = 'bottom';
    else
        h_offset = -0.1;
    end
    
    % Create text annotation with background box for better visibility
    text(i + h_offset, rpi_values_vector(i) + v_offset, sprintf('%.3f', rpi_values_vector(i)), ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', v_align, ...
         'FontSize', 12, 'Color', 'blue', 'FontWeight', 'bold', ...
         'BackgroundColor', 'white');
end

yyaxis right
h2 = plot(1:7, TWI_values_vector, 'r-s', 'LineWidth', 4, 'MarkerSize', 14, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', [0.5 0 0]);
ylabel('TWI (Topographic Wetness Index)', 'FontSize', 16, 'FontWeight', 'bold', 'Color', 'red');
set(gca, 'YColor', 'red');

% Set concentrated Y-axis limits for TWI (with some padding around data)
twi_min = min(TWI_values_vector);
twi_max = max(TWI_values_vector);
twi_range = twi_max - twi_min;
ylim([twi_min - 0.2*twi_range, twi_max + 0.3*twi_range]); % Extra space at top for title

% Get Y-axis limits for TWI annotations
ylims_right = ylim;
y_range_right = ylims_right(2) - ylims_right(1);

% Add TWI value annotations with improved positioning and styling
for i = 1:7
    % Calculate vertical offset based on data point position (reduced offset)
    if TWI_values_vector(i) > mean(TWI_values_vector)
        v_offset = y_range_right * 0.04; % Reduced from 0.08 to 0.04
        v_align = 'bottom';
    else
        v_offset = -y_range_right * 0.04; % Reduced from 0.08 to 0.04
        v_align = 'top';
    end
    
    % Special handling for specific problematic points
    if i == 1  % P1 (Crater Minimum) - move more to the right
        h_offset = 0.25;
        v_offset = y_range_right * 0.06; % Slightly higher
    elseif i == 5  % P5 (Wave Maximum) - put below the point
        h_offset = 0.1;
        v_offset = -y_range_right * 0.06; % Below point
        v_align = 'top';
    elseif i == 6  % P6 (Wave Minimum) - put red number above
        h_offset = 0.15;
        v_offset = y_range_right * 0.06; % Above point
        v_align = 'bottom';
    else
        h_offset = 0.1;
    end
    
    % Create text annotation with background box for better visibility
    text(i + h_offset, TWI_values_vector(i) + v_offset, sprintf('%.3f', TWI_values_vector(i)), ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', v_align, ...
         'FontSize', 12, 'Color', 'red', 'FontWeight', 'bold', ...
         'BackgroundColor', 'white');
end

% Format x-axis
set(gca, 'XTick', 1:7, 'XTickLabel', point_descriptions, 'FontSize', 12);
xlim([0.5, 7.5]);
xlabel('Strategic Points', 'FontSize', 16, 'FontWeight', 'bold');

% Add main title
title('Topographic Index Comparison: RPI vs TWI at Strategic Terrain Features', ...
      'FontSize', 18, 'FontWeight', 'bold');

% IMPROVED LEGEND - Clean and simple
legend([h1, h2], {'RPI', 'TWI'}, ...
       'Location', 'northeast', 'FontSize', 14, 'Box', 'on');

% Enhance grid and axes
set(gca, 'GridAlpha', 0.4, 'GridLineStyle', '-', 'LineWidth', 1.5);

% Add zone background colors with updated limits
yyaxis left
ylims_left_final = ylim;
hold on;

% Zone 1: Light blue background (P1, P2)
fill([0.5, 2.5, 2.5, 0.5], [ylims_left_final(1), ylims_left_final(1), ylims_left_final(2), ylims_left_final(2)], ...
     'blue', 'FaceAlpha', 0.03, 'EdgeColor', 'none');
% Zone 2: Light red background (P3, P4)
fill([2.5, 4.5, 4.5, 2.5], [ylims_left_final(1), ylims_left_final(1), ylims_left_final(2), ylims_left_final(2)], ...
     'red', 'FaceAlpha', 0.03, 'EdgeColor', 'none');
% Zone 3: Light green background (P5, P6)
fill([4.5, 6.5, 6.5, 4.5], [ylims_left_final(1), ylims_left_final(1), ylims_left_final(2), ylims_left_final(2)], ...
     'green', 'FaceAlpha', 0.03, 'EdgeColor', 'none');
% Flat zone: Light yellow background (P8)
fill([6.5, 7.5, 7.5, 6.5], [ylims_left_final(1), ylims_left_final(1), ylims_left_final(2), ylims_left_final(2)], ...
     'yellow', 'FaceAlpha', 0.03, 'EdgeColor', 'none');

% Add zone labels at the top with better positioning
yyaxis left
ylims_left_final = ylim; % Get final limits after all adjustments
zone_y_pos = ylims_left_final(2) - (ylims_left_final(2) - ylims_left_final(1)) * 0.15;
text(1.5, zone_y_pos, 'ZONE 1: Concave Depression', 'HorizontalAlignment', 'center', ...
     'FontSize', 11, 'FontWeight', 'bold', 'Color', 'blue', ...
     'BackgroundColor', 'white');
text(3.5, zone_y_pos, 'ZONE 2: Convex Mountain', 'HorizontalAlignment', 'center', ...
     'FontSize', 11, 'FontWeight', 'bold', 'Color', 'red', ...
     'BackgroundColor', 'white');
text(5.5, zone_y_pos, 'ZONE 3: Undulations', 'HorizontalAlignment', 'center', ...
     'FontSize', 11, 'FontWeight', 'bold', 'Color', 'green', ...
     'BackgroundColor', 'white');
text(7, zone_y_pos, 'FLAT ZONE', 'HorizontalAlignment', 'center', ...
     'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.8, 0.6, 0], ...
     'BackgroundColor', 'white');

% Add point representations and zone info below x-axis
annotation_y = -0.12; % Relative position below x-axis

% Add terrain symbols and zone info
for i = 1:7
    % Add terrain symbol
    text(i, annotation_y, terrain_symbols{i}, 'HorizontalAlignment', 'center', ...
         'FontSize', 13, 'Units', 'normalized', 'FontWeight', 'bold', ...
         'BackgroundColor', 'white');
    
    % Add zone information
    text(i, annotation_y - 0.06, point_zones{i}, 'HorizontalAlignment', 'center', ...
         'FontSize', 10, 'Units', 'normalized', 'Color', [0.4, 0.4, 0.4], ...
         'FontWeight', 'bold', 'BackgroundColor', 'white');
end

% Ensure all plot elements are properly layered
uistack(h1, 'top');
uistack(h2, 'top');

% Print detailed summary
fprintf('\n=== DUAL-AXIS INDEX COMPARISON (7 POINTS) - IMPROVED ===\n');
fprintf('%-15s | %-10s | %-10s | %-15s | %s\n', 'Point', 'RPI', 'TWI', 'Terrain Feature', 'Zone');
fprintf('%-15s | %-10s | %-10s | %-15s | %s\n', repmat('-', 1, 15), repmat('-', 1, 10), repmat('-', 1, 10), repmat('-', 1, 15), repmat('-', 1, 20));
features = {'Crater Min', 'Crater Curv', 'Mountain Max', 'Mountain Curv', 'Wave Max', 'Wave Min', 'Flat Ref'};
zones = {'Zone 1', 'Zone 1', 'Zone 2', 'Zone 2', 'Zone 3', 'Zone 3', 'Flat Zone'};
for i = 1:7
    fprintf('%-15s | %10.3f | %10.3f | %-15s | %s\n', ...
            point_labels{i}, rpi_values_vector(i), TWI_values_vector(i), features{i}, zones{i});
end

% Add instructions for saving high-quality figure
fprintf('\n=== TIPS FOR HIGH-QUALITY OUTPUT ===\n');
fprintf('To save as high-resolution image:\n');
fprintf('  print(gcf, ''topographic_comparison.png'', ''-dpng'', ''-r600'');\n');
fprintf('To save as vector format:\n');
fprintf('  print(gcf, ''topographic_comparison.eps'', ''-depsc'', ''-r600'');\n');
exportgraphics(gcf, 'Metrics_INDEX.png', 'Resolution', 600)
end