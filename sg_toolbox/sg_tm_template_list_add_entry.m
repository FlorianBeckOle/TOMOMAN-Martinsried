%% sg_tm_template_list_add_entry.m
% Add an entry to a template list. If the template list already exists, the
% new entry is appended to the old list.
%
% The template list is a .star file with the following columns:
% Template name 
% Mask name
% Symmetry
% Angle list name
%
% WW 03-2018

%% Inputs

% Template list name
tlist_name = 'tlist_20deg.star';

% Parameters
tmpl_name = 'tmpl.mrc';
mask_name = 'mask.mrc';
symmetry = 'c3';
anglist_name = 'anglist_20deg_c1.csv';



%% Generate template list

% Intialize struct
tlist = struct();

% Fill fields
tlist.tmpl_name = tmpl_name;
tlist.mask_name = mask_name;
tlist.symmetry = symmetry;
tlist.anglist_name = anglist_name;


% Check for old list
if exist(tlist_name,'file')
    old_tlist = sg_tm_template_list_read(tlist_name);
    tlist = cat(1,old_tlist,tlist);
end

% Write list
stopgap_star_write(tlist,tlist_name,'sg_tm_template_list',[],4,2);





