function eq = load_headphone_eq(headphone_key, fs)
% LOAD_HEADPHONE_EQ - Get impulse response for headphone equalization.
%
% Usage:
%   eq = GET_HEADPHONE_EQ(headphone_key, fs)
%
% Input:
%   headphone_key   Key string to specify headphone type
%   fs              Sampling rate in Hz
%
% For supported headphones and sampling rates, and how to add own equalizations, see
% RAZR_CFG_DEFAULT and RAZR_CFG.
%
% Output:
%   eq          Inverse impulse response
%
% See also: RAZR_CFG_DEFAULT, RAZR_CFG

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


cfg = get_razr_cfg;
fname = cfg.(sprintf('hp_eq__%s_%d', headphone_key, floor(fs)));

data = load(fname);
flds = fieldnames(data);
eq = data.(flds{1});
