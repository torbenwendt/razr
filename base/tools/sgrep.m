function fstr_out = sgrep(filename, pattern, ignore_char)
% SGREP - Simple grep function.
% Displays lines of a file in which a search pattern is found.
% 
% Usage:
%   SGREP(filename, pattern, [ignore_char])
%   fstr_out = SGREP(filename, pattern, [ignore_char])
%
% Input:
%   filename        A filename
%   pattern         Search pattern (regular expression, not case-sensitive)
%   ignore_char     Lines in file starting with this character will be ignored
%                   If empty, no line will be ignored. Default: ''.
%
% Output:
%   fstr_out        Cell array containing lines of file that contain search
%                   pattern. Search pattern is marked up to be printed bold
%                   when using FPRINTF or SPRINTF

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


if nargin < 3
    ignore_char = '';
end

str = fileread(filename);
lines = strsplit(str, '\n');
fstr_out = {};

for n = 1:length(lines)
    if ~isempty(lines{n}) && (isempty(ignore_char) || lines{n}(1) ~= ignore_char)
        [idx_start, idx_end] = regexpi(lines{n}, pattern);
        if ~isempty(idx_start)
            str_print = strrep(lines{n}, ...
                lines{n}(idx_start:idx_end), ...
                ['<strong>', lines{n}(idx_start:idx_end), '</strong>']);
            if nargout == 0
                fprintf('%s\n', str_print);
            else
                fstr_out = [fstr_out; str_print];
            end
        end
    end
end

if nargout == 0
    clear fstr_out;
end
