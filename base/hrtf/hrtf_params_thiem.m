function dbase = hrtf_params_thiem(dbase, options)
% HRTF_PARAMS_THIEM - Set parameters for thiemann database.
% 
% Available options:
%   dbname  ID of artificial head
%           'BK':       Bruel & Kjaer dummy head
%           'Head':     HEAD acoustics dummy head
%           'KEMAR':    KEMAR dummy head (default)
%           'SP':       Custom dummy head built by the Signal Processing Group,
%                       Uni Oldenburg
% 
% Database reference:
%   Thiemann, J., et al. (2015): Multiple Model High-Spatial Resolution HRTF
%   Measurements, DAGA 2015.

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


if ~isfield(options, 'dbname')
    options.dbname = 'kemar';
end

dbase.dbname = lower(options.dbname);
dbase.orig_names.bk    = 'BK';
dbase.orig_names.head  = 'Head';
dbase.orig_names.kemar = 'KEMAR';
dbase.orig_names.sp    = 'SP';

dbase.fs = 44100;
%hrir_len = 2205;

% For these databases, hrirs will be truncated below:
dbase.len = 330;
dbase.flanklen = round(1e-3*dbase.fs);
win = hannwin(dbase.flanklen*2);
dbase.flank = repmat(win((dbase.flanklen + 1):end), 1, 2);

dbase.oldpath = addpath(dbase.path);
dbase.did_addpath = true;
