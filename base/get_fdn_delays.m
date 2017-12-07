% GET_FDN_DELAYS - Get vector of delay elements for the Feedback Delay Network (FDN)
%
% Usage:
%   fdnDelays = GET_FDN_DELAYS(room, op)
%
% Input:
%   room        Room structure (see RAZR)
%   op          Options structure (see RAZR). The field 'fdn_delays_choice' specifies how the delays
%               will be calculated:
%               'roomdim2014': after Wendt et al. (2014), JAES 62,
%               'diag', 'hyp', 'hyp2', 'lin': improved methods
%
% Output:
%   fdnDelays   Vector containing the FDN delay elements, specified in samples

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.92
%
% Author(s): Torben Wendt, Stephan D. Ewert
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
