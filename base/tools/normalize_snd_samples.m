function snd_norm_rms = normalize_snd_samples(snds, thresh_rms_level, maxval)
% NORMALIZE_SND_SAMPLES - Normalize sound samples to their thresh_rms() and apply a common scaling
% factor such that the maximum of the largest signal is maxval (input parameter, see below).
%
% Usage:
%   snds = NORMALIZE_SND_SAMPLES(snds, maxval)
%
% Input:
%   snds                Cell array containing sound samples
%   thresh_rms_level    Threshold level for thresh_rms().
%   maxval              Maximum value of largest signal after normalization
%
% See also: APPLY_RIR

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


numSnds = length(snds);

for n = numSnds:-1:1
    % stereo2mono:
    snds{n} = mean(snds{n}, 2);
    
    snd_norm_rms{n} = snds{n}/thresh_rms(snds{n}, thresh_rms_level);
    sigmax(n) = max(abs(snd_norm_rms{n}));
end

sigmaxmax = max(sigmax);

for n = 1:numSnds
    snd_norm_rms{n} = snd_norm_rms{n}/sigmaxmax*maxval;
end
