function [pcXYZ] = createTerrain_RPI_vs_TWI()
% CREATETERRAIN_RPI_VS_TWI
% Creates realistic agricultural terrain to highlight RPI vs TWI differences
% 4 zones with realistic agricultural scales

% Grid size - higher resolution for microtopography
nx = 400; ny = 400;
[Xgrid, Ygrid] = meshgrid(linspace(0, 1000, nx), linspace(0, 1000, ny)); % 1km x 1km field
Zgrid = zeros(ny, nx);

% ==== ZONA 1: REGIÓN CÓNCAVA (LOWLAND) - ACUMULACIÓN ====
% Depresión gaussiana EXTREMA como cráter
zone1 = Xgrid <= 500 & Ygrid >= 500; % Top-left
base_elevation_z1 = 100.0; % meters
Zgrid(zone1) = base_elevation_z1;

% Depresión gaussiana EXTREMA tipo cráter/valle profundo
center_x1 = 250; % Centro de la zona 1
center_y1 = 750; % Centro de la zona 1
gaussian_width = 40; % 40m ancho (SÚPER ESTRECHO = montañoso)
max_depth = 2.0; % 2 METROS profundidad (como cráter)

% Crear depresión gaussiana EXTREMA
dist_from_center1 = sqrt((Xgrid - center_x1).^2 + (Ygrid - center_y1).^2);
gaussian_depression = max_depth * exp(-(dist_from_center1.^2) / (gaussian_width^2));
Zgrid(zone1) = Zgrid(zone1) - gaussian_depression(zone1);

% ==== ZONA 2: REGIÓN CONVEXA (UPLAND) - ESCORRENTÍA ====
% Elevación gaussiana EXTREMA como montaña
zone2 = Xgrid > 500 & Ygrid >= 500; % Top-right
base_elevation_z2 = 100.0; % Misma base que zona 1
Zgrid(zone2) = base_elevation_z2;

% Elevación gaussiana EXTREMA tipo montaña/volcán
center_x2 = 750; % Centro de la zona 2
center_y2 = 750; % Centro de la zona 2
gaussian_width2 = 40; % 40m ancho (SÚPER ESTRECHO = montañoso)
max_height = 2.0; % 2 METROS altura (como montaña)

% Crear elevación gaussiana EXTREMA
dist_from_center2 = sqrt((Xgrid - center_x2).^2 + (Ygrid - center_y2).^2);
gaussian_elevation = max_height * exp(-(dist_from_center2.^2) / (gaussian_width2^2));
Zgrid(zone2) = Zgrid(zone2) + gaussian_elevation(zone2);

% ==== ZONA 3: TERRENO PLANO "PERFECTO" ====
% Para mostrar dónde TWI da valores extremos/inútiles
zone3 = Xgrid <= 500 & Ygrid < 500; % Bottom-left
Zgrid(zone3) = 100.2; % 20 cm más alto que zona 1

% Solo ondulaciones limpias (sin ruido ni depresiones)
wave_amplitude = 0.3; % 30 cm amplitud (rango ±30 cm = 60 cm total)
wave_length_x = 200; % 200m longitud de onda en X
wave_length_y = 150; % 150m longitud de onda en Y

% Ondulaciones muy suaves tipo senoidal - patrón limpio
wave_pattern = wave_amplitude * sin(2*pi*Xgrid/wave_length_x) .* cos(2*pi*Ygrid/wave_length_y);
Zgrid(zone3) = Zgrid(zone3) + wave_pattern(zone3);

% ==== ZONA 4: PENDIENTE PRONUNCIADA ====
% Donde TWI funciona bien (referencia)
zone4 = Xgrid > 500 & Ygrid < 500; % Bottom-right
% Pendiente más fuerte pero realista
Zgrid(zone4) = 100.0 + 2.0 * (Xgrid(zone4) - 500) / 500 + 1.5 * (500 - Ygrid(zone4)) / 500;

% Agregar canal de drenaje realista
channel_y = 250 - 200 * (Xgrid - 500) / 500; % Canal diagonal
channel_condition = abs(Ygrid - channel_y) < 15; % 30m wide channel
channel_mask = channel_condition & zone4;
Zgrid(channel_mask) = Zgrid(channel_mask) - 0.8; % 80 cm deep channel

% Suavizado mínimo para evitar artefactos
Zgrid = imgaussfilt(Zgrid, 1.0); % Light smoothing

% Output como point cloud
pcXYZ = [Xgrid(:), Ygrid(:), Zgrid(:)];

% ==== VISUALIZACIÓN MEJORADA ====
figure('Position', [50, 50, 1400, 600]);

% Subplot 1: Vista 3D con escala vertical exagerada
subplot(2, 3, 1);
% Escalar coordenadas para mejor visualización 3D
X_scaled = pcXYZ(:,1) / 1000; % Convertir a km
Y_scaled = pcXYZ(:,2) / 1000; % Convertir a km
Z_scaled = (pcXYZ(:,3) - min(pcXYZ(:,3))) * 50; % Exagerar altura x50

scatter3(X_scaled, Y_scaled, Z_scaled, 2, pcXYZ(:,3), 'filled');
title('Terreno Agrícola (Escala Vertical Exagerada x50)');
xlabel('X (km)'); ylabel('Y (km)'); zlabel('Altura Relativa (m × 50)');
axis equal; grid on; view(45, 30);
colormap(gca, turbo); colorbar;

% Agregar etiquetas de zonas
text(0.25, 0.75, max(Z_scaled)*0.8, 'Z1: CRÁTER (∇²z>>>0)', 'FontSize', 9, 'Color', 'red', 'FontWeight', 'bold');
text(0.75, 0.75, max(Z_scaled)*0.8, 'Z2: MONTAÑA (∇²z<<<0)', 'FontSize', 9, 'Color', 'red', 'FontWeight', 'bold');
text(0.25, 0.25, max(Z_scaled)*0.8, 'Z3: Ondulaciones', 'FontSize', 9, 'Color', 'red', 'FontWeight', 'bold');
text(0.75, 0.25, max(Z_scaled)*0.8, 'Z4: Pendiente Fuerte', 'FontSize', 9, 'Color', 'red', 'FontWeight', 'bold');

% Subplot 2: Vista superior con contornos (escala en km)
subplot(2, 3, 2);
Z_reshaped = reshape(pcXYZ(:,3), ny, nx);
X_km = Xgrid / 1000; % Convertir a km
Y_km = Ygrid / 1000; % Convertir a km
contourf(X_km, Y_km, Z_reshaped, 20);
colorbar; colormap(gca, turbo);
title('Mapa de Elevación con Contornos');
xlabel('X (km)'); ylabel('Y (km)');
axis equal tight;

% Subplot 3: Perfil transversal (escala en km)
subplot(2, 3, 3);
mid_row = round(ny/2);
profile_x = Xgrid(mid_row, :) / 1000; % Convertir a km
profile_z = Z_reshaped(mid_row, :);
plot(profile_x, profile_z, 'b-', 'LineWidth', 2);
title('Perfil Transversal (Y = 0.5 km)');
xlabel('X (km)'); ylabel('Elevación (m)');
grid on;
ylim([min(profile_z)-0.1, max(profile_z)+0.1]);

% Subplot 4: Histograma de elevaciones
subplot(2, 3, 4);
histogram(pcXYZ(:,3), 50, 'FaceColor', 'blue', 'FaceAlpha', 0.7);
title('Distribución de Elevaciones');
xlabel('Elevación (m)'); ylabel('Frecuencia');
grid on;

