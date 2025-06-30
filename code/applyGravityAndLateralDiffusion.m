function W = applyGravityAndLateralDiffusion(W, Zgrid, Zmin, dz)
% applyGravityAndLateralDiffusion: simulates gravity and lateral flow at terrain contact
% Inputs:
%   W       - 3D water matrix (MxNxZ), binary (0 or 1) for discrete model
%   Zgrid   - terrain elevation map (MxN)
%   Zmin    - minimum terrain elevation
%   dz      - vertical voxel thickness
% Output:
%   W       - updated water volume (discrete)

    [rows, cols, z_max] = size(W);

    for z = 1:z_max-1
        z_above = z + 1;
        H = W(:,:,z_above);  % Water layer at current height

        % Step 1: Compute the physical height of the voxel below
        Z_voxel_below = Zmin + (z - 1) * dz;

        % Step 2: Determine where water can fall downward
        canFall = H > 0 & Z_voxel_below > Zgrid;

        % Step 3: Where water cannot fall, it's in contact with terrain → enable lateral flow
        terrainContact = ~canFall & H > 0;
        if any(terrainContact(:))
            % Apply lateral redistribution using discrete movement
            W = darcyLateralFlow_discrete(W, Zgrid, terrainContact, z_above);
        end

        % Step 4: Apply gravity (move to lower voxel)
                [ix, iy] = find(canFall);
        for k = 1:length(ix)
            x = ix(k); y = iy(k);

            % Buscar la capa más baja disponible que esté encima del terreno
            for z_target = z:-1:1
                altura = Zmin + (z_target - 1) * dz;
                if altura > Zgrid(x, y) && W(x, y, z_target) == 0
                    % Mover gota
                    W(x, y, z_above) = 0;
                    W(x, y, z_target) = 1;
                    break;
                end
            end
        end

        
    end
end

% function W = applyGravityAndLateralDiffusion(W, Zgrid, Zmin, dz)
% % applyGravityAndLateralDiffusion: simulates gravity and lateral flow at terrain contact
% % Inputs:
% %   W       - 3D water matrix (MxNxZ)
% %   Zgrid   - terrain elevation map (MxN)
% %   Zmin    - minimum terrain elevation
% %   dz      - vertical voxel thickness
% % Output:
% %   W       - updated water volume
% 
%     [rows, cols, z_max] = size(W);
%     alpha = 0.25;  % diffusion coefficient
% 
%     for z = 1:z_max-1
%         z_above = z + 1;
%         H = W(:,:,z_above);
% 
%         % === Step 1: Check where water can fall ===
%         Z_voxel_below = Zmin + (z - 1) * dz;
%         canFall = H > 0 & Z_voxel_below > Zgrid;
% 
%         % === Step 2: Lateral flow ONLY where water cannot fall ===
%         terrainContact = ~canFall & H > 0;
%         if any(terrainContact(:))
%             H_new = darcyLateralFlow(H, Zgrid, alpha, terrainContact);
%             W(:,:,z_above) = H_new;
%             H = H_new;  % update local H for gravity step
%         end
% 
%         % === Step 3: Gravity step ===
%         moved = H .* canFall;
%         W(:,:,z_above) = W(:,:,z_above) - moved;
%         W(:,:,z) = W(:,:,z) + moved;
%     end
% end