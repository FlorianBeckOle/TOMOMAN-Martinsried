function compile_tomoman(target_dir)
%% compile_tomoman
% Default parameters for compiling TOMOMAN_parallel. TOMOMAN is compiled
% into the target_dir.
% 
% WW 07-2022

% % % % DEBUG
% target_dir = '/dors/wan_lab/home/wanw/research/software/tomoman/TOMOMAN-vandy/exec/lib/';


%% Compile

% % Clear workspace
% clear all
% close all

% Compile with tiltctf lookup table
[self_path,~,~] = fileparts(which('tm_get_dependencies'));
dep_param = [self_path,'/tm_dependencies.param'];

% Compile with backup dependencies
[self_path,~,~] = fileparts(which('tm_tiltctf_ctffind4'));
lut_name = [self_path,'/tiltctf_lut.csv'];

% Compile
% mcc -mv -R nojvm -R -nodisplay -R -nosplash tomoman_parallel.m -d /dors/wan_lab/home/wanw/research/software/tomoman/TOMOMAN-vandy/exec/lib/ -a lut_name
mcc('-R', 'nojvm', '-R', 'nodisplay', '-R', 'nosplash', '-m', 'tomoman_parallel.m', '-d', target_dir, '-a', lut_name, '-a', dep_param)