% Subplot 5: Gradiente de pendientes (escala en km)
subplot(2, 3, 5);
[Gx, Gy] = gradient(Z_reshaped, 1000/nx, 1000/ny); % metros
slope_magnitude = sqrt(Gx.^2 + Gy.^2) * 100; % en porcentaje
X_km = Xgrid / 1000;
Y_km = Ygrid / 1000;
imagesc(X_km(1,:), Y_km(:,1), slope_magnitude);
colorbar; colormap(gca, hot);
title('Mapa de Pendientes (%)');
xlabel('X (km)'); ylabel('Y (km)');
axis equal tight;

% Subplot 6: Zoom a zona de microtopografía
subplot(2, 3, 6);
zoom_x_range = 50:150;  % Zona 1
zoom_y_range = 250:350; % Zona 1
zoom_Z = Z_reshaped(zoom_y_range, zoom_x_range);
zoom_X = Xgrid(zoom_y_range, zoom_x_range) / 1000; % km
zoom_Y = Ygrid(zoom_y_range, zoom_x_range) / 1000; % km
imagesc(zoom_X(1,:), zoom_Y(:,1), zoom_Z);
colorbar; colormap(gca, turbo);
title('Zoom: Zona 1 - Microtopografía');
xlabel('X (km)'); ylabel('Y (km)');
axis equal tight;

% ==== EXTRACCIÓN DE PUNTOS ESTRATÉGICOS ====

% Crear máscaras de zona como vectores lineales
zone1_mask = reshape(zone1, [], 1);
zone2_mask = reshape(zone2, [], 1);
zone3_mask = reshape(zone3, [], 1);
zone4_mask = reshape(zone4, [], 1);

fprintf('\n=== COORDENADAS DE PUNTOS ESTRATÉGICOS ===\n');

% ZONA 1: Depresión cóncava extrema
fprintf('\n--- ZONA 1: DEPRESIÓN CÓNCAVA ---\n');
% Punto 1: Mínimo absoluto (centro del cráter)
[min_val_z1, min_idx_z1] = min(pcXYZ(zone1_mask, 3));
min_coords_z1 = pcXYZ(find(pcXYZ(:,3) == min_val_z1, 1), :);
fprintf('Punto 1 - Mínimo del cráter: X=%.1fm, Y=%.1fm, Z=%.3fm\n', min_coords_z1(1), min_coords_z1(2), min_coords_z1(3));

% Punto 2: Máxima curvatura (borde del cráter, ~1.5 desviaciones estándar del centro)
target_dist_z1 = gaussian_width * 1.5; % ~60m del centro
center_z1 = [center_x1, center_y1];
border_candidates_z1 = [];
for i = 1:length(pcXYZ)
    if zone1_mask(i)
        dist_to_center = sqrt((pcXYZ(i,1) - center_z1(1))^2 + (pcXYZ(i,2) - center_z1(2))^2);
        if abs(dist_to_center - target_dist_z1) < 5 % Tolerancia de 5m
            border_candidates_z1 = [border_candidates_z1; pcXYZ(i,:)];
        end
    end
end
if ~isempty(border_candidates_z1)
    border_z1 = border_candidates_z1(1,:); % Tomar el primero
    fprintf('Punto 2 - Máx curvatura cráter: X=%.1fm, Y=%.1fm, Z=%.3fm\n', border_z1(1), border_z1(2), border_z1(3));
end

% ZONA 2: Elevación convexa extrema
fprintf('\n--- ZONA 2: ELEVACIÓN CONVEXA ---\n');
% Punto 3: Máximo absoluto (cima de la montaña)
[max_val_z2, max_idx_z2] = max(pcXYZ(zone2_mask, 3));
max_coords_z2 = pcXYZ(find(pcXYZ(:,3) == max_val_z2, 1), :);
fprintf('Punto 3 - Máximo de montaña: X=%.1fm, Y=%.1fm, Z=%.3fm\n', max_coords_z2(1), max_coords_z2(2), max_coords_z2(3));

% Punto 4: Máxima curvatura (base de la montaña)
target_dist_z2 = gaussian_width2 * 1.5; % ~60m del centro
center_z2 = [center_x2, center_y2];
border_candidates_z2 = [];
for i = 1:length(pcXYZ)
    if zone2_mask(i)
        dist_to_center = sqrt((pcXYZ(i,1) - center_z2(1))^2 + (pcXYZ(i,2) - center_z2(2))^2);
        if abs(dist_to_center - target_dist_z2) < 5 % Tolerancia de 5m
            border_candidates_z2 = [border_candidates_z2; pcXYZ(i,:)];
        end
    end
end
if ~isempty(border_candidates_z2)
    border_z2 = border_candidates_z2(1,:); % Tomar el primero
    fprintf('Punto 4 - Máx curvatura montaña: X=%.1fm, Y=%.1fm, Z=%.3fm\n', border_z2(1), border_z2(2), border_z2(3));
end

% ZONA 3: Ondulaciones regulares
fprintf('\n--- ZONA 3: ONDULACIONES REGULARES ---\n');
% Punto 5: Máximo de ondulación
z3_data = pcXYZ(zone3_mask, :);
[max_val_z3, max_idx_z3] = max(z3_data(:, 3));
max_coords_z3 = z3_data(max_idx_z3, :);
fprintf('Punto 5 - Máximo ondulación: X=%.1fm, Y=%.1fm, Z=%.3fm\n', max_coords_z3(1), max_coords_z3(2), max_coords_z3(3));

% Punto 6: Mínimo de ondulación
[min_val_z3, min_idx_z3] = min(z3_data(:, 3));
min_coords_z3 = z3_data(min_idx_z3, :);
fprintf('Punto 6 - Mínimo ondulación: X=%.1fm, Y=%.1fm, Z=%.3fm\n', min_coords_z3(1), min_coords_z3(2), min_coords_z3(3));

% ZONA 4: Pendiente pronunciada
fprintf('\n--- ZONA 4: PENDIENTE PRONUNCIADA ---\n');
% Punto 7: Punto representativo de pendiente fuerte (zona media-alta)
z4_data = pcXYZ(zone4_mask, :);
% Buscar punto en la parte alta de la pendiente (75% del rango Y en zona 4)
target_y_z4 = 125; % 25% desde abajo en zona 4 (0-500m Y)
candidates_z4 = z4_data(abs(z4_data(:,2) - target_y_z4) < 25, :); % ±25m tolerancia
if ~isempty(candidates_z4)
    slope_point_z4 = candidates_z4(round(end/2), :); % Punto medio
    fprintf('Punto 7 - Pendiente fuerte: X=%.1fm, Y=%.1fm, Z=%.3fm\n', slope_point_z4(1), slope_point_z4(2), slope_point_z4(3));
end

% ZONA PLANA (elegir zona 1 área plana)
fprintf('\n--- ZONA PLANA (REFERENCIA) ---\n');
% Punto 8: Punto plano alejado de características extremas (zona 1, área base)
target_dist_flat = gaussian_width * 3; % 120m del centro del cráter (área relativamente plana)
flat_candidates = [];
for i = 1:length(pcXYZ)
    if zone1_mask(i)
        dist_to_center = sqrt((pcXYZ(i,1) - center_z1(1))^2 + (pcXYZ(i,2) - center_z1(2))^2);
        if abs(dist_to_center - target_dist_flat) < 10 % Tolerancia de 10m
            flat_candidates = [flat_candidates; pcXYZ(i,:)];
        end
    end
