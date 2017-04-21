function [out, in_respl] = apply_rir(ir, varargin)
% APPLY_RIR - Convolve RIR with one or several dry test signals.
%
% Usage:
%	[out, in_respl] = APPLY_RIR(ir)
%	[out, in_respl] = APPLY_RIR(ir, Name, Value)
%
% Input:
%	ir          RIR structure (see RAZR)
%
% Optional Name-Value-pair arguments:
%   src         Dry test signals or cell array of multiple test signals, specified as ...
%               - Soundfile names (including absolute or relative path if the file is not in the
%                 Matlab search path). If your Matlab version contains AUDIOREAD, all file formats
%                 supported by that function are possible, otherwise only wav files are supported.
%               - Key strings for sound samples specified in RAZR_CFG_DEFAULT and RAZR_CFG.
%                 By default, the following keys are supported: 'olsa1', 'olsa2', 'olsa3'. These
%                 refer to sound examples taken from the Oldenburg Sentence Test for the AFC
%                 Software Package by Stephan Ewert, Daniel Berg, Hoertech gGmbH. See also
%                 ANALYSIS_TOOLS/SAMPLES/OLSA_README.TXT.
%                 Own samples can be used, whose key strings and location on your harddrive have to
%                 be specified in RAZR_CFG.
%               - Sound signal as a matrix. The same sampling rate as of ir will be assumed.
%               Specifications of multiple sounds can be mixed, i.e. the cell array can look like,
%               e.g., {'olsa', rand(44100, 2), 'path/to/soundfile.wav', ...}.
%               Default: 'olsa1'.
%   eq          Headphone type key string. Currently supported: 'hd650' or 'none'. Own equalizations
%               can be used. For details, see RAZR_CFG_DEFAULT.
%               Default: Specified in RAZR_CFG_DEFAULT or, potentially overwritten, in RAZR_CFG
%   normalize   If true, normalize output signals to 0.99 (default: true)
%   cconvlen    For circular convolution (using cconv), cconvlen specifies the convolution length in
%               samples. If not specified or set to zero or empty, no circular convolution will be
%               performed. If set to -1, cconvlen will be set to each of the lengths of the dry
%               source signals, respectively.
%   thresh_rms_params = [thresh_db, maxval], where trhesh_db is the threshold for
%               thresh_rms calculation (see THRESH_RMS) and maxval is the maximum value the signal
%               is normalized to (has only an effect, if do_normalize == false). Default behaviour:
%               no application of THRESH_RMS.
%
% Output:
%	out         Cell array of convolved signals (sampling rate same as for ir)
%	in_respl	Dry source signals (resampled to same sampling rate as ir, if original differs)
%
% See also: RAZR_CFG_DEFAULT, THRESH_RMS, SOUNDIR

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.91
%
% Author(s): Torben Wendt
%
% Copyright (c) 2014-2017, Torben Wendt, Steven van de Par, Stephan Ewert,
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


%% input

if isempty(fieldnames(ir))
    return;
end

cfg = get_razr_cfg;
check_thresh = @(x) (length(x) == 2 || isempty(x));

p = inputParser;
addparam = get_addparam_func;
addparam(p, 'src', 'olsa1');
addparam(p, 'eq', cfg.default_headphone);
addparam(p, 'normalize', true);
addparam(p, 'cconvlen', []);
addparam(p, 'thresh_rms_params', [], check_thresh);

parse(p, varargin{:});

%% apply headphone eq

if ~strcmp(p.Results.eq, 'none')
    eq = load_headphone_eq(p.Results.eq, ir.fs);
    for n = 1:size(ir.sig, 2)
        ir.sig(:, n) = filter(eq, 1, ir.sig(:, n));
    end
end

%%

if iscell(p.Results.src)
    srcsig = p.Results.src;
else
    srcsig = {p.Results.src};
end

numSrc = length(srcsig);

in_respl = cell(numSrc, 1);
out      = cell(numSrc, 1);

if exist('audioread', 'file') || exist('audioread', 'builtin')
    audioread_fcn = @audioread;
else
    audioread_fcn = @wavread;
end

for n = 1:numSrc
    if isnumeric(srcsig{n})
        in = srcsig{n};
        fs = ir.fs;
    else
        fldname = sprintf('sample__%s', srcsig{n});
        if isfield(cfg, fldname)
            [in, fs] = audioread_fcn(cfg.(fldname));
        elseif exist(srcsig{n}, 'file')
            [in, fs] = audioread_fcn(srcsig{n});
        else
            error('Sound sample ID unknown or file not found: %s', srcsig{n});
        end
    end
    
    % stereo2mono:
    if size(in, 2) == 2
        in = mean(in, 2);
    end
    
    % resample:
    if ir.fs ~= fs
        in_respl{n} = resample(in, ir.fs, fs);
    else
        in_respl{n} = in;
    end
end

if ~isempty(p.Results.thresh_rms_params)
    in_respl = normalize_snd_samples(...
        in_respl, p.Results.thresh_rms_params(1), p.Results.thresh_rms_params(2));
end

for n = 1:numSrc
    if isempty(p.Results.cconvlen) || p.Results.cconvlen == 0
        % pad zeros (space for reverb):
        in_respl{n} = [in_respl{n}; zeros(size(ir.sig, 1), 1)];
        
        out{n} = [...
            dlfconvComp(in_respl{n}, ir.sig(:, 1)), ...
            dlfconvComp(in_respl{n}, ir.sig(:, end))];
    else
        if p.Results.cconvlen == -1
            cconvlen = size(in_respl{n}, 1);
        else
            cconvlen = p.Results.cconvlen;
        end
        
        out{n} = [...
            cconv(in_respl{n}, ir.sig(:, 1  ), round(cconvlen)), ...
            cconv(in_respl{n}, ir.sig(:, end), round(cconvlen))];
    end
    
    if p.Results.normalize
        out{n} = 0.99*out{n}./(max(max(abs(out{n}))));
    end
end
