%% sg_motl_shift_and_rotate
% A function for applying a shift and rotation to an entire motivelist. The
% shifts and rotations are with respect to the refrence frame, and are
% ordered as shift, then rotation about the shifted positions.
%
% Best practice would be to pre-determine the desired shifts and rotations
% using sg_rotate_vol(sg_shift_vol(ref,[x_shift,y_shift,z_shift]),[phi,psi,the]).
% These shifts and rotations are then the input for this script. 
%
% WW 08-2018

%% Inputs

% Motivelists
input_name = 'allmotl_8.star';
output_name = 'allmotl_rot_8.star';

% Shifts
x_shift = 0;
y_shift = 0;
z_shift = 0;

% Rotations
phi = -90;
psi = 90;
the = -90;


%% Initialize

% Shift vector
r = [-x_shift,-y_shift,-z_shift];

% Check calculations
if all(r==0)
    calc_shift = false;
else
    calc_shift = true;
end
if all([phi,psi,the]==0)
    calc_rot = false;
else
    calc_rot = true;
end
if ~calc_shift && ~calc_rot
    error('ACHTUNG!!! You have not given me anything to do!!!');
end

% Read motivelist
allmotl = sg_motl_read(input_name);
n_motls = numel(allmotl);


% Precalculate rotation quaternion
q = sg_euler2quaternion(-psi,-phi,-the);

% New motivelist
newmotl = allmotl;


%% Apply shifts and rotations
disp('Applying shifts and rotations!!!11!');

for i = 1:n_motls
     
    % Parse old angles
    q_old = sg_euler2quaternion(allmotl(i).phi,allmotl(i).psi,allmotl(i).the);
    
    % Calculate shifts
    if calc_shift
        % New shift vector
        r_new = sg_quaternion_rotate(q_old,r);
        
        % Store shift values
        newmotl(i).x_shift = allmotl(i).x_shift + r_new(1);
        newmotl(i).y_shift = allmotl(i).y_shift + r_new(2);
        newmotl(i).z_shift = allmotl(i).z_shift + r_new(3);
        
    end
    
    % Calculate rotations
    if calc_rot
        
        % New eulers
        q_new = sg_quaternion_multiply(q_old,q);
        [nphi,npsi,nthe] = sg_quaternion2euler(q_new);
        
        % Store new angles
        newmotl(i).phi = nphi;
        newmotl(i).psi = npsi;
        newmotl(i).the = nthe;
    end
    
     
     
end

sg_motl_write(output_name,newmotl);









