function hrir = pick_hrir_sofa(azim, elev, dbase, options)
% PICK_HRIR_SOFA - Pick an HRIR from a SOFA database

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


if ~strcmp(dbase.sofaobj.GLOBAL_SOFAConventions, 'SimpleFreeFieldHRIR')
    error('HRTFs must be saved in the SOFA conventions SimpleFreeFieldHRIR');
end

% conversion of angles from RAZR to SOFA format:
azim = pm180_to_360(azim);

num = length(azim);
hrir = zeros(dbase.len, num, 2);

for n = 1:num
    angdiff = bsxfun(@minus, dbase.sofaobj.SourcePosition(:, 1:2), [azim(n), elev(n)]);
    [ans0, idx] = min(sum(angdiff.^2, 2));
    hrir(:, n, :) = squeeze(dbase.sofaobj.Data.IR(idx, :, :))';
end

% actually used angles:
%az = dbase.sofaobj.SourcePosition(idx, 1);
%el = dbase.sofaobj.SourcePosition(idx, 2);

end
