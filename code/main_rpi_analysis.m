%% ========================================================================
%% RUNOFF POTENTIAL INDEX (RPI) - ANALYSIS AND CALCULATION
%% ========================================================================
% Author: Edgar S. Correa
% Date: (2024) - (May 2025)
% Description: This script calculates the Runoff Potential Index (RPI)
%              for terrain-based drought vulnerability assessment.
%              RPI = ∇²z / (|∇z| + ε)
%
% Features:
% - RPI calculation for upland-lowland differentiation
% - Terrain curvature and slope analysis
% - Drought vulnerability mapping
% - Agricultural zone classification
%
% Usage: Run this script to calculate RPI for terrain analysis
% ========================================================================

%% INITIALIZATION
clc; clear; close all;

%% TERRAIN SETUP
rows = 200;
dz = 0.1;

% Initialize terrain
[Xgrid, Ygrid, Zgrid, Z_index, dz] = initializeTerrain2(rows, dz);

%% RPI CALCULATION AND ANALYSIS
fprintf('Calculating Runoff Potential Index (RPI)...\n');

% Calculate RPI values for terrain
Index(Xgrid, Ygrid, Zgrid);   % Main RPI analysis function

fprintf('RPI analysis completed!\n');
fprintf('Results show upland-lowland differentiation for drought assessment.\n');