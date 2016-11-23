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
