function par = tomoman(root_dir,paramfilename,task,par)
%% tomoman
% A function to run the TOMOMAN workflow. 
%
% Input is a TOMOMAN .param file. NOTE: The input .param file must have the
% first line formatted as: "## tomoman_[task]" where [task] is the name of
% the task to be run. 
%
% WW 06-2022

%% Check input task

% Check for parallel processing
if nargin < 4
    par = [];
end
    

% Check if task was given
if nargin < 3
    task = [];
end

% Check root_dir
root_dir = sg_check_dir_slash(root_dir);

% Check paramfile exists
if ~exist([root_dir,paramfilename],'file')
    error('TOMOMAN: ACHTUNG!!! paramfile not found!!!');
end
    

% Parse task if not given
if isempty(task)
    
    % Get input task from paramfile header
    try
        task = tm_parse_tasks([root_dir,paramfilename]);
    catch
        error ('TOMOMAN: ACHTUNG!!! Unable to determine task from paramfile header!!!');
    end
    
end



%% Parse task

% Get list of tasks
tasks = tm_get_tasks();


% Check for valid task
if ~any(strcmpi(tasks,task))
    error(['TOMOMAN: Achtung!!! Input .param file "',paramfilename,'" has an invalid task: ',task,'!!!']);
end


%% Run task

switch lower(task)
    
    case 'pipeline'
        par = tomoman_pipeline(root_dir,paramfilename,par);
    
    case 'import'
        par = tomoman_import(root_dir,paramfilename,par);
        
    case 'relion_motioncorr'
        par = tomoman_relion_motioncorr(root_dir,paramfilename,par);
        
    case 'motioncor2'
        par = tomoman_motioncor2(root_dir,paramfilename,par);
        
    case 'clean_stacks'
        par = tomoman_clean_stacks(root_dir,paramfilename,par);
        
    case 'dosefilter'
        par = tomoman_dosefilter(root_dir,paramfilename,par);
        
    case 'aretomo'
        par = tomoman_aretomo(root_dir,paramfilename,par);
        
    case 'imod_preprocess'
        par = tomoman_imod_preprocess(root_dir,paramfilename,par);
        
    case 'ctffind4'
        par = tomoman_ctffind4(root_dir,paramfilename,par);
        
    case 'tiltctf'
        par = tomoman_tiltctf(root_dir,paramfilename,par);
        
    case 'novactf'
        par = tomoman_novactf(root_dir,paramfilename,par);
        
    otherwise
        error(['TOMOMAN: ACHTUNG!!! ',task,' is an unsupported task!!!']);
        
end

end




