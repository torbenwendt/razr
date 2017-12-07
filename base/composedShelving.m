function [b, a, B, A] = composedShelving(desiredFrqRsp, freq, fs, type, M, linGain)
% COMPOSEDSHELVING - Get coefficients for composed shelving filters, to approximate specified
% frequency response. The resulting filter has the order length(freq)*2+1.
%
% Usage:
%   [b, a] = COMPOSEDSHELVING(desiredFrqRsp, freq, fs, type, M, linGain)
%
% Input:
%   desiredFrqRsp   Desired frequency response, values in dB or linear (specified by input parameter 'linGain')
%   freq            Frequency base, must have the same length as desiredFrqRsp
%   fs              Sampling rate
%   type            Type of shelving filters: 'peak': Peak-Shelving, 'low': Low-Shelving ('low' doesn't work, sorry)
%   M               Order of each shelving filter (I'm sorry, but this function works for M = 1 only)
%   linGain         Set true, if dGain values are linear attenuation factors, false if they are specified in dB
%
% Output:
%	b, a            Filter coefficient vectors of the resulting EQ
%   B, A            Filter coefficient vectors of all sigle filters, stored as matrix

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
    materials = {...
        'hall.concrete_block_painted'; 'hall.windowglass'; ...
        'hall.draperies'; 'hall.carpet_on_conc'};
    
    freq = [250, 500, 1e3, 2e3, 4e3];
    desiredFrqRsp = material2abscoeff(materials, freq);
    
    w = 4;
    testdata = desiredFrqRsp(w, :);
    
    %freq     = [125,  250, 500, 1e3, 2e3, 4e3];
    %testdata = [0.07, 0.3, 0.5, 0.7, 0.7, 0.6];
    
    linGain = 1;
    fs = 44100;
    type = 'peak';
    M = 1;
    
    freq = freq(1:size(testdata,2));
    
    [b,a] = composedShelving(testdata, freq, fs, type, M, linGain);
    
    figure
    plotFrqRsp(b,a,fs);
    hold on
    semilogx(freq,20*log10(testdata), 's', 'color', 'k', 'markerfacecolor', 'w');
    
    %title(materials{w})
    ylim([-40 0])
    
    return;
end

%%

numFrq = size(desiredFrqRsp, 2);

% shelvingM() with 1st order yields coefficient vectors of this length:
peak_coefflen = 3*strcmp(type, 'peak') + 2*strcmp(type, 'low');

coefflen = (M*(peak_coefflen - 1) + 1);     % shelvingM() with M-th order yields coefficient vectors of this length
convlen = @(n) (n*(coefflen - 1) + 1);      % length of coefficient convolution product after n convolutions

% prealloc:
b = [1, zeros(1, convlen(numFrq) - 1)];
a = b;

if strcmp(type,'peak')
    
    % Approach for filter synthesis:
    % - normalize original data points to their mean (such that they are closer to 0 dB)
    % - create peak filter composition
    % - shift composition by data point mean
    
    if (M~=1)
        error('rirsynth:composedShelving:peak shelving filter only works for M=1');
    end
    
    shift = mean(desiredFrqRsp);
    
    normedFrqRsp = desiredFrqRsp/shift;
    
    for f = 1:numFrq
        
        [b1, a1] = shelvingM(freq(f), freq(f), fs, normedFrqRsp(f), M, type, linGain);
        
        b(1:convlen(f)) = conv(b(1:convlen(f - 1)), b1);
        a(1:convlen(f)) = conv(a(1:convlen(f - 1)), a1);
        B(f, :) = b1;
        A(f, :) = a1;
    end
    
    b = b*shift;
    B = B*shift^(1/numFrq);
    
    
elseif strcmp(type,'low')
    
    for f = 1:numFrq-1
        
        [b1, a1] = shelvingM(freq(f), geomean(freq(f), freq(f + 1)), fs, ...
            [desiredFrqRsp(f), desiredFrqRsp(f + 1)], M, type, linGain);
        
        b(1:convlen(f)) = conv(b(1:convlen(f - 1)), b1);
        a(1:convlen(f)) = conv(a(1:convlen(f - 1)), a1);
        B(f, :) = b1;
        A(f, :) = a1;
    end
    
end

