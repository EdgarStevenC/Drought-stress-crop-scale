function [rpi_values, twi_values] = getStrategicPointsFixed(RPI, TWI, Xgrid, Ygrid)
% Coordenadas exactas que verificaste manualmente
exact_indices = [
    51, 150;   % P1: RPI = -1.36
    65, 163;   % P2: RPI = 0.10  
    102, 155;  % P3: RPI = -0.495
    99, 155;   % P4: RPI = +0.421
    164, 63;   % P5: RPI = +0.098
    150, 51;   % P6: RPI = -1.359
    175, 151;  % P7: Slope (approximate)
    51, 75     % P8: Flat (approximate)
];

% Extraer valores directamente
rpi_values = zeros(8, 1);
twi_values = zeros(8, 1);
for i = 1:8
    row = exact_indices(i, 1);
    col = exact_indices(i, 2);
    rpi_values(i) = RPI(row, col);
    twi_values(i) = TWI(row, col);
end

% Mostrar valores
point_names = {'P1_crater_min', 'P2_crater_curv', 'P3_mountain_max', 'P4_mountain_curv', ...
               'P5_wave_max', 'P6_wave_min', 'P7_slope_strong', 'P8_flat_ref'};
fprintf('=== VALORES EXTRAÍDOS ===\n');
for i = 1:8
    fprintf('%s [%d,%d]: RPI=%.3f, TWI=%.3f\n', point_names{i}, ...
            exact_indices(i,1), exact_indices(i,2), rpi_values(i), twi_values(i));
end
end