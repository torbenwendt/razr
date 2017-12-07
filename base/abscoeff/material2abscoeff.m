function abscoeff = material2abscoeff(materials, desired_freq)
% MATERIAL2ABSCOEFF - Extract absorption coefficients from databases on the
% basis of specified material names. Databases are stored in functions
% get_abscoeff_<dbase_name>.m.
%
% Usage:
%   abscoeffs = MATERIAL2ABSCOEFF(materials, desired_freq)
%
% Input:
%   materials       String or cell array of strings of the form
%                   "dbase_name.material", where "dbase_name" is the name of an
%                   absorbing-material database that contains absorption
%                   coefficients stored under the name "material". For details
%                   and an example, see GET_ROOM_L.M.
%   desired_freq    Frequency base (in Hz) for absorption coefficients.
%                   Frequencies must be available in all chosen databases.
%
% Example:
%   Load absorption coefficients from the "hall" database, stored in
%   get_abscoeff_hall.m:
% 
%   >> abscoeffs = material2abscoeff(...
%           {'hall.brick', 'hall.draperies'}, [250, 500, 1e3, 2e3, 4e3])
%   ans =
%       0.0300    0.0300    0.0300    0.0400    0.0500    0.0700
%       0.0700    0.3000    0.5000    0.7000    0.7000    0.6000
% 
% See also: get_abscoeff_*, SMAT, ADD_ABSCOEFF

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


if ~iscell(materials)
    materials = {materials};
end

sep = '.';
[db_names, mats] = ...
    cellfun(@(x) (parse_matkey(x, sep)), materials, 'UniformOutput', false);

dbases = get_abscoeff_dbases(unique(db_names));
abscoeff = extract_abscoeffs(dbases, db_names, mats, desired_freq);

end

% ------------------------------------------------------------------------------
function [dbase, material] = parse_matkey(matkey, sep)

parts = strsplit(matkey, sep);

if length(parts) ~= 2 || any(cellfun(@isempty, parts))
    % handle legacy format (e.g., 'brick' instead of 'hall.brick'):
    if length(parts) == 1
        db = get_abscoeff_legacy;
        if isfield(db.absco, parts{1})
            dbase = 'legacy';
            material = parts{1};
            warning_msg = ['Use new format to specify absorbing materials.', ...
                ' See help razr for details. Legacy database is used.'];
            % display warning only once:
            if ~strcmp(lastwarn, warning_msg)
                warning(warning_msg);
            end
            return;
        end
    end
    error(['Absorbing material not well-formatted: %s. ', ...
        'Must be in the form ''dbase.material''.'], matkey);
end

dbase = parts{1};
material = parts{2};

end

% ------------------------------------------------------------------------------
function dbases = get_abscoeff_dbases(db_names_unique)

for n = 1:length(db_names_unique)
    fname = sprintf('get_abscoeff_%s', db_names_unique{n});
    get_abscoeff_func = str2func(fname);
    try
        dbases.(db_names_unique{n}) = get_abscoeff_func();
    catch exc
        if strcmp(exc.identifier, 'MATLAB:UndefinedFunction')
            error(['Absorbing-material database not found: "%s".\n', ...
                'Must be stored in a function called "%s".\n', ...
                'See help get_abscoeffs for details.'], ...
                db_names_unique{n}, fname);
        else
            error(exc.message);
        end
    end
end

end

% ------------------------------------------------------------------------------
function abscoeff = extract_abscoeffs(dbases, db_names, mats, desired_freq)

freq_idx = extract_freq_idx(dbases, desired_freq);

num_mats = length(mats);
num_freq = length(desired_freq);

abscoeff = zeros(num_mats, num_freq);

for n = 1:num_mats
    try
        abscoeff(n, :) = ...
            dbases.(db_names{n}).absco.(mats{n})(freq_idx.(db_names{n}));
    catch exc
        if strcmp(exc.identifier, 'MATLAB:nonExistentField')
            error('No absorbing material "%s" in database "%s".', ...
                mats{n}, db_names{n});
        else
            error(exc.message);
        end
    end
end

end

% ------------------------------------------------------------------------------
function fidx = extract_freq_idx(dbases, desired_freq)

fldnames = fieldnames(dbases);
num_db = length(fldnames);

for idx_db = 1:num_db
    avail_freq = dbases.(fldnames{idx_db}).freq;
    fidx.(fldnames{idx_db}) = zeros(1, length(desired_freq));
    
    % search indices of avail_freq, which refer to the values of desired_freq:
    for n = 1:length(desired_freq)
        fidx_tmp = find(avail_freq == desired_freq(n));
        if ~isempty(fidx_tmp)
            fidx.(fldnames{idx_db})(n) = fidx_tmp;
        else
            error(['Frequency %g Hz not available in absorption-', ...
                'coefficient database "%s"'], desired_freq(n), fldnames{idx_db});
        end
    end
end

end
