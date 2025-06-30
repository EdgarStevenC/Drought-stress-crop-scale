function flowAcc = computeFlowAccumulation2(Zgrid)
% COMPUTEFLOWACCUMULATION - Approximate flow accumulation based on inverse slope magnitude.
%   flowAcc = computeFlowAccumulation(Zgrid)
% 
%   Inputs:
%       Zgrid   - 2D matrix of terrain elevation values
%
%   Output:
%       flowAcc - 2D matrix (same size as Zgrid) with normalized accumulation values [0, 1]
%
%   Note:
%       This is a simple D8-like proxy. Flat or concave regions accumulate more "flow".

    % Compute slope magnitude
    [dzdx, dzdy] = gradient(Zgrid);
    slope_mag = sqrt(dzdx.^2 + dzdy.^2);

    % Inverse of slope: flatter areas = more accumulation
    flowAcc = 1 ./ (slope_mag + eps);  % eps avoids division by zero

    % Optional: smooth to reduce noise
    flowAcc = imgaussfilt(flowAcc, 2);

    % Normalize to [0, 1]
    %flowAcc = rescale(flowAcc);
end
