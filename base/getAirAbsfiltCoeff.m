function [b, a] = getAirAbsfiltCoeff(distce, fs, c, makePlot)
% GETAIRABSFILTCOEFF - Filter coefficients for sound attenuation due to air absorption.
% After Grimm et al.: Implementation and perceptual evaluation of a simulation method
% for coupled rooms in higher order ambisonics. Proc. of the EAA Joint Symposium on
% Auralization and Ambisonics, Berlin 2014
%
% Usage:
%	[b, a] = GETAIRABSFILTCOEFF(distce, fs, [c], [makePlot])
%
% Eingabe:
%	distce		Vector containing source-reciever distances in m
%	fs			Sampling rate
%	c			Speed of sound (optional, default: speedOfSound(20))
%	makePlot	If true, make test plot for frequency responses (optional, default: false)
%
% Output:
%	b, a		Matrices of filter coefficient vectors in rows

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.90
%
% Author(s): Torben Wendt
%
% Copyright (c) 2014-2016, Torben Wendt, Steven van de Par, Stephan Ewert,
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


%% test call

if nargin == 0
    distce   = 0:20:100;
    fs       = 44100;
    c        = speedOfSound(20);
    makePlot = 1;
    
    [b, a] = getAirAbsfiltCoeff(distce, fs, c, makePlot);
    
    return;
end

%% input parameters

if nargin < 4
    makePlot = 0;
    if nargin < 3
        c = [];
    end
end

if isempty(c)
    c = speedOfSound(20);
end

%%

if isrowvec(distce)
    distce = distce';
end

numDist = size(distce, 1);

alpha = 7782;
c1 = exp(-distce*fs/(c*alpha));

b = c1;
a = [ones(numDist,1), -(1 - c1)];

%%

if makePlot
    figure
    plotFrqRsp(b, a, fs);
    ylim([-20 0])
end
