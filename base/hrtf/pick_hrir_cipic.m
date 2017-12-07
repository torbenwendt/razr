function hrir = pick_hrir_cipic(azim, elev, dbase, options)
% PICK_HRIR_CIPIC
% 
% See also: HRTF_PARAMS_CIPIC

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


% angle conversion:
[lat, pol] = geo2horpolar(-azim, elev);

num = length(lat);
hrir = zeros(dbase.len, num, 2);

% round angles:
for n = 1:num
    [ans0, minlatdistarg] = min(abs(dbase.laterals - lat(n)));
    [ans0, minpoldistarg] = min(abs(dbase.polars   - pol(n)));
    hrir(:, n, 1) = dbase.hrir.hrir_l(minlatdistarg, minpoldistarg, :);
    hrir(:, n, 2) = dbase.hrir.hrir_r(minlatdistarg, minpoldistarg, :);
end
