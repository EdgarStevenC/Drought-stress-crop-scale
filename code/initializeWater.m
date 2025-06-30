function W = initializeWater(Zgrid, Zmin, dz, Z_offset, numDrops)
% initializeWater: creates water volume with drops centered (Gaussian) over valid terrain
% Inputs:
%   Zgrid     - terrain grid (MxN), NaNs for outside
%   Zmin      - minimum elevation
%   dz        - vertical resolution
%   Z_offset  - height above max terrain
%   numDrops  - number of drops to insert
% Output:
%   W         - 3D water matrix (MxNxZ)

    [rows, cols] = size(Zgrid);
    Zmax = max(Zgrid(:), [], 'omitnan');
    Z_real = Zmax + Z_offset;
    z_max = ceil((Z_real - Zmin) / dz) + 1;
    W = zeros(rows, cols, z_max);
    z_air_index = round((Z_real - Zmin) / dz) + 1;

    % === VALID TERRAIN MASK ===
    validMask = ~isnan(Zgrid);

    % === CREATE 2D GAUSSIAN WEIGHT MASK ===
    [X, Y] = meshgrid(1:cols, 1:rows);
    cx = cols / 2;
    cy = rows / 2;
    sigma = min(rows, cols) / 4;  % controls spread
    G = exp(-((X - cx).^2 + (Y - cy).^2) / (2 * sigma^2));
    G(~validMask) = 0;  % exclude outside area
    P = G / sum(G(:));  % normalize to sum 1

    % === RANDOM SAMPLING BASED ON PROBABILITY MAP ===
    P_flat = P(:);
    cumP = cumsum(P_flat);
    r = rand(numDrops,1);
    selectedIdx = arrayfun(@(x) find(cumP >= x, 1, 'first'), r);
    [ix, iy] = ind2sub([rows, cols], selectedIdx);

    % === PLACE DROPS ===
    for k = 1:numDrops
        W(ix(k), iy(k), z_air_index) = 1.0;
    end
end
