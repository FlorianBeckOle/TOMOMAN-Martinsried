function tomoman_parallel(varargin)
%% tomoman_parallel
% A function to run the TOMOMAN workflow in a parallel computing
% environment. 
%
% NOTE: There are a few overlapping parameters between .param files and the
% input to tomoman_parallel. Specifically, the root_dir and tomolist_name
% parameters in the .param files are ALWAYS overwritten with those in the
% tomoman_parallel input. This is to ensure consistency when running a
% parallel pipeline job.
%
% WW 07-2022


% % % % % DEBUG
% varargin = {'root_dir', '/hd1/wwan/2022_embo-course/hiv_subset/tomo2/', 'paramfilename', 'pipeline.param', 'n_nodes', '1', 'node_id', '0', 'n_tasks', '1', 'local_id', '0', 'task_id', '0', 'n_tasks_per_node', '1', 'cpus_per_task', '10', 'gpu_per_node', '1', 'gpu_per_task', '1' 'gpu_list', '3'};

%% Initialize

% Parse parallel inputs
par = tm_parse_parallel_inputs(varargin);

% Set up comm folder
par = tm_par_initialize_dirs(par);


% Check root_dir
par.root_dir = sg_check_dir_slash(par.root_dir);

% Get input task from paramfile header
try
    task = tm_parse_tasks([par.root_dir,par.paramfilename]);
catch
    error ('TOMOMAN: ACHTUNG!!! Unable to determine task from paramfile header!!!');
end

%% Run TOMOMAN


switch lower(task)
    
    case 'pipeline'
        [~] = tomoman_pipeline(par.root_dir,par.paramfilename,par);
        
    otherwise
        % Run TOMOMAN workflow in parallel
        par = tomoman(par.root_dir,par.paramfilename,[],par);

        % Recompile results
        % task = tm_parse_tasks(par.paramfilename);
        tm_par_finish_run(par);
            
            
end



