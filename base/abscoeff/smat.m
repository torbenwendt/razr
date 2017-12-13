function smat(pattern)
% SMAT - Search and display available absorbing materials that match a specified
% pattern. All m-files are taken into account that are in the current MATLAB
% search path and whose filenames are "get_abscoeff_*.m".
%
% Usage:
%   SMAT pattern
%
% Input:
%   pattern     Search pattern (regular expression, not case-sensitive)
%
% Example:
%   >> smat plaster
%
%   In get_abscoeff_hall.m:
%   -----------------------
%   Frequencies:     [  125    250    500   1000   2000   4000] Hz
%   plaster_sprayed: [ 0.50   0.70   0.60   0.70   0.70   0.50] (acoustic plaster, sprayed)
%   plaster_on_lath: [ 0.20   0.15   0.10   0.05   0.04   0.05] (plaster, on lath)
%
% Known issues/limitations:
%   - SMAT will not work properly if the specified absorption coefficients in
%     get_abscoeff_*.m contains line breaks using ellipses (...)
%   - In get_abscoeff_*.m, absorption coefficients must be stored as a field of
%     a structure named "absco". See GET_ABSCOEFF_HALL for details.
%
% See also: GET_ABSCOEFF_HALL, MATERIAL2ABSCOEFF, SOP, SGREP

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


if nargin == 0 || isempty(pattern)
    fprintf('Usage:\n    smat pattern\n');
    return;
end

fname_pattern = 'get_abscoeff_*.m';
ignore_file   = 'get_abscoeff_legacy.m';
ignore_char = '%';
fieldname_absco = 'absco';
idx_start_dbname = strfind(fname_pattern, '*');

searchpath = strsplit(path, pathsep);
num_paths = length(searchpath);
filenames = {};
do_strong = false;

% search for files in the matlab search path that match fname_pattern:
for n = 1:num_paths
    files = dir(fullfile(searchpath{n}, fname_pattern));
    if ~isempty(files)
        for f = 1:length(files)
            if ~strcmp(files(f).name, ignore_file)
                filenames = [filenames; files(f).name]; %#ok<AGROW>
            end
        end
    end
end

%%
for n = 1:length(filenames)
    str_print = sgrep(filenames{n}, pattern, ignore_char, do_strong);
    
    % extract only lines that contain actual data (filter for 'absco.'):
    idx_invalid_lines = ...
        cellfun(@(x) (isempty(strfind(x, [fieldname_absco, '.']))), str_print);
    str_print(idx_invalid_lines) = [];
    
    if ~isempty(str_print)
        [pth, funcname] = fileparts(filenames{n});
        func = str2func(funcname);
        db = func();
        
        % print filename:
        [pth, dbname] = fileparts(filenames{n}(idx_start_dbname:end));
        fname_print = strrep(filenames{n}, dbname, boldface(dbname));
        fprintf('\nIn %s:\n', fname_print);
        disp(repmat('-', 1, length(filenames{n}) + 4))
        
        % frequencies:
        freqstr = deblank(sprintf('%5d  ', db.freq));
        freqliteral = 'Frequencies';
        
        % material names:
        [fields, commts, whitesp, len_field] = parse_lines(str_print, fieldname_absco);
        
        num_add_space = abs(length(freqliteral) - len_field);
        if length(freqliteral) > len_field
            add_space_freql = '';
            add_space_field = repmat(' ', 1, num_add_space);
        else
            add_space_freql = repmat(' ', 1, num_add_space);
            add_space_field = '';
        end
        
        % print frequencies:
        fprintf('%s: %s[%s] Hz\n', freqliteral, add_space_freql, freqstr);
        
        % print materials:
        for p = 1:length(str_print)
            data = deblank(sprintf('% 1.2f  ', db.(fieldname_absco).(fields{p})));
            field = strrep(fields{p}, pattern, boldface(pattern));
            if ~isempty(commts{p})
                commt = strrep(commts{p}, pattern, boldface(pattern));
                commt = ['(', commt, ')']; %#ok<AGROW>
            else
                commt = '';
            end
            fprintf('%s: %s%s[%s] %s\n', field, add_space_field, whitesp{p}, data, commt);
        end
        
        fprintf(['\n-> To use materials from this database specify, e.g.,\n', ...
        '   room.materials = {%s:%s, ...};\n'], boldface(dbname), fields{1});
    end
end

end

function [fields, commts, whitesp, maxlen] = parse_lines(strs, fieldname_absco)
% Parse lines for material names (fieldnames) and comments. Create whitespace
% to align abscoeffs

numStr = length(strs);
fields = cell(numStr, 1);
commts = cell(numStr, 1);
whitesp = cell(numStr, 1);

for n = 1:numStr
    idx_absco = strfind(strs{n}, fieldname_absco);
    spl = strsplit(strs{n}(idx_absco:end), {'.', '='});  % '.' from "struct.field"
    
    if length(spl) >= 2
        fields{n} = strtrim(spl{2});
    else
        error('Bad format.')
    end
    % get comment if exists:
    spl_comm = strsplit(strs{n}, '%');
    if length(spl_comm) > 1
        commts{n} = strtrim(strjoin(spl_comm(2:end), '%'));  % restore potential remaining '%'
    else
        commts{n} = '';
    end
end

maxlen = max(cellfun(@length, fields));

for n = 1:numStr
    whitesp{n} = repmat(' ', 1, maxlen - length(fields{n}));
end

end
