function saveCurrentFrameWithWaterMM(W, dz, Xgrid, Ygrid, t, outputDir)
% saveCurrentFrameWithWaterMM: saves current figure with water volume in mm in title
% Inputs:
%   W         - 3D binary water matrix
%   dz        - vertical resolution (m)
%   Xgrid, Ygrid - spatial grid (same size as terrain)
%   t         - current time step
%   outputDir - folder to save images

    % Compute total water in millimeters (per m²)
    total_mm = 1000 * dz * sum(W(:)) / numel(Xgrid);

    % Update title of current figure
    title(sprintf('Step %d | Water Volume = %.2f mm', t, total_mm), 'FontSize', 12);

    % Save current figure
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    filename = fullfile(outputDir, sprintf('frame_%04d.png', t));
    saveas(gcf, filename);
end
