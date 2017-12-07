function hrir = pick_hrir_fabian(azim, elev, dbase, options)
% PICK_HRIR_FABIAN
% 
% See also: HRTF_PARAMS_FABIAN

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


% available azim/elev in database: 0:359 and -90:90, respectively:
elev = round(elev);
azim = round(azim);

% -179 ... +180 --> 0 ... 359:
azim = pm180_to_360(azim);

num = length(azim);
hrir = zeros(dbase.len, num, 2);

for n = 1:num
    idx_el = dbase.hrir.elevation == elev(n);
    idx_az = dbase.hrir.azimuth == azim(n);
    idx_hrir = idx_el & idx_az;
    assert(sum(idx_hrir) == 1);
    
    hrir(:, n, :) = ...
        [dbase.hrir.HRIR_L(:, idx_hrir), dbase.hrir.HRIR_R(:, idx_hrir)];
end


