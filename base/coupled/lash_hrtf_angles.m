function [lashed_angles, factr] = lash_hrtf_angles(hrtf_angles, ap)
% lash_hrtf_angles - A set of compressed HRTF angles (see aperture_distce_atten()) is further
% compressed, depending on the aperture to the door for a specified point. The idea is to have a
% continuous transition to the situation where only one hrtf_angle is applied to all FDN channels.
% This function is called within see aperture_distce_atten().
%
% Usage:
%   [lashed_angles, factor] = lash_hrtf_angles(hrtf_angles, ap)
%
% Input:
%   hrtf_angles     Matrix containing HRTF angles in the format [azim, elev]
%   ap              Apertures (azim, elev) for the receiver point to the door
%
% Output:
%   lashed_angles   The lashed angles, same format as hrtf_angles
%   factr           Factor applied to hrtf_angles

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.92
%
% Author(s): Torben Wendt
%
% Copyright (c) 2014-2017, Torben Wendt, Steven van de Par, Stephan Ewert,
% University Oldenburg, Germany.
%
% This work is licensed under the
% Creative Commons Attribution-NonCommercial-NoDerivs 4.0 International
% License (CC BY-NC-ND 4.0).
% To view a copy of this license, visit
% http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
% Creative Commons, 444 Castro Street, Suite 900, Mountain View, California,
% 94041, USA.
%------------------------------------------------------------------------------


% Torben Wendt
% 2015-08-10



maxap = max(ap);
avg_angles = mean(hrtf_angles, 1);

%factr = 1 - 2./(maxap + 2);
factr = (tanh(0.1*(maxap - 45)) + 1)/2;

lashed_angles = factr*hrtf_angles + repmat((1 - factr)*avg_angles, size(hrtf_angles, 1), 1);

