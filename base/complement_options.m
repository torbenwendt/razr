function op = complement_options(options)
% COMPLEMENT_OPTIONS - Merge input options with default options
%
% Usage:
%   op = COMPLEMENT_OPTIONS(options)

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



op_default = get_default_options;

% ---- Spatialization: ----
if ~iscell(op_default.spat_mode)
    op_default.spat_mode = {op_default.spat_mode};
end

if isfield(options, 'spat_mode') && ~iscell(options.spat_mode)
    options.spat_mode = {options.spat_mode};
end
% -------------------------

if isfield(options, 'ism_only') && all(options.ism_only ~= -1)
    op_default.verbosity = 3;
end

op = overwrite_merge(options, op_default, 1, 1);

if isfield(options, 'ism_only') && all(options.ism_only ~= -1)
    op.ism_order = op.ism_only;
    op.fdn_enabled = false;
end

% Check, if there are fields in input options struct that are not in the default options:
invalid_fields = setdiff(fieldnames(op), fieldnames(op_default));

if ~isempty(invalid_fields)
    warning('The following fields of options struct are unknown: %s.', ...
        strjoin(invalid_fields, ', '));
end
