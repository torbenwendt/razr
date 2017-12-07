function ang = pm180_to_360(ang)
% PM180_TO_360 - Converts angles (in degrees) from the range -180...180 to the
% range 0...360.
%
% Usage:
%   ang360 = PM180_TO_360(ang180)
%
% Input:
%   ang180  Angles -180...180 deg
%
% Output:
%   ang360  Angles converted to 0...360 deg

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


idx = ang < 0;
ang(idx) = ang(idx) + 360;
