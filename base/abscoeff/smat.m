function smat(pattern)
% SMAT - Search absorbing materials. Displays available absorbing-materials that
% match a given pattern. Actually, this function is a wrapper for SGREP taking
% all files into account that are in the current MATLAB search path and whose
% filenames are "get_abscoeff_*.m".
%
% Usage:
%   SMAT pattern
%
% Input:
%   pattern     Search pattern (regular expression, not case-sensitive)
%
% See also: get_abscoeff_*, MATERIAL2ABSCOEFF, SOP, SGREP

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


if nargin == 0
    fprintf('Usage:\n    smat pattern\n');
    return;
end

fname_pattern = 'get_abscoeff_*.m';
ignore_char = '%';

searchpath = strsplit(path, pathsep);
num_paths = length(searchpath);
filenames = {};

% search for files in the matlab search path that match fname_pattern:
for n = 1:num_paths
    files = dir(fullfile(searchpath{n}, fname_pattern));
    if ~isempty(files)
        for f = 1:length(files)
            filenames = [filenames; files(f).name]; %#ok<AGROW>
        end
    end
end

for n = 1:length(filenames)
    str_print = sgrep(filenames{n}, pattern, ignore_char);
    if ~isempty(str_print)
        fprintf('\nIn %s:\n', filenames{n});
        disp(repmat('–', 1, length(filenames{n}) + 4))
        for p = 1:length(str_print)
            fprintf('%s\n', str_print{p});
        end
    end
end
