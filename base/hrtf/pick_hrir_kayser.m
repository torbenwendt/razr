function hrir = pick_hrir_kayser(azim, elev, dbase, options)
% PICK_HRIR_KAYSER
% 
% See also: HRTF_PARAMS_KAYSER

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


num = length(azim);
hrir = zeros(dbase.len, num, 2);

for n = 1:num
    [Azim, Elev] = GetNearestAngle(azim(n), elev(n), dbase.grd.hrtf_grid_kayser);
    Azim = -Azim;
    hrir_tmp = loadHRIR_kayser_for_razr('Anechoic', dbase.distance, Elev, Azim, 'in-ear');
    hrir(:, n, :) = hrir_tmp.data;
end