end
if ~isempty(flat_candidates)
    flat_point = flat_candidates(end,:); % Tomar el primero
    flat_point = [492.462, 572.864, 100];
    fprintf('Punto 8 - Zona plana: X=%.1fm, Y=%.1fm, Z=%.3fm\n', flat_point(1), flat_point(2), flat_point(3));
end

% Resumen de coordenadas para fácil copia
fprintf('\n=== RESUMEN DE COORDENADAS (X, Y, Z) ===\n');
fprintf('P1_crater_min: [%.1f, %.1f, %.3f]\n', min_coords_z1(1), min_coords_z1(2), min_coords_z1(3));
if exist('border_z1', 'var')
    fprintf('P2_crater_curv: [%.1f, %.1f, %.3f]\n', border_z1(1), border_z1(2), border_z1(3));
end
fprintf('P3_mountain_max: [%.1f, %.1f, %.3f]\n', max_coords_z2(1), max_coords_z2(2), max_coords_z2(3));
if exist('border_z2', 'var')
    fprintf('P4_mountain_curv: [%.1f, %.1f, %.3f]\n', border_z2(1), border_z2(2), border_z2(3));
end
fprintf('P5_wave_max: [%.1f, %.1f, %.3f]\n', max_coords_z3(1), max_coords_z3(2), max_coords_z3(3));
fprintf('P6_wave_min: [%.1f, %.1f, %.3f]\n', min_coords_z3(1), min_coords_z3(2), min_coords_z3(3));
if exist('slope_point_z4', 'var')
    fprintf('P7_slope_strong: [%.1f, %.1f, %.3f]\n', slope_point_z4(1), slope_point_z4(2), slope_point_z4(3));
end
if exist('flat_point', 'var')
    fprintf('P8_flat_ref: [%.1f, %.1f, %.3f]\n', flat_point(1), flat_point(2), flat_point(3));
end

end

