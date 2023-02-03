function dep = tm_get_dependencies(task,dep)
%% tm_get_dependencies
% Return a struct array containing the executable names of required
% external dependencies for each task. 
%
% WW 05-2022

%% External Commands

% Source dependency list from .param file
try
    [~,tomomanhome] = system('echo $TOMOMANHOME');  % Get TOMOMAN path
    exe_cell = tm_read_paramfile([tomomanhome(1:end-1),'/../io/tm_dependencies.param']);
catch
    [dep_param_path,~,~] = fileparts(which('tm_get_dependencies'));
    exe_cell = tm_read_paramfile([dep_param_path,'/tm_dependencies.param']);
end


   
%% Task dependencies

switch task
    case 'linux'
        task_cell = {'cp', 'mv', 'ln'};
        
    case 'relionmc'
        task_cell = {'relion_import','relionmc','newstack'};
        
    case 'motioncor2'
        task_cell = {'motioncor2','newstack'};
        
    case 'clean_stacks'
        task_cell = {'imod_3dmod', 'newstack'};
        
    case 'dosefilter'
        task_cell = {'newstack'};
        
    case 'aretomo'
        task_cell = {'aretomo', 'newstack', 'clip'};
        
    case 'imod'
        task_cell = {'etomo'};
        
    case 'ctffind4'
        task_cell = {'ctffind4'};
        
    case 'tiltctf'
        task_cell = {'ctffind4'};
        
    case 'novactf'
        task_cell = {'novactf','etomo','fourier3d','mpiexec'};
        
end



%% Generate dep array

% Check for input struct
if nargin == 1
    % Initialize struct
    dep = struct();
end


% Number of dependencies
n_dep = numel(task_cell);

% Fill dependencies
for i = 1:n_dep
    
    % Find executable name in exe cell
    exe_idx = strcmp(exe_cell{1},task_cell{i});
    
    % Store executable command
    dep.(task_cell{i}) = exe_cell{2}{exe_idx};
    
end





