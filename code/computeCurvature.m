function curvature = computeCurvature(Z)
% COMPUTECURVATURE - Estimate terrain curvature from elevation grid
%
% INPUT:
%   Z - Elevation grid (Zgrid)
%
% OUTPUT:
%   curvature - Grid of curvature values (positive = convex, negative = concave)

    % Compute derivatives
    [dzdx, dzdy] = gradient(Z);
    [d2zdx2, ~] = gradient(dzdx);
    [~, d2zdy2] = gradient(dzdy);

    % Curvature as sum of second partial derivatives (Laplacian)
    curvature = d2zdx2 + d2zdy2;

    % Optional smoothing (useful for artificial or noisy DEMs)
    curvature = imgaussfilt(curvature, 1);
    
    curvature = -del2(Z);  % del2 MATLAB --> ∇²Z
    % discrete approximation of Laplace's differential operator applied to Z

end
