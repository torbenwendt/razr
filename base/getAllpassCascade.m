% GETALLPASSCASCADE - Calculates the filter coefficients for a cascade of
% allpass filters.
%
% Usage:
%   [b, a] = getAllpassCascade(T, gain, delay_ratio, [envtype])
%
% Input:
%   desired_grpD    Desired group delay in samples (may be fractional)
%   gain            Feedback gain
%   delay_ratio     Delay ratio
%   envtype         Smearing envelope control:
%                   0 = classic Schroeder       (4 allpasses in series)
%                   1 = more gamma like         (4 allpasses in series)
%                   2 = even more gamma like    (4 allpasses in series)
%                   3 = related to case 2       (5 allpasses in series)
%                   4 = related to case 2       (6 allpasses in series)
%                   5 = exponential like        (4 allpasses in series)
%                   6 = original by NG          (4 allpasses in series)
%                   --> Type 6 is related to the original function
%                   GETSCHROEDERREVERBERATOR.M by Nico Goessling
%                   (optional, default: 6)
%
% Output:
%   b, a            Filter coefficients
%   grpD            Resulting group delay in samples

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.93
%
% Author(s): Oliver Buttler, Stephan D. Ewert, Torben Wendt
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
