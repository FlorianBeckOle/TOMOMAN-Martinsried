function sg_extract_make_tomolist(tm_tomolist_name,tomo_dir,sg_tomolist_name)
%% sg_extract_make_tomolist
% A function to read a TOMOMAN tomolist 
% WW 08-2022


%% Initialize

% Read tomolist
tomolist = tm_read_tomolist([],tm_tomolist_name);
n_tomos = numel(tomolist);

% Open output file
fid = fopen(sg_tomolist_name,'w');

%% Create links

for i = 1:n_tomos
    
    % Check for skip
    if tomolist(i).skip
        continue
    end
    
    % Parse name of stack used for alignment
    switch tomolist(i).alignment_stack
        case 'unfiltered'
            process_stack = tomolist(i).stack_name;
        case 'dose-filtered'
            process_stack = tomolist(i).dose_filtered_stack_name;
        otherwise
            error([p.name,'ACTHUNG!!! Unsuppored stack!!! Only "unfiltered" and "dose-filtered" supported!!!']);
    end        
    [~,stack_name,~] = fileparts(process_stack);
    tomo_name = [stack_name,'.rec'];
    
    % Check for tomo
    if ~exist([tomo_dir,tomo_name],'file')
        warning(['ACHTUNG!!! Tomogram ',tomo_name,' not found!!! Moving to next tomogram...']);
        continue
    end   
    
    % Write output
    fprintf(fid,'%s\n',[num2str(tomolist(i).tomo_num),' ',tomo_dir,tomo_name]);    
    
end


% Close file
fclose(fid);


