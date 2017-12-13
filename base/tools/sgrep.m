function fstr_out = sgrep(filename, pattern, ignore_char, do_strong)
% SGREP - Simple grep function.
% Displays lines of a file in which a search pattern is found.
% 
% Usage:
%   SGREP(filename, pattern, [ignore_char], [do_strong])
%   fstr_out = SGREP(filename, pattern, [ignore_char])
%
% Input:
%   filename        A filename
%   pattern         Search pattern (regular expression, not case-sensitive)
%   ignore_char     Lines in file starting with this character will be ignored
%                   If empty, no line will be ignored. Default: ''.
%   do_strong       If true, print found search pattern in boldface
%
% Output:
%   fstr_out        Cell array containing lines of file that contain search
%                   pattern. Search pattern is marked up to be printed bold
%                   when using FPRINTF or SPRINTF

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


if nargin < 4
    do_strong = true;
    if nargin < 3
        ignore_char = '';
    end
end

str = fileread(filename);
lines = strsplit(str, '\n');
fstr_out = {};

for n = 1:length(lines)
    if ~isempty(lines{n}) && (isempty(ignore_char) || lines{n}(1) ~= ignore_char)
        idx_start = regexpi(lines{n}, pattern);
        if ~isempty(idx_start)
            str_print = lines{n};
            
            % FIXME: instead of replacing pattern, the original string should be
            % replaced by its own boldface version. In the current way, boldface
            % is not set, e.g., for case-insensitive matchings.
            if do_strong
                str_print = strrep(str_print, pattern, boldface(pattern));
            end
            
            if nargout == 0
                fprintf('%s\n', str_print);
            else
                fstr_out = [fstr_out; str_print]; %#ok<AGROW>
            end
        end
    end
end

if nargout == 0
    clear fstr_out;
end
