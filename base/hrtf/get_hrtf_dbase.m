function dbase = get_hrtf_dbase(database, options)
% GET_HRTF_DBASE - Create a HRTF-database struct for razr

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


cfg = get_razr_cfg;

dbase = parse_database(database, cfg);

if dbase.is_sofa
    dbase = hrtf_params_sofa(dbase, cfg);
    dbase.fname_pick = 'pick_hrir_sofa';
else
    dbase.fname_params = sprintf('hrtf_params_%s', database);
    dbase.fname_pick   = sprintf('pick_hrir_%s', database);
    hrtf_params_func = str2func(dbase.fname_params);
    
    try
        dbase = hrtf_params_func(dbase, options);
    catch exc
        if strcmp(exc.identifier, 'MATLAB:UndefinedFunction')
            error(['Function "%s" not found but needed to support the HRTF', ...
                ' database "%s".\nSee the RAZR README for details.'], ...
                dbase.fname_params, database);
        else
            error(exc.message);
        end
    end
end

dbase.pick_hrir_func = str2func(dbase.fname_pick);

end

function dbase = parse_database(database, cfg)

% Allowed grammar for database:
%   (1) 'dbase_shortcut' (non-SOFA format)
%   (2) 'dbase_shortcut.sofa'
%   (3) 'dbase_path/to/sofa_filename.sofa'

dbase.input_string = database;
dbase.is_sofa = length(database) >= 6 && strcmpi(database((end - 4):end), '.sofa');
dbase_split = strsplit(database, {'/', '.'});
dbase_shortcut = dbase_split{1};

% Cases 2, 3:
if dbase.is_sofa
    % Case 3:
    if exist(database, 'file')
        dbase.sofa_filename = database;
    else
        if length(dbase_split) > 2
            error('Invalid name for HRTF database: %s', database);
        end
        
        sofa_fldname = sprintf('sofa_file__%s', dbase_shortcut);
        dbase.shortcut = dbase_shortcut;
        if isfield(cfg, sofa_fldname)
            dbase.sofa_filename = cfg.(sofa_fldname);
        else
            error('SOFA file shortcut "%s" not specified in razr_cfg.m. See README for details.', ...
                dbase_shortcut);
        end
    end
else
    % Case 1:
    if length(dbase_split) > 1
        error('Invalid name for HRTF database: %s', database);
    end
    
    dbase_path_fldname = sprintf('hrtf_path__%s', dbase_shortcut);
    if isfield(cfg, dbase_path_fldname)
        dbase.path = cfg.(dbase_path_fldname);
        dbase.shortcut = dbase_shortcut;
    else
        error('HRTF-database-path shortcut "%s" not specified in razr_cfg.m.', ...
            dbase_shortcut);
    end
end

end