% function [pcXYZ] = createTerrain_RPI_vs_TWI()
% % CREATETERRAIN_RPI_VS_TWI
% % Creates realistic agricultural terrain to highlight RPI vs TWI differences
% % 4 zones with realistic agricultural scales
% 
% % Grid size - higher resolution for microtopography
% nx = 400; ny = 400;
% [Xgrid, Ygrid] = meshgrid(linspace(0, 1000, nx), linspace(0, 1000, ny)); % 1km x 1km field
% Zgrid = zeros(ny, nx);
% 
% % ==== ZONA 1: REGIÓN CÓNCAVA (LOWLAND) - ACUMULACIÓN ====
% % Depresión gaussiana EXTREMA como cráter
% zone1 = Xgrid <= 500 & Ygrid >= 500; % Top-left
% base_elevation_z1 = 100.0; % meters
% Zgrid(zone1) = base_elevation_z1;
% 
% % Depresión gaussiana EXTREMA tipo cráter/valle profundo
% center_x1 = 250; % Centro de la zona 1
% center_y1 = 750; % Centro de la zona 1
% gaussian_width = 40; % 40m ancho (SÚPER ESTRECHO = montañoso)
% max_depth = 2.0; % 2 METROS profundidad (como cráter)
% 
% % Crear depresión gaussiana EXTREMA
% dist_from_center1 = sqrt((Xgrid - center_x1).^2 + (Ygrid - center_y1).^2);
% gaussian_depression = max_depth * exp(-(dist_from_center1.^2) / (gaussian_width^2));
% Zgrid(zone1) = Zgrid(zone1) - gaussian_depression(zone1);
% 
% % ==== ZONA 2: REGIÓN CONVEXA (UPLAND) - ESCORRENTÍA ====
% % Elevación gaussiana EXTREMA como montaña
% zone2 = Xgrid > 500 & Ygrid >= 500; % Top-right
% base_elevation_z2 = 100.0; % Misma base que zona 1
% Zgrid(zone2) = base_elevation_z2;
% 
% % Elevación gaussiana EXTREMA tipo montaña/volcán
% center_x2 = 750; % Centro de la zona 2
% center_y2 = 750; % Centro de la zona 2
% gaussian_width2 = 40; % 40m ancho (SÚPER ESTRECHO = montañoso)
% max_height = 2.0; % 2 METROS altura (como montaña)
% 
% % Crear elevación gaussiana EXTREMA
% dist_from_center2 = sqrt((Xgrid - center_x2).^2 + (Ygrid - center_y2).^2);
% gaussian_elevation = max_height * exp(-(dist_from_center2.^2) / (gaussian_width2^2));
% Zgrid(zone2) = Zgrid(zone2) + gaussian_elevation(zone2);
% 
% % ==== ZONA 3: TERRENO PLANO "PERFECTO" ====
% % Para mostrar dónde TWI da valores extremos/inútiles
% zone3 = Xgrid <= 500 & Ygrid < 500; % Bottom-left
% Zgrid(zone3) = 100.2; % 20 cm más alto que zona 1
% 
% % Solo ondulaciones limpias (sin ruido ni depresiones)
% wave_amplitude = 0.3; % 30 cm amplitud (rango ±30 cm = 60 cm total)
% wave_length_x = 200; % 200m longitud de onda en X
% wave_length_y = 150; % 150m longitud de onda en Y
% 
% % Ondulaciones muy suaves tipo senoidal - patrón limpio
% wave_pattern = wave_amplitude * sin(2*pi*Xgrid/wave_length_x) .* cos(2*pi*Ygrid/wave_length_y);
% Zgrid(zone3) = Zgrid(zone3) + wave_pattern(zone3);
% 
% % ==== ZONA 4: PENDIENTE PRONUNCIADA ====
% % Donde TWI funciona bien (referencia)
% zone4 = Xgrid > 500 & Ygrid < 500; % Bottom-right
% % Pendiente más fuerte pero realista
% Zgrid(zone4) = 100.0 + 2.0 * (Xgrid(zone4) - 500) / 500 + 1.5 * (500 - Ygrid(zone4)) / 500;
% 
% % Agregar canal de drenaje realista
% channel_y = 250 - 200 * (Xgrid - 500) / 500; % Canal diagonal
% channel_condition = abs(Ygrid - channel_y) < 15; % 30m wide channel
% channel_mask = channel_condition & zone4;
% Zgrid(channel_mask) = Zgrid(channel_mask) - 0.8; % 80 cm deep channel
% 
% % Suavizado mínimo para evitar artefactos
% Zgrid = imgaussfilt(Zgrid, 1.0); % Light smoothing
% 
% % Output como point cloud
% pcXYZ = [Xgrid(:), Ygrid(:), Zgrid(:)];
% 
% % ==== VISUALIZACIÓN MEJORADA ====
% figure('Position', [50, 50, 1400, 600]);
% 
% % Subplot 1: Vista 3D con escala vertical exagerada
% subplot(2, 3, 1);
% % Escalar coordenadas para mejor visualización 3D
% X_scaled = pcXYZ(:,1) / 1000; % Convertir a km
% Y_scaled = pcXYZ(:,2) / 1000; % Convertir a km
% Z_scaled = (pcXYZ(:,3) - min(pcXYZ(:,3))) * 50; % Exagerar altura x50
% 
% scatter3(X_scaled, Y_scaled, Z_scaled, 2, pcXYZ(:,3), 'filled');
% title('Terreno Agrícola (Escala Vertical Exagerada x50)');
% xlabel('X (km)'); ylabel('Y (km)'); zlabel('Altura Relativa (m × 50)');
% axis equal; grid on; view(45, 30);
% colormap(gca, turbo); colorbar;
% 
% % Agregar etiquetas de zonas
% text(0.25, 0.75, max(Z_scaled)*0.8, 'Z1: CRÁTER (∇²z>>>0)', 'FontSize', 9, 'Color', 'red', 'FontWeight', 'bold');
% text(0.75, 0.75, max(Z_scaled)*0.8, 'Z2: MONTAÑA (∇²z<<<0)', 'FontSize', 9, 'Color', 'red', 'FontWeight', 'bold');
% text(0.25, 0.25, max(Z_scaled)*0.8, 'Z3: Ondulaciones', 'FontSize', 9, 'Color', 'red', 'FontWeight', 'bold');
% text(0.75, 0.25, max(Z_scaled)*0.8, 'Z4: Pendiente Fuerte', 'FontSize', 9, 'Color', 'red', 'FontWeight', 'bold');
% 
% % Subplot 2: Vista superior con contornos (escala en km)
% subplot(2, 3, 2);
% Z_reshaped = reshape(pcXYZ(:,3), ny, nx);
% X_km = Xgrid / 1000; % Convertir a km
% Y_km = Ygrid / 1000; % Convertir a km
% contourf(X_km, Y_km, Z_reshaped, 20);
% colorbar; colormap(gca, turbo);
% title('Mapa de Elevación con Contornos');
% xlabel('X (km)'); ylabel('Y (km)');
% axis equal tight;
% 
% % Subplot 3: Perfil transversal (escala en km)
% subplot(2, 3, 3);
% mid_row = round(ny/2);
% profile_x = Xgrid(mid_row, :) / 1000; % Convertir a km
% profile_z = Z_reshaped(mid_row, :);
% plot(profile_x, profile_z, 'b-', 'LineWidth', 2);
% title('Perfil Transversal (Y = 0.5 km)');
% xlabel('X (km)'); ylabel('Elevación (m)');
% grid on;
% ylim([min(profile_z)-0.1, max(profile_z)+0.1]);
% 
% % Subplot 4: Histograma de elevaciones
% subplot(2, 3, 4);
% histogram(pcXYZ(:,3), 50, 'FaceColor', 'blue', 'FaceAlpha', 0.7);
% title('Distribución de Elevaciones');
% xlabel('Elevación (m)'); ylabel('Frecuencia');
% grid on;
% 
% % Subplot 5: Gradiente de pendientes (escala en km)
% subplot(2, 3, 5);
% [Gx, Gy] = gradient(Z_reshaped, 1000/nx, 1000/ny); % metros
% slope_magnitude = sqrt(Gx.^2 + Gy.^2) * 100; % en porcentaje
% X_km = Xgrid / 1000;
% Y_km = Ygrid / 1000;
% imagesc(X_km(1,:), Y_km(:,1), slope_magnitude);
% colorbar; colormap(gca, hot);
% title('Mapa de Pendientes (%)');
% xlabel('X (km)'); ylabel('Y (km)');
% axis equal tight;
% 
% % Subplot 6: Zoom a zona de microtopografía
% subplot(2, 3, 6);
% zoom_x_range = 50:150;  % Zona 1
% zoom_y_range = 250:350; % Zona 1
% zoom_Z = Z_reshaped(zoom_y_range, zoom_x_range);
% zoom_X = Xgrid(zoom_y_range, zoom_x_range) / 1000; % km
% zoom_Y = Ygrid(zoom_y_range, zoom_x_range) / 1000; % km
% imagesc(zoom_X(1,:), zoom_Y(:,1), zoom_Z);
% colorbar; colormap(gca, turbo);
% title('Zoom: Zona 1 - Microtopografía');
% xlabel('X (km)'); ylabel('Y (km)');
% axis equal tight;
% 
% % Estadísticas del terreno
% zone1_mask = reshape(zone1, [], 1);
% zone2_mask = reshape(zone2, [], 1);
% zone3_mask = reshape(zone3, [], 1);
% zone4_mask = reshape(zone4, [], 1);
% 
% fprintf('\n=== ESTADÍSTICAS DEL TERRENO AGRÍCOLA ===\n');
% fprintf('Rango total de elevación: %.3f - %.3f metros\n', min(pcXYZ(:,3)), max(pcXYZ(:,3)));
% fprintf('Variación total: %.3f metros (%.0f cm)\n', range(pcXYZ(:,3)), range(pcXYZ(:,3))*100);
% fprintf('Zona 1 (microtopo): %.3f - %.3f m\n', min(pcXYZ(zone1_mask,3)), max(pcXYZ(zone1_mask,3)));
% fprintf('Zona 2 (pend+curv): %.3f - %.3f m\n', min(pcXYZ(zone2_mask,3)), max(pcXYZ(zone2_mask,3)));
% fprintf('Zona 3 (plano): %.3f - %.3f m\n', min(pcXYZ(zone3_mask,3)), max(pcXYZ(zone3_mask,3)));
% fprintf('Zona 4 (pend fuerte): %.3f - %.3f m\n', min(pcXYZ(zone4_mask,3)), max(pcXYZ(zone4_mask,3)));
% fprintf('Pendiente máxima: %.2f%%\n', max(slope_magnitude(:)));
% fprintf('Pendiente media Z1: %.3f%%\n', mean(slope_magnitude(reshape(zone1, ny, nx))));
% fprintf('Pendiente media Z2: %.3f%%\n', mean(slope_magnitude(reshape(zone2, ny, nx))));
% fprintf('Pendiente media Z3: %.3f%%\n', mean(slope_magnitude(reshape(zone3, ny, nx))));
% fprintf('Pendiente media Z4: %.3f%%\n', mean(slope_magnitude(reshape(zone4, ny, nx))));
% 
% end

