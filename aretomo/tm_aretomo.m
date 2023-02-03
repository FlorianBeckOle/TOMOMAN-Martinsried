function tomolist = tm_aretomo(tomolist,p,are,dep,write_list)
%% tm_aretomo
% Wrapper function to run AreTomo. 
%
% WW 05-2022

%% Dose filter
n_stacks = size(tomolist,1);

for i = 1:n_stacks
    
    % Check processing
    process = true;
    if tomolist(i).skip
        process = false;        
    elseif tomolist(i).stack_aligned
        if ~are.force_align
            process = false;
        end
    end
    
    % Process 
    if process        
        disp(['TOMOMAN: Running AreTomo on stack: ',tomolist(i).stack_name]);
        
        % Parse stack name
        switch are.process_stack
            case 'unfiltered'
                stack_name = tomolist(i).stack_name;
            case 'dose-filtered'
                stack_name = tomolist(i).dose_filtered_stack_name;
            otherwise
                error(['TOMOMAN: ACHTUNG!!! ',are.process_stack,' is an unsupported stack type!!! Allowed types are either "unfiltered" or "dose-filtered"']);
        end
        [~,name,ext] = fileparts(stack_name);
        
        
        
        % Initialize processing script
        if exist([tomolist(i).stack_dir,'AreTomo/'],'dir')
            system(['rm -rf ',tomolist(i).stack_dir,'AreTomo/']);
        end
        mkdir([tomolist(i).stack_dir,'AreTomo/']);
        script_name = [tomolist(i).stack_dir,'AreTomo/run_aretomo.sh'];
        fid = fopen(script_name,'w');
        % fprintf(fid,['#!/usr/bin/env bash \n\n','set -e \n','set -o nounset \n\n']);
        fprintf(fid,'# Aligning tilt-series using AreTomo \n\n');
        
        
        
        % Check for input stack binning
        if are.InBin > 1
            
            % Parse binned stack name
            InMrc_name = [tomolist(i).stack_dir,'AreTomo/',name,'_bin',num2str(are.InBin),ext];
            
            % Bin stack
            fprintf(fid,['# Fourier crop aligned stack','\n']);
            fprintf(fid,['newstack -InputFile ',tomolist(i).stack_dir,stack_name,' ',...
                             ' -OutputFile ',InMrc_name,' ',...
                             ' -FourierReduceByFactor ', num2str(are.InBin),'\n\n']);
                         
        else
            
            % Parse input stack name
            InMrc_name = [tomolist(i).stack_dir,stack_name];
            
        end

        
        % Check output directory
        if ~exist([p.root_dir,are.out_dir],'dir')
            mkdir([p.root_dir,are.out_dir])
        end
            
        % Output tomogram name
        vol_name = [name,'_bin',num2str(are.OutBin),'.mrc'];
        OutMrc_name = [tomolist(i).stack_dir,'AreTomo/',vol_name];
                
        % AngleFile
        tlt_name = [tomolist(i).stack_dir,name,'.rawtlt'];

        
        
        
        % Write AreTomo lines
        fprintf(fid,['# Run AreTomo','\n']);
        fprintf(fid,[dep.aretomo,' -InMrc ' , InMrc_name,...
                                 ' -OutMrc ', OutMrc_name,...
                                 ' -AngFile ', tlt_name,...
                                 ' -AlignZ ', num2str(are.AlignZ/are.InBin),...
                                 ' -VolZ ', num2str(are.VolZ/are.InBin),...                                 
                                 ' -Wbp ', num2str(are.Wbp),...
                                 ' -Outbin ',num2str(are.OutBin/are.InBin),...
                                 ' -TiltCor ',num2str(are.TiltCor),...
                                 ' -TiltAxis ',num2str(tomolist(i).tilt_axis_angle),...
                                 ' -OutXF ', num2str(are.OutXF),...
                                 ' -OutImod ', num2str(are.OutImod),...
                                 ' -Gpu ', num2str(are.Gpu)]);
         if ~isempty(are.Sart)
             fprintf(fid,[' -Sart ',num2str(are.Sart,'%5.2f,%-5.2f')]);
         end
         if ~isempty(are.Roi)
             fprintf(fid,[' -Roi ',num2str(are.Roi,'%5.2f,%-5.2f')]);
         end
         if ~isempty(are.Patch)
             fprintf(fid,[' -Patch ',num2str(are.Patch,'%5.2f,%-5.2f')]);
         end
         if ~isempty(are.DarkTol)
             fprintf(fid,[' -DarkTol ',num2str(are.DarkTol)]);
         end
         fprintf(fid,'\n\n');
        
%         % Write aligned stack
%         ali_name = [tomolist(i).stack_dir,'AreTomo/',name,'_bin',num2str(are.OutBin),'.ali'];
%         fprintf(fid,[dep.aretomo,' -InMrc ' , InMrc_name,...
%                                  ' -OutMrc ', ali_name,...
%                                  ' -AlnFile ', [InMrc_name,'.aln'],...
%                                  ' -Align 0 -VolZ 0 ',...                                 
%                                  ' -Gpu ', num2str(are.Gpu)]);
        fprintf(fid,'\n\n');
        
        % Check for IMOD output
        if are.OutImod
            
            % Directory of -OutImod outputs
%             imod_dir = [tomolist(i).stack_dir,'AreTomo/',name,'_bin',num2str(are.OutBin),'/'];
            imod_dir = [tomolist(i).stack_dir,'AreTomo/'];
            
            % Rotate volume
%             fprintf(fid,[dep.clip,' flipyz ',imod_dir,'tomogram.mrc ',imod_dir,'tomogram.mrc','\n\n']);
%             fprintf(fid,[dep.clip,' rotx ',imod_dir,'tomogram.mrc ',imod_dir,'tomogram.mrc','\n\n']);   % For Aretomo > ver 1
            fprintf(fid,[dep.clip,' rotx ',imod_dir,vol_name,' ',imod_dir,vol_name,'\n\n']);   % For Aretomo > ver 1

            % Cleanup
            fprintf(fid,['rm -f ',tomolist(i).stack_dir,'AreTomo/*~ \n\n']);
            fprintf(fid,['rm -f ',imod_dir,'*~ \n\n']);

            % Move final tomogram
            fprintf(fid,['mv ',imod_dir,vol_name,' ',p.root_dir,are.out_dir,vol_name]);
            
        else
            
            % Rotate volume
            fprintf(fid,[dep.clip,' flipyz ',OutMrc_name, ' ', OutMrc_name,'\n\n']);

            % Cleanup
            fprintf(fid,['rm -f ',tomolist(i).stack_dir,'AreTomo/*~ \n\n']);

            % Move final tomogram
            fprintf(fid,['mv ',OutMrc_name,' ',p.root_dir,are.out_dir]);
            
        end
        
        fclose(fid);
        
        % Run script
        system(['chmod +x ',script_name]);
        system(script_name);
        
        % Convert outputs to IMOD format
        tm_aretomo2imod(tomolist(i),are);
        
        
        % Update tomolist
        tomolist(i).stack_aligned = true;
        tomolist(i).alignment_stack = are.process_stack;
        tomolist(i).alignment_software = 'AreTomo';
        
        
        
        % Save tomolist
        if write_list
            save([p.root_dir,p.tomolist_name],'tomolist');
        end
        
              
    end
    
end

