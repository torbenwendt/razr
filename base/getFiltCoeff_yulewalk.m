function [b, a] = getFiltCoeff_yulewalk(freq, ampl, fs, N, makePlot)
% GETFILTCOEFF_YULEWALK - Get coefficients for filter approximating specified
% frequency response, using the Matlab function YULEWALK.
%
% Usage:
%	[b,a] = GETFILTCOEFF_YULEWALK(freq, ampl, fs, N, [makePlot])
%
% Input:
%	freq		Frequency base in Hz
%	ampl		Amplitudes of desired frequency responses as matrix; frequency responses in rows
%	fs			Sampling rate
%	N			Filter order
%	makePlot	If true, plot frequency responses (optional, default: false)
%
% Output:
%	b, a		Filter coefficients as matrix; rows represent filters
%
% See also: YULEWALK

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


%% test call

if nargin == 0
    N = 16;
    materials = {'hall.carpet_on_conc'; 'hall.plaster_sprayed'; 'hall.windowglass'};
    fs = 44100;
    freq = [250 500 1e3 2e3 4e3];
    abscoeff = material2abscoeff(materials, freq);
    absolRefl = sqrt(1 - abscoeff);
    
    [b, a] = getFiltCoeff_yulewalk(freq, absolRefl, fs, N, true);
    return;
end

%% input parameters

if nargin < 5
    makePlot = 0;
end

%% error handling

if ~issorted(freq)
    error('Frequencies must be sorted.');
end
if max(freq) > fs/2
    error('Maximum frequency must not larger than half of sampling rate.');
end

[numRsp, numFrq] = size(ampl);

if numFrq~=length(freq)
    error('Number of columns of ampl must equal the number of frequencies.');
end

%%

fnorm = 2*freq/fs;

% yulewalk needs normed frequencies 0 and 1:

% thresh = min(abs(fnorm(1:numFrq-1)-fnorm(2:numFrq)));
% thresh = 1e-3*min(abs(freq(1:numFrq-1)-freq(2:numFrq)));

if freq(1) ~= 0
    fnorm = [0, fnorm];
    freq  = [0, freq];
    ampl  = [ampl(:,1), ampl];
    % else
    % 	fnorm(1) = round(fnorm);
end

if freq(numFrq)~=fs/2
    fnorm = [fnorm, 1];
    freq  = [freq, fs/2];
    ampl  = [ampl, ampl(:,numFrq)];
    % else
    % 	fnorm(numFrq) = round(fnorm(numFrq));
end

% prealloc:
b = zeros(numRsp, N+1);
a = b;

for n = 1:numRsp
    [b(n,:), a(n,:)] = yulewalk(N, fnorm, ampl(n,:));
end


%% Plot

if makePlot
    figure
    for n = 1:numRsp
        [h, w] = freqz(b(n, :), a(n, :), 128);
        
        plot(freq, 20*log10(ampl(n, :)), 'ko-')
        hold on
        plot(w/pi*fs/2, 20*log10(abs(h)))
    end
    
    xlim([1e2, fs/2])
    ylim([-6, 0])
    set(gca, 'xscale', 'log')
end




