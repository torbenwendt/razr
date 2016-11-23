function play_demo
% PLAY_DEMO - Plays the demo created by RAZR demo.
% Note: "razr demo" must have been executed before the demo can be played.
%
% Usage:
%   PLAY_DEMO

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



% same as in razr_demo!!:
ffname = fullfile(get_razr_path, 'demo.wav');

if ~exist(ffname, 'file')
    error('Demo file not found. Run "razr demo" to create it.');
else
    if exist('audioread', 'file') || exist('audioread', 'builtin')
        audioread_fcn = @audioread;
    else
        audioread_fcn = @wavread;
    end
    
    [out, fs] = audioread_fcn(ffname);
    soundsc(out, fs);
end
