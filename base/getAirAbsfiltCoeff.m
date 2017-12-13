function [b, a] = getAirAbsfiltCoeff(distce, fs, c)
% GETAIRABSFILTCOEFF - Filter coefficients for sound attenuation due to air absorption.
% After Grimm et al.: Implementation and perceptual evaluation of a simulation method
% for coupled rooms in higher order ambisonics. Proc. of the EAA Joint Symposium on
% Auralization and Ambisonics, Berlin 2014
%
% Usage:
%   [b, a] = GETAIRABSFILTCOEFF(distce, fs, c)
%
% Eingabe:
%   distce      Vector containing source-reciever distances in m
%   fs          Sampling rate
%   c           Speed of sound in m/s
%
% Output:
%   b, a        Matrices of filter coefficient vectors in rows

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


if isrowvec(distce)
    distce = distce';
end

numDist = size(distce, 1);

alpha = 7782;
c1 = exp(-distce*fs/(c*alpha));

b = c1;
a = [ones(numDist,1), -(1 - c1)];