%% init OK
% function [pcXYZ] = createTerrain_RPI_vs_TWI()
% % CREATETERRAIN_RPI_VS_TWI
% % Creates realistic agricultural terrain to highlight RPI vs TWI differences
% % 4 zones with realistic agricultural scales
% 
% % Grid size - higher resolution for microtopography
% nx = 400; ny = 400;
% [Xgrid, Ygrid] = meshgrid(linspace(0, 1000, nx), linspace(0, 1000, ny)); % 1km x 1km field
% Zgrid = zeros(ny, nx);
% 
% % ==== ZONA 1: TERRENO CASI PLANO CON MICROTOPOGRAFÍA ====
% % TWI fallará aquí (pendiente ~0), pero RPI detectará curvatura
% zone1 = Xgrid <= 500 & Ygrid >= 500; % Top-left
% base_elevation_z1 = 100.0; % meters
% Zgrid(zone1) = base_elevation_z1;
% 
% % Agregar depresiones y montículos realistas (20-80 cm)
% depression_centers = [150, 750; 350, 850; 250, 650]; % meters
% mound_centers = [200, 800; 400, 700; 300, 900]; % meters
% 
% for i = 1:size(depression_centers, 1)
%     cx = depression_centers(i, 1);
%     cy = depression_centers(i, 2);
%     radius = 40; % 40m radius
%     dist = sqrt((Xgrid - cx).^2 + (Ygrid - cy).^2);
%     mask = dist <= radius & zone1;
%     if any(mask(:))
%         depth = 0.5 * exp(-(dist.^2) / (radius/2)^2); % 50 cm max
%         Zgrid(mask) = Zgrid(mask) - depth(mask);
%     end
% end
% 
% for i = 1:size(mound_centers, 1)
%     cx = mound_centers(i, 1);
%     cy = mound_centers(i, 2);
%     radius = 30; % 30m radius
%     dist = sqrt((Xgrid - cx).^2 + (Ygrid - cy).^2);
%     mask = dist <= radius & zone1;
%     if any(mask(:))
%         height = 0.3 * exp(-(dist.^2) / (radius/2)^2); % 30 cm max
%         Zgrid(mask) = Zgrid(mask) + height(mask);
%     end
% end
% 
% % ==== ZONA 2: PENDIENTE MODERADA CON CURVATURA COMPLEJA ====
% % Aquí tanto TWI como RPI funcionan, pero muestran patrones diferentes
% zone2 = Xgrid > 500 & Ygrid >= 500; % Top-right
% % Pendiente gradual realista
% Zgrid(zone2) = 100.0 + 1.0 * (Xgrid(zone2) - 500) / 500; % Pendiente ~0.2% (1m en 500m)
% 
% % Agregar curvatura convergente y divergente
% conv_center = [750, 750]; % meters
% div_center = [850, 650]; % meters
% 
% % Zona convergente (como valle pequeño)
% conv_dist = sqrt((Xgrid - conv_center(1)).^2 + (Ygrid - conv_center(2)).^2);
% conv_mask = conv_dist <= 50 & zone2; % 50m radius
% if any(conv_mask(:))
%     conv_depth = 0.8 * exp(-(conv_dist.^2) / (30^2)); % 80 cm max depth
%     Zgrid(conv_mask) = Zgrid(conv_mask) - conv_depth(conv_mask);
% end
% 
% % Zona divergente (como colina pequeña)
% div_dist = sqrt((Xgrid - div_center(1)).^2 + (Ygrid - div_center(2)).^2);
% div_mask = div_dist <= 40 & zone2; % 40m radius
% if any(div_mask(:))
%     div_height = 0.6 * exp(-(div_dist.^2) / (25^2)); % 60 cm max height
%     Zgrid(div_mask) = Zgrid(div_mask) + div_height(div_mask);
% end
% 
% % ==== ZONA 3: TERRENO PLANO "PERFECTO" ====
% % Para mostrar dónde TWI da valores extremos/inútiles
% zone3 = Xgrid <= 500 & Ygrid < 500; % Bottom-left
% Zgrid(zone3) = 100.2; % 20 cm más alto que zona 1
% 
% % Solo ondulaciones limpias (sin ruido ni depresiones)
% wave_amplitude = 0.3; % 30 cm amplitud (rango ±30 cm = 60 cm total)
% wave_length_x = 200; % 200m longitud de onda en X
% wave_length_y = 150; % 150m longitud de onda en Y
% 
% % Ondulaciones muy suaves tipo senoidal - patrón limpio
% wave_pattern = wave_amplitude * sin(2*pi*Xgrid/wave_length_x) .* cos(2*pi*Ygrid/wave_length_y);
% Zgrid(zone3) = Zgrid(zone3) + wave_pattern(zone3);
% 
% % ==== ZONA 4: PENDIENTE PRONUNCIADA ====
% % Donde TWI funciona bien (referencia)
% zone4 = Xgrid > 500 & Ygrid < 500; % Bottom-right
% % Pendiente más fuerte pero realista
% Zgrid(zone4) = 100.0 + 2.0 * (Xgrid(zone4) - 500) / 500 + 1.5 * (500 - Ygrid(zone4)) / 500;
% 
% % Agregar canal de drenaje realista
% channel_y = 250 - 200 * (Xgrid - 500) / 500; % Canal diagonal
% channel_condition = abs(Ygrid - channel_y) < 15; % 30m wide channel
% channel_mask = channel_condition & zone4;
% Zgrid(channel_mask) = Zgrid(channel_mask) - 0.8; % 80 cm deep channel
% 
% % Suavizado mínimo para evitar artefactos
% Zgrid = imgaussfilt(Zgrid, 1.0); % Light smoothing
% 
% % Output como point cloud
% pcXYZ = [Xgrid(:), Ygrid(:), Zgrid(:)];
% 
% % ==== VISUALIZACIÓN MEJORADA ====
% figure('Position', [50, 50, 1400, 600]);
% 
% % Subplot 1: Vista 3D con escala vertical exagerada
% subplot(2, 3, 1);
% % Escalar coordenadas para mejor visualización 3D
% X_scaled = pcXYZ(:,1) / 1000; % Convertir a km
% Y_scaled = pcXYZ(:,2) / 1000; % Convertir a km
% Z_scaled = (pcXYZ(:,3) - min(pcXYZ(:,3))) * 50; % Exagerar altura x50
% 
% scatter3(X_scaled, Y_scaled, Z_scaled, 2, pcXYZ(:,3), 'filled');
% title('Terreno Agrícola (Escala Vertical Exagerada x50)');
% xlabel('X (km)'); ylabel('Y (km)'); zlabel('Altura Relativa (m × 50)');
% axis equal; grid on; view(45, 30);
% colormap(gca, turbo); colorbar;
% 
% % Agregar etiquetas de zonas
% text(0.25, 0.75, max(Z_scaled)*0.8, 'Z1: Plano + Micro', 'FontSize', 9, 'Color', 'red', 'FontWeight', 'bold');
% text(0.75, 0.75, max(Z_scaled)*0.8, 'Z2: Pendiente + Curvatura', 'FontSize', 9, 'Color', 'red', 'FontWeight', 'bold');
% text(0.25, 0.25, max(Z_scaled)*0.8, 'Z3: Plano Perfecto', 'FontSize', 9, 'Color', 'red', 'FontWeight', 'bold');
% text(0.75, 0.25, max(Z_scaled)*0.8, 'Z4: Pendiente Fuerte', 'FontSize', 9, 'Color', 'red', 'FontWeight', 'bold');
% 
% % Subplot 2: Vista superior con contornos (escala en km)
% subplot(2, 3, 2);
% Z_reshaped = reshape(pcXYZ(:,3), ny, nx);
% X_km = Xgrid / 1000; % Convertir a km
% Y_km = Ygrid / 1000; % Convertir a km
% contourf(X_km, Y_km, Z_reshaped, 20);
% colorbar; colormap(gca, turbo);
% title('Mapa de Elevación con Contornos');
% xlabel('X (km)'); ylabel('Y (km)');
% axis equal tight;
% 
% % Subplot 3: Perfil transversal (escala en km)
% subplot(2, 3, 3);
% mid_row = round(ny/2);
% profile_x = Xgrid(mid_row, :) / 1000; % Convertir a km
% profile_z = Z_reshaped(mid_row, :);
% plot(profile_x, profile_z, 'b-', 'LineWidth', 2);
% title('Perfil Transversal (Y = 0.5 km)');
% xlabel('X (km)'); ylabel('Elevación (m)');
% grid on;
% ylim([min(profile_z)-0.1, max(profile_z)+0.1]);
% 
% % Subplot 4: Histograma de elevaciones
% subplot(2, 3, 4);
% histogram(pcXYZ(:,3), 50, 'FaceColor', 'blue', 'FaceAlpha', 0.7);
% title('Distribución de Elevaciones');
% xlabel('Elevación (m)'); ylabel('Frecuencia');
% grid on;
% 
% % Subplot 5: Gradiente de pendientes (escala en km)
% subplot(2, 3, 5);
% [Gx, Gy] = gradient(Z_reshaped, 1000/nx, 1000/ny); % metros
% slope_magnitude = sqrt(Gx.^2 + Gy.^2) * 100; % en porcentaje
% X_km = Xgrid / 1000;
% Y_km = Ygrid / 1000;
% imagesc(X_km(1,:), Y_km(:,1), slope_magnitude);
% colorbar; colormap(gca, hot);
% title('Mapa de Pendientes (%)');
% xlabel('X (km)'); ylabel('Y (km)');
% axis equal tight;
% 
% % Subplot 6: Zoom a zona de microtopografía
% subplot(2, 3, 6);
% zoom_x_range = 50:150;  % Zona 1
% zoom_y_range = 250:350; % Zona 1
% zoom_Z = Z_reshaped(zoom_y_range, zoom_x_range);
% zoom_X = Xgrid(zoom_y_range, zoom_x_range) / 1000; % km
% zoom_Y = Ygrid(zoom_y_range, zoom_x_range) / 1000; % km
% imagesc(zoom_X(1,:), zoom_Y(:,1), zoom_Z);
% colorbar; colormap(gca, turbo);
% title('Zoom: Zona 1 - Microtopografía');
% xlabel('X (km)'); ylabel('Y (km)');
% axis equal tight;
% 
% % Estadísticas del terreno
% zone1_mask = reshape(zone1, [], 1);
% zone2_mask = reshape(zone2, [], 1);
% zone3_mask = reshape(zone3, [], 1);
% zone4_mask = reshape(zone4, [], 1);
% 
% fprintf('\n=== ESTADÍSTICAS DEL TERRENO AGRÍCOLA ===\n');
% fprintf('Rango total de elevación: %.3f - %.3f metros\n', min(pcXYZ(:,3)), max(pcXYZ(:,3)));
% fprintf('Variación total: %.3f metros (%.0f cm)\n', range(pcXYZ(:,3)), range(pcXYZ(:,3))*100);
% fprintf('Zona 1 (microtopo): %.3f - %.3f m\n', min(pcXYZ(zone1_mask,3)), max(pcXYZ(zone1_mask,3)));
% fprintf('Zona 2 (pend+curv): %.3f - %.3f m\n', min(pcXYZ(zone2_mask,3)), max(pcXYZ(zone2_mask,3)));
% fprintf('Zona 3 (plano): %.3f - %.3f m\n', min(pcXYZ(zone3_mask,3)), max(pcXYZ(zone3_mask,3)));
% fprintf('Zona 4 (pend fuerte): %.3f - %.3f m\n', min(pcXYZ(zone4_mask,3)), max(pcXYZ(zone4_mask,3)));
% fprintf('Pendiente máxima: %.2f%%\n', max(slope_magnitude(:)));
% fprintf('Pendiente media Z1: %.3f%%\n', mean(slope_magnitude(reshape(zone1, ny, nx))));
% fprintf('Pendiente media Z2: %.3f%%\n', mean(slope_magnitude(reshape(zone2, ny, nx))));
% fprintf('Pendiente media Z3: %.3f%%\n', mean(slope_magnitude(reshape(zone3, ny, nx))));
% fprintf('Pendiente media Z4: %.3f%%\n', mean(slope_magnitude(reshape(zone4, ny, nx))));
% 
% end
% 

