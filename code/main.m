%% ========================================================================
%% RUNOFF SIMULATION TOOLBOX - MAIN ENTRY POINT
%% ========================================================================
% Author: Edgar S. Correa
% Date: (2024) - (May 2025)
% Description: This toolbox simulates surface water runoff over terrain
%              using a 3D grid-based approach with gravity and lateral
%              diffusion effects. The simulation calculates runoff indices
%              and visualizes water flow dynamics over time.
%
% Features:
% - 3D terrain modeling with customizable resolution
% - Rain drop initialization and water accumulation
% - Gravity-driven water movement with lateral diffusion
% - Real-time visualization of water flow
% - Runoff index calculation and analysis
% - Frame-by-frame output for animation creation
%
% Usage: Simply run this script to start the simulation
% ========================================================================

%% INITIALIZATION
% Clear workspace and prepare environment
clc; clear; close all;

% Create output directory for simulation frames
outputDir = 'frames_water';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

%% SIMULATION PARAMETERS
% These parameters control the behavior and accuracy of the simulation

% Grid and spatial resolution
rows = 200;                    % Grid resolution for terrain (200x200 cells)
dz = 0.1;                     % Vertical layer thickness in meters
Z_offset = 5.0;               % Initial water height above terrain (m)

% Precipitation parameters  
numDrops = 500;               % Number of initial rain drops per event
Timeline = 90;                % Total simulation time steps

% Physics parameters
gravityStepsPerFrame = 3;     % Water layers that can fall per time step
                             % (controls simulation speed vs accuracy)

%% STEP 1: TERRAIN INITIALIZATION AND RUNOFF INDEX CALCULATION
% Load or generate terrain data and calculate runoff characteristics
fprintf('Initializing terrain and calculating runoff indices...\n');

[Xgrid, Ygrid, Zgrid, Z_index, dz] = initializeTerrain(rows, dz);
Zmin = min(Zgrid(:));         % Find minimum terrain elevation

% Calculate runoff index based on terrain characteristics
% Index(Xgrid, Ygrid, Zgrid);   % This function analyzes terrain for runoff potential

%% STEP 2: WATER INITIALIZATION 
% Place initial water droplets on the terrain surface
fprintf('Placing initial water droplets...\n');

W = initializeWater(Zgrid, Zmin, dz, Z_offset, numDrops);
n = 1;                        % Rain event counter

%% STEP 3: MAIN SIMULATION LOOP
% Run the physics simulation over time
fprintf('Starting runoff simulation...\n');

figure;
outputDir = 'frames_darcy';   % Directory for output frames

for t = 1:Timeline
    % Display current simulation progress
    if mod(t, 10) == 0
        fprintf('Simulation progress: %d/%d steps (%.1f%%)\n', ...
                t, Timeline, (t/Timeline)*100);
    end
    
    % Visualize current state of water distribution
    visualizeWaterSimple(W, Xgrid, Ygrid, Zgrid, Zmin, dz, t);
    
    % Apply physics: gravity and lateral water movement
    % Multiple substeps per frame for numerical stability
    for s = 1:gravityStepsPerFrame
        W = applyGravityAndLateralDiffusion(W, Zgrid, Zmin, dz);
        % Alternative gravity function (comment/uncomment as needed):
        % W = applyGravity_stepwise(W, Zgrid, Zmin, dz);
    end
    
    % Add new precipitation events during early simulation
    if n < 15
        Wn = initializeWater(Zgrid, Zmin, dz, Z_offset, numDrops);
        W = Wn + W;              % Add new water to existing
        n = n + 1;               % Increment rain event counter
    end
    
    % Save current frame with water volume data
    % Volume is calculated and displayed in mm for practical interpretation
    saveCurrentFrameWithWaterMM(W, dz, Xgrid, Ygrid, t, outputDir);
    
end

% Brief pause to ensure final frame is saved
pause(0.1);

fprintf('Simulation completed! Check %s folder for output frames.\n', outputDir);

%% SIMULATION SUMMARY
% Display final statistics and results
fprintf('\n=== SIMULATION SUMMARY ===\n');
fprintf('Total simulation steps: %d\n', Timeline);
fprintf('Final water events: %d\n', n-1);
fprintf('Output directory: %s\n', outputDir);
fprintf('Grid resolution: %dx%d cells\n', rows, rows);
fprintf('Vertical resolution: %.2f m\n', dz);