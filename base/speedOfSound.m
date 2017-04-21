function c = speedOfSound(in)
% SPEEDOFSOUND - Linear approximation of sound-propagation speed in air.
%
% Usage:
%   c = SPEEDOFSOUND
%   c = SPEEDOFSOUND(TCelsius)
%   c = SPEEDOFSOUND(room)
%
% Input:
%   (none)      A default air temperature of 20 °C is assumed
%   TCelsius    Temperature in °C
%   room        Room structure (see RAZR). If the field TCelsius exists, it will be taken into
%               account. Otherwise, the default temperature is applied.
%
% Output:
%   c           Speed of sound in m/s

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.91
%
% Author(s): Torben Wendt
%
% Copyright (c) 2014-2017, Torben Wendt, Steven van de Par, Stephan Ewert,
% Universitaet Oldenburg.
%
% This work is licensed under the
% Creative Commons Attribution-NonCommercial-NoDerivs 4.0 International
% License (CC BY-NC-ND 4.0).
% To view a copy of this license, visit
% http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
% Creative Commons, 444 Castro Street, Suite 900, Mountain View, California,
% 94041, USA.
%------------------------------------------------------------------------------


% edit 2014-08-04: TCelsius now optional
% edit 2016-06-10: room as input accepted

T_default = 20;

if nargin == 0
    TCelsius = T_default;
elseif ~isstruct(in)
    TCelsius = in;
elseif isfield(in, 'TCelsius')
    TCelsius = in.TCelsius;
else
    TCelsius = T_default;
end

c = 331.5 + 0.6*TCelsius;