%%
% % function [pcXYZ] = createTerrain_RPI_vs_TWI()
% % % CREATETERRAIN_RPI_VS_TWI
% % % Creates realistic agricultural terrain to highlight RPI vs TWI differences
% % % Focused on microtopography variations typical in crop fields
% % 
% % % Grid size - higher resolution for microtopography
% % nx = 400; ny = 400;
% % [Xgrid, Ygrid] = meshgrid(linspace(0, 1000, nx), linspace(0, 1000, ny)); % 1km x 1km field
% % Zgrid = zeros(ny, nx);
% % 
% % % ==== BASE TERRAIN: TWO MAIN ZONES WITH GAUSSIAN TRANSITION ====
% % 
% % % Zone masks (left half vs right half)
% % zone_flat_micro = Xgrid <= 500; % Left: flat with microtopography
% % zone_flat_perfect = Xgrid > 500;  % Right: perfectly flat
% % 
% % % ==== ZONA IZQUIERDA: TERRENO CASI PLANO CON MICROTOPOGRAFÍA ====
% % % Elevation: 100-102m (realistic agricultural field range)
% % base_elevation_left = 100.5; % meters
% % Zgrid(zone_flat_micro) = base_elevation_left;
% % 
% % % Microtopographic features typical in agricultural fields
% % % Small depressions (water retention areas)
% % depression_centers = [150, 750; 250, 600; 350, 800; 200, 500; 400, 650]; % meters
% % depression_depths = [0.4, 0.6, 0.3, 0.5, 0.4]; % 30-60 cm depth
% % depression_radii = [40, 50, 35, 45, 38]; % 35-50m radius
% % 
% % for i = 1:size(depression_centers, 1)
% %     cx = depression_centers(i, 1);
% %     cy = depression_centers(i, 2);
% %     radius = depression_radii(i);
% %     depth = depression_depths(i);
% % 
% %     dist = sqrt((Xgrid - cx).^2 + (Ygrid - cy).^2);
% %     mask = dist <= radius & zone_flat_micro;
% % 
% %     % Gaussian depression
% %     depression = depth * exp(-(dist.^2) / (radius/2)^2);
% %     Zgrid(mask) = Zgrid(mask) - depression(mask);
% % end
% % 
% % % Rice bed pattern - linear ridges (more realistic)
% % % Create parallel linear ridges
% % ridge_spacing = 60; % meters between ridge centers
% % ridge_width = 15;   % meters width of each ridge
% % ridge_height = 0.20; % 20 cm height
% % ridge_length = 600;  % meters length (covers most of the zone)
% % 
% % % Create parallel ridges running North-South (Y direction)
% % ridge_centers_x = 150:ridge_spacing:450; % X positions of ridge centers
% % 
% % for ridge_x = ridge_centers_x
% %     if ridge_x <= 500 % Only in microtopography zone
% %         % Create linear ridge running full length in Y direction
% %         x_dist = abs(Xgrid - ridge_x);
% % 
% %         % Ridge mask (linear strip)
% %         ridge_mask = (x_dist <= ridge_width/2) & zone_flat_micro;
% % 
% %         if any(ridge_mask(:))
% %             % Smooth cross-sectional profile (Gaussian)
% %             ridge_profile = ridge_height * exp(-(x_dist.^2) / (ridge_width/3)^2);
% %             Zgrid(ridge_mask) = Zgrid(ridge_mask) + ridge_profile(ridge_mask);
% %         end
% %     end
% % end
% % 
% % % Add minimal field drainage (very subtle)
% % drainage_spacing = 100; % meters (minimal drainage lines)
% % for y_center = 300:drainage_spacing:700
% %     drainage_mask = abs(Ygrid - y_center) < 1.5 & zone_flat_micro; % 3m wide, very subtle
% %     Zgrid(drainage_mask) = Zgrid(drainage_mask) - 0.03; % Only 3 cm depression
% % end
% % 
% % % ==== ZONA DERECHA: TERRENO PERFECTAMENTE PLANO ====
% % base_elevation_right = base_elevation_left + 0.20; % 20 cm más alto (igual que montículos)
% % Zgrid(zone_flat_perfect) = base_elevation_right;
% % 
% % % Add only minimal noise (measurement uncertainty level)
% % noise_std = 0.02; % 2 cm standard deviation
% % noise = noise_std * randn(sum(zone_flat_perfect(:)), 1);
% % Zgrid(zone_flat_perfect) = Zgrid(zone_flat_perfect) + reshape(noise, sum(zone_flat_perfect, 'all'), 1);
% % 
% % % ==== TRANSICIÓN GAUSSIANA FUERTE ENTRE ZONAS ====
% % transition_center = 500; % meters (center line)
% % transition_width = 50;   % meters (transition zone width)
% % 
% % % Create smooth transition with strong gradient
% % transition_zone = abs(Xgrid - transition_center) <= transition_width;
% % if any(transition_zone(:))
% %     % Gaussian transition from left elevation to right elevation
% %     elevation_diff = base_elevation_right - base_elevation_left;
% % 
% %     for i = 1:nx
% %         for j = 1:ny
% %             if transition_zone(j, i)
% %                 x_pos = Xgrid(j, i);
% %                 distance_from_center = x_pos - transition_center;
% % 
% %                 % Sigmoid transition (smoother than linear)
% %                 transition_factor = 0.5 + 0.5 * tanh(distance_from_center / (transition_width/4));
% % 
% %                 % Apply transition
% %                 left_elevation = Zgrid(j, i); % Already set values
% %                 target_elevation = base_elevation_left + elevation_diff * transition_factor;
% % 
% %                 % If we're in the left zone, keep microtopo + transition
% %                 if x_pos <= transition_center
% %                     micro_variation = Zgrid(j, i) - base_elevation_left;
% %                     Zgrid(j, i) = target_elevation + micro_variation * (1 - transition_factor);
% %                 else
% %                     Zgrid(j, i) = target_elevation;
% %                 end
% %             end
% %         end
% %     end
% % end
% % 
% % % Minimal smoothing to avoid artifacts but preserve microtopography
% % Zgrid = imgaussfilt(Zgrid, 0.8); % Very light smoothing
% % 
% % % Output como point cloud
% % pcXYZ = [Xgrid(:), Ygrid(:), Zgrid(:)];
% % 
% % % ==== VISUALIZACIÓN MEJORADA ====
% % figure('Position', [50, 50, 1400, 600]);
% % 
% % % Subplot 1: Vista 3D con escala vertical exagerada
% % subplot(2, 3, 1);
% % % Escalar coordenadas para mejor visualización 3D
% % X_scaled = pcXYZ(:,1) / 1000; % Convertir a km
% % Y_scaled = pcXYZ(:,2) / 1000; % Convertir a km
% % Z_scaled = (pcXYZ(:,3) - min(pcXYZ(:,3))) * 50; % Exagerar altura x50
% % 
% % scatter3(X_scaled, Y_scaled, Z_scaled, 2, pcXYZ(:,3), 'filled');
% % title('Terreno Agrícola (Escala Vertical Exagerada x50)');
% % xlabel('X (km)'); ylabel('Y (km)'); zlabel('Altura Relativa (m × 50)');
% % axis equal; grid on; view(45, 30);
% % colormap(gca, turbo); colorbar;
% % 
% % % Añadir texto explicativo
% % text(0.1, 0.8, max(Z_scaled)*0.8, 'Camas Lineales', 'FontSize', 10, 'Color', 'red', 'FontWeight', 'bold');
% % text(0.7, 0.8, max(Z_scaled)*0.8, 'Zona Plana', 'FontSize', 10, 'Color', 'red', 'FontWeight', 'bold');
% % 
% % % Subplot 2: Vista superior con contornos (escala en km)
% % subplot(2, 3, 2);
% % Z_reshaped = reshape(pcXYZ(:,3), ny, nx);
% % X_km = Xgrid / 1000; % Convertir a km
% % Y_km = Ygrid / 1000; % Convertir a km
% % contourf(X_km, Y_km, Z_reshaped, 20);
% % colorbar; colormap(gca, turbo);
% % title('Mapa de Elevación con Contornos');
% % xlabel('X (km)'); ylabel('Y (km)');
% % axis equal tight;
% % 
% % % Subplot 3: Perfil transversal (escala en km)
% % subplot(2, 3, 3);
% % mid_row = round(ny/2);
% % profile_x = Xgrid(mid_row, :) / 1000; % Convertir a km
% % profile_z = Z_reshaped(mid_row, :);
% % plot(profile_x, profile_z, 'b-', 'LineWidth', 2);
% % title('Perfil Transversal (Y = 0.5 km)');
% % xlabel('X (km)'); ylabel('Elevación (m)');
% % grid on;
% % ylim([min(profile_z)-0.1, max(profile_z)+0.1]);
% % 
% % % Subplot 4: Histograma de elevaciones
% % subplot(2, 3, 4);
% % histogram(pcXYZ(:,3), 50, 'FaceColor', 'blue', 'FaceAlpha', 0.7);
% % title('Distribución de Elevaciones');
% % xlabel('Elevación (m)'); ylabel('Frecuencia');
% % grid on;
% % 
% % % Subplot 5: Gradiente de pendientes (escala en km)
% % subplot(2, 3, 5);
% % [Gx, Gy] = gradient(Z_reshaped, 1000/nx, 1000/ny); % metros
% % slope_magnitude = sqrt(Gx.^2 + Gy.^2) * 100; % en porcentaje
% % X_km = Xgrid / 1000;
% % Y_km = Ygrid / 1000;
% % imagesc(X_km(1,:), Y_km(:,1), slope_magnitude);
% % colorbar; colormap(gca, hot);
% % title('Mapa de Pendientes (%)');
% % xlabel('X (km)'); ylabel('Y (km)');
% % axis equal tight;
% % 
% % % Subplot 6: Zoom a zona de microtopografía
% % subplot(2, 3, 6);
% % zoom_x_range = 50:150;  % Ajustado para estar dentro de 1:400
% % zoom_y_range = 250:350; % Ajustado para estar dentro de 1:400
% % zoom_Z = Z_reshaped(zoom_y_range, zoom_x_range);
% % zoom_X = Xgrid(zoom_y_range, zoom_x_range);
% % zoom_Y = Ygrid(zoom_y_range, zoom_x_range);
% % imagesc(zoom_X(1,:), zoom_Y(:,1), zoom_Z);
% % colorbar; colormap(gca, turbo);
% % title('Zoom: Microtopografía (250m × 250m)');
% % xlabel('X (metros)'); ylabel('Y (metros)');
% % axis equal tight;
% % 
% % % Estadísticas del terreno
% % fprintf('\n=== ESTADÍSTICAS DEL TERRENO AGRÍCOLA ===\n');
% % fprintf('Rango total de elevación: %.2f - %.2f metros\n', min(pcXYZ(:,3)), max(pcXYZ(:,3)));
% % fprintf('Variación total: %.2f metros (%.0f cm)\n', range(pcXYZ(:,3)), range(pcXYZ(:,3))*100);
% % fprintf('Zona izq. (microtopo): %.2f - %.2f m\n', min(pcXYZ(zone_flat_micro(:),3)), max(pcXYZ(zone_flat_micro(:),3)));
% % fprintf('Zona der. (plana): %.2f - %.2f m\n', min(pcXYZ(zone_flat_perfect(:),3)), max(pcXYZ(zone_flat_perfect(:),3)));
% % fprintf('Pendiente máxima: %.2f%%\n', max(slope_magnitude(:)));
% % fprintf('Pendiente media zona izq.: %.3f%%\n', mean(slope_magnitude(zone_flat_micro)));
% % fprintf('Pendiente media zona der.: %.3f%%\n', mean(slope_magnitude(zone_flat_perfect)));
% % 
% % end
% 
% 
% function [pcXYZ] = createTerrain_RPI_vs_TWI()
% % CREATETERRAIN_RPI_VS_TWI
% % Creates synthetic terrain to highlight differences between RPI and TWI
% % Designed to show TWI limitations and RPI advantages
% 
% % Grid size
% nx = 300; ny = 300;
% [Xgrid, Ygrid] = meshgrid(linspace(0, 1, nx), linspace(0, 1, ny));
% Zgrid = zeros(ny, nx);
% 
% % ==== ZONA 1: TERRENO CASI PLANO CON MICROTOPOGRAFÍA ====
% % TWI fallará aquí (pendiente ~0), pero RPI detectará curvatura
% zone1 = Xgrid <= 0.5 & Ygrid >= 0.5;
% base_elevation = 5.0; % Muy plano
% Zgrid(zone1) = base_elevation;
% 
% % Agregar pequeñas depresiones y montículos (20-80 cm como mencionas)
% depression_centers = [0.15, 0.75; 0.35, 0.85; 0.25, 0.65];
% mound_centers = [0.20, 0.80; 0.40, 0.70; 0.30, 0.90];
% 
% for i = 1:size(depression_centers, 1)
%     cx = depression_centers(i, 1);
%     cy = depression_centers(i, 2);
%     radius = 0.08;
%     dist_mask = ((Xgrid - cx).^2 + (Ygrid - cy).^2) <= radius^2;
%     mask = dist_mask & zone1;
%     depth = 0.5 * exp(-((Xgrid - cx).^2 + (Ygrid - cy).^2) / (0.03^2)); % 50 cm max
%     Zgrid(mask) = Zgrid(mask) - depth(mask);
% end
% 
% for i = 1:size(mound_centers, 1)
%     cx = mound_centers(i, 1);
%     cy = mound_centers(i, 2);
%     radius = 0.06;
%     dist_mask = ((Xgrid - cx).^2 + (Ygrid - cy).^2) <= radius^2;
%     mask = dist_mask & zone1;
%     height = 0.3 * exp(-((Xgrid - cx).^2 + (Ygrid - cy).^2) / (0.02^2)); % 30 cm max
%     Zgrid(mask) = Zgrid(mask) + height(mask);
% end
% 
% % ==== ZONA 2: PENDIENTE MODERADA CON CURVATURA COMPLEJA ====
% % Aquí tanto TWI como RPI funcionan, pero muestran patrones diferentes
% zone2 = Xgrid > 0.5 & Ygrid >= 0.5;
% % Pendiente gradual
% Zgrid(zone2) = 5.0 + 3.0 * (Xgrid(zone2) - 0.5); % Pendiente 3m/0.5 = 6m/m = ~1%
% 
% % Agregar curvatura convergente y divergente
% conv_center = [0.75, 0.75];
% div_center = [0.85, 0.65];
% 
% % Zona convergente (como valle pequeño)
% conv_dist = ((Xgrid - conv_center(1)).^2 + (Ygrid - conv_center(2)).^2) <= 0.05^2;
% conv_mask = conv_dist & zone2;
% conv_depth = 1.0 * exp(-((Xgrid - conv_center(1)).^2 + (Ygrid - conv_center(2)).^2) / (0.02^2));
% Zgrid(conv_mask) = Zgrid(conv_mask) - conv_depth(conv_mask);
% 
% % Zona divergente (como colina pequeña)
% div_dist = ((Xgrid - div_center(1)).^2 + (Ygrid - div_center(2)).^2) <= 0.04^2;
% div_mask = div_dist & zone2;
% div_height = 0.8 * exp(-((Xgrid - div_center(1)).^2 + (Ygrid - div_center(2)).^2) / (0.015^2));
% Zgrid(div_mask) = Zgrid(div_mask) + div_height(div_mask);
% 
% % ==== ZONA 3: TERRENO PLANO "PERFECTO" ====
% % Para mostrar dónde TWI da valores extremos/inútiles
% zone3 = Xgrid <= 0.5 & Ygrid < 0.5;
% Zgrid(zone3) = 3.0; % Completamente plano
% 
% % Solo agregar ruido muy sutil (1-2 cm) que RPI puede detectar
% noise = 0.02 * randn(sum(zone3(:)), 1); % 2 cm de ruido
% Zgrid(zone3) = Zgrid(zone3) + reshape(noise, sum(zone3(:)), 1);
% 
% % ==== ZONA 4: PENDIENTE PRONUNCIADA ====
% % Donde TWI funciona bien (referencia)
% zone4 = Xgrid > 0.5 & Ygrid < 0.5;
% % Pendiente más fuerte
% Zgrid(zone4) = 3.0 + 8.0 * (Xgrid(zone4) - 0.5) + 4.0 * (0.5 - Ygrid(zone4));
% 
% % Agregar canal de drenaje
% channel_condition = abs(Ygrid - (0.3 - 0.4 * (Xgrid - 0.5))) < 0.03;
% channel_mask = channel_condition & zone4;
% Zgrid(channel_mask) = Zgrid(channel_mask) - 1.5;
% 
% % Suavizado mínimo para evitar artefactos
% Zgrid = imgaussfilt(Zgrid, 1.5);
% 
% % Rescalar para mantener rangos realistas de elevación
% Zgrid = rescale(Zgrid, 2, 10); % 2-10 metros
% 
% % Output como point cloud
% pcXYZ = [Xgrid(:), Ygrid(:), Zgrid(:)];
% 
% % Visualización
% figure('Position', [100, 100, 1200, 400]);
% 
% % Subplot 1: Terreno 3D
% %subplot(1, 3, 1);
% scatter3(pcXYZ(:,1), pcXYZ(:,2), pcXYZ(:,3), 4, pcXYZ(:,3), 'filled');
% title('Terreno Sintético: RPI vs TWI');
% xlabel('X'); ylabel('Y'); zlabel('Elevation (m)');
% axis equal; grid on; view(45, 30);
% colormap(gca, turbo); colorbar;
% 
% % Agregar etiquetas de zonas
% text(0.25, 0.75, max(pcXYZ(:,3)), 'ZONA 1: Plano + Micro', 'FontSize', 10, 'Color', 'red', 'FontWeight', 'bold');
% text(0.75, 0.75, max(pcXYZ(:,3)), 'ZONA 2: Pendiente + Curvatura', 'FontSize', 10, 'Color', 'red', 'FontWeight', 'bold');
% text(0.25, 0.25, max(pcXYZ(:,3)), 'ZONA 3: Plano Perfecto', 'FontSize', 10, 'Color', 'red', 'FontWeight', 'bold');
% text(0.75, 0.25, max(pcXYZ(:,3)), 'ZONA 4: Pendiente Fuerte', 'FontSize', 10, 'Color', 'red', 'FontWeight', 'bold');
% end