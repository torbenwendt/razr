function [D, C, limits_sec] = definition_clarity(ir, varargin)
% DEFINITION_CLARITY - Calculation of definition and clarity index from RIR.
%
% Usage:
%   [D, C, upperlim] = DEFINITION_CLARITY(ir, Name, Value)
%
% Input:
%   ir          RIR structure (see RAZR)
%
% Optional Name-Value-pair arguments (defaults in parentheses):
%   upperbound  ('irlen') Upper integration limit, in sec. or as key string. Has only an effect if
%               the whole RIR or the late part is taken into account (see argument 'parts').
%               Possible key strings:
%               'irlen': take full ir length
%               'lundeby': calculation using LUNDEBY_CROSSPOINT
%   trim        (true) If true, use the field ir.start_spl (if it exists) to remove the first
%               samples before the direct sound
%   sliding_upperlim
%               (false) If true, calculate definition and clarity for a sliding upper integration
%               limit. The stepsize is specified by the parameter 'stepsize' (see next parameter).
%               If false, calculate the classical definition D50 and clarity index C80.
%   stepsize    (25e-3) Stepsize (in sec) for sliding upper integration limit (see prev. parameter)
%
% Output:
%   D           Definition (single value or vector, depending on 'sliding_upperlim')
%   C           Clarity index in dB (single value or vector, depending on 'sliding_upperlim')
%   upperlim    Upper integration limits.
%
% See also: LUNDEBY_CROSSPOINT

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


%% testing mode

if nargin == 0
    fprintf('definition_clarity: testing mode\n');
    
    ir.fs = 44100;
    len = 44100;
    t_s = timevec(len, ir.fs);
    
    ir.sig = (2*rand(len, 2) - 1).*exp(-repmat(1e3*t_s', 1, 2)/(len/1000))*0.7;
    ir.sig(1,1) = 1;
    ir.sig(1,2) = 0.8;
    
    zlen = 10e-3*ir.fs;                 % Nullen am Anfang = Direktschallverzoegerung
    ir.sig = [1e-3*(2*rand(zlen,2)-1); ir.sig(1:end-zlen,:)];
    
    ir.start_spl = zlen;
end

%% input parameters

p = inputParser;
addparam = get_addparam_func;
addparam(p, 'upperbound', 'irlen');
addparam(p, 'trim', true);
addparam(p, 'sliding_upperlim', false);
addparam(p, 'stepsize', 25e-3);

parse(p, varargin{:});

if ischar(p.Results.upperbound)
    switch p.Results.upperbound
        case 'irlen'
            upperbound = size(ir.sig, 1)/ir.fs;
        case 'lundeby'
            upperbound = lundeby_crosspoint(ir);
        otherwise
            error('Unknown upperbound specification: %s', p.Results.upperbound);
    end
else
    upperbound = p.Results.upperbound;
end

%% remove silence before direct sound

if p.Results.trim && isfield(ir, 'start_spl')
    ir.sig = ir.sig(ir.start_spl:end,:);
    trimmed = true;
else
    trimmed = false;
end

len = size(ir.sig, 1);

%%

% upper integration limits in sec:
if p.Results.sliding_upperlim
    limits_sec = p.Results.stepsize:p.Results.stepsize:upperbound;
    limit_D = limits_sec;
    limit_C = limits_sec;
else
    limit_D = 50e-3;
    limit_C = 80e-3;
    limits_sec = [limit_D, limit_C];
end

% sec2spl:
upperbound_spl = floor(upperbound*ir.fs);

if trimmed
    upperbound_spl = upperbound_spl - ir.start_spl + 1;
end

if upperbound_spl > len
    warning(['definition_clarity: upperbound is larger than signal length. ', ...
        'The whole signal will be taken into account.']);
    upperbound_spl = len;
end

limit_D = round(limit_D*ir.fs);
limit_C = round(limit_C*ir.fs);

t_s = timevec(len, ir.fs);
ir2 = mean(ir.sig.^2, 2);
erg = cumtrapz(t_s, ir2);

% definition:
D = erg(limit_D)./erg(upperbound_spl);

% claritiy index:
C = 10*log10(erg(limit_C)./(erg(upperbound_spl) - erg(limit_C)));

%% testing mode
if nargin == 0
    figure
    p1 = plot(t_s*1e3, ir2);
    hold on
    p2 = plot(t_s*1e3, erg*100, 'r');
    legend([p1, p2], {'RIR^2', 'int(RIR^2)'})
end
