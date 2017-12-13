function hrir = pick_hrir_thiem(azim, elev, dbase, options)
% PICK_HRIR_THIEM
% 
% See also: HRTF_PARAMS_THIEM

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


% CAUTION: This file is likely buggy.

% angle conversion:
azim = -azim;

num = length(azim);
hrir = zeros(dbase.len, num, 2);

for n = 1:num
    hrir(:, n, :) = loadHRIRnear(...
        fullfile(hrtf_path, [dbase.orig_names.(options.dbname), '.h5']), ...
        azim(n), elev(n))';
end

% truncate and fade out HRIR:
hrir = hrir(1:hrir_len, :, :);
hrir((dbase.len - dbase.flanklen + 1):dbase.len, :, :) = ...
    hrir((dbase.len - dbase.flanklen + 1):dbase.len, :, :) .* flank;
