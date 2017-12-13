function hrir = pick_hrir_mk2(azim, elev, dbase, options)
% PICK_HRIR_MK2
% 
% See also: HRTF_PARAMS_MK2

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.93
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


% angle conversion:
azim = pm180_to_360(azim);  % -90 -> +270 etc.

num = length(azim);
hrir = zeros(dbase.len, num, 2);

for n = 1:num
    [Azim, Elev] = GetNearestAngle(azim(n), elev(n), dbase.grd.hrtf_grid_deg);
    load(fullfile(dbase.path, GetSaveStr(Azim, Elev)));  % loads y_hrir
    hrir(:, n, :) = y_hrir;
end
