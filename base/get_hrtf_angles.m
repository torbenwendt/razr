function [hrir_angles, p, lrscale, relcoo] = get_hrtf_angles(room, cube, numAng, diagchoice)
% GET_HRTF_ANGLES - Calculates angles (relative to receiver) for virtual reverb sources
%
% Usage:
%   [hrir_angles, p, lrscale, relcoo] = GET_HRTF_ANGLES([room], [cube], [numAng])
%
% Input:
%   room            room structure (see RAZR)
%   cube            if true: virtual reverb sources on cube surface around receiver (otherwise on
%                   actual walls)
%   numAng          Number of angles being returned (order according to map_roomdim_Idx_2_ch()).
%   diagchoice      If numAng == 12, this parameter specifies the choice of two possible diagonals
%                   on cube (or wall) surfaces on which the virtual reverb sources are placed.
%                   Possible input: 1 or 2. Optional, default: 1.
%
%   If no input parameter is specified, a demo plot is created.
%
% Output:
%   hrir_angles     [azim, elev] angles
%   p               actual positions of reverb sources
%   lrscale         scaling factors [lscale, rscale] for left and right channal amplitudes per point
%                   (used for stereo panning, if ILDs are applied instead of HRTFs)
%   relcoo          positions of reverb sources, relative to receiver

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


%% test run

if nargin == 0
    room.boxsize = [5, 1.2, 0.5];
    room.recpos  = [2.1, 0.6, 0.25];
    room.recdir = [0 0];
    
    cube = 1;
    numAng = 12;
    
    [ans0, p, ans0, r] = get_hrtf_angles(room, cube, numAng);
    
    figure;
    plot3(p(:, 1), p(:, 2), p(:, 3), '*');
    hold on
    if cube
        plotbox(gca, ones(1, 3), room.recpos - [1 1 1]/2);
    end
    plotbox(gca, room.boxsize, [0 0 0]);
    plot3(room.recpos(1), room.recpos(2), room.recpos(3),'ro');
    xlabel('x')
    ylabel('y')
    zlabel('z')
    set(gca, 'DataAspectRatio', [1 1 1]);
    grid on;
    
    figure;
    plot3(r(:, 1), r(:, 2), r(:, 3), '*');
    hold on
    plot3(0,0,0, 'ro');
    xlabel('x')
    ylabel('y')
    zlabel('z')
    set(gca,'DataAspectRatio', [1 1 1]);
    grid on;
    title('relcoo')
    
    return;
end

%%

if nargin < 4
    diagchoice = 1;
    if nargin < 3
        numAng = 12;
        if nargin < 2
            cube = true;
        end
    end
end

if all(numAng ~= [12, 24])
    error('numAng must be 12 or 24');
end

if all(diagchoice ~= [1, 2])
    error('diagchoice must be 1 or 2');
end

%%

if cube
    b = ones(1,3);
    recpos = b/2;       % receiver in central point
else
    b = room.boxsize;
    recpos = room.recpos;
end

% points on cuboid surfaces
% (order is in line with the standard order for walls used in all other functions,
% especially in fdn-channel-to-wall matching):
if diagchoice == 1 || numAng == 24
    p1 = zeros(12, 3);
    p1(1,:)  = [1 1 0].*b * 1/3;                 % -z
    p1(2,:)  = [1 0 1].*b * 1/3;                 % -y
    p1(3,:)  = [0 1 1].*b * 1/3;                 % -x
    p1(4,:)  = [1 0 1].*b + [0 1 -1].*b*1/3;     % +x
    p1(5,:)  = [1 1 0].*b + [-1 0 1].*b*1/3;     % +y
    p1(6,:)  = [1 0 1].*b + [-1 1 0].*b*1/3;     % +z
    p1(7,:)  = [1 1 0].*b * 2/3;                 % -z
    p1(8,:)  = [1 0 1].*b * 2/3;                 % -y
    p1(9,:)  = [0 1 1].*b * 2/3;                 % -x
    p1(10,:) = [1 0 1].*b + [0 1 -1].*b*2/3;     % +x
    p1(11,:) = [1 1 0].*b + [-1 0 1].*b*2/3;     % +y
    p1(12,:) = [1 0 1].*b + [-1 1 0].*b*2/3;     % +z
else
    p1 = [];
end

% points on diagonals opposing to the first ones:
if diagchoice == 2 || numAng == 24
    p2 = zeros(12, 3);
    p2(1,:)  = [1 0 0].*b + [-1 1 0].*b*1/3;     % -z
    p2(2,:)  = [1 0 0].*b + [-1 0 1].*b*1/3;     % -y
    p2(3,:)  = [0 1 0].*b + [0 -1 1].*b*1/3;     % -x
    p2(4,:)  = [1 0 0].*b + [0  1 1].*b*1/3;     % +x
    p2(5,:)  = [0 1 0].*b + [1  0 1].*b*1/3;     % +y
    p2(6,:)  = [0 0 1].*b + [1  1 0].*b*1/3;     % +z
    p2(7,:)  = [1 0 0].*b + [-1 1 0].*b*2/3;     % -z
    p2(8,:)  = [1 0 0].*b + [-1 0 1].*b*2/3;     % -y
    p2(9,:)  = [0 1 0].*b + [0 -1 1].*b*2/3;     % -x
    p2(10,:) = [1 0 0].*b + [0  1 1].*b*2/3;     % +x
    p2(11,:) = [0 1 0].*b + [1  0 1].*b*2/3;     % +y
    p2(12,:) = [0 0 1].*b + [1  1 0].*b*2/3;     % +z
else
    p2 = [];
end

p = [p1; p2];

% coordintes, relative to receiver
relcoo = p - repmat(recpos, numAng, 1);

% random jitter:
if 0
    rand_factor = 0.0;
    relcoo = relcoo .* (1 + rand_factor*(2*rand(numAng, 3) - 1));
end

[azim, elev] = cart2sph(relcoo(:, 1), relcoo(:, 2), relcoo(:, 3));

% shift positions according to receiver position (only for p output):
if cube
    p = p + repmat(room.recpos - [1 1 1]/2, numAng, 1);
end

azim = rd2dg(azim);
elev = rd2dg(elev);

% respect reciever orientation:
azim = azim - room.recdir(1);
elev = elev - room.recdir(2);

lrscale = panscale(room, relcoo);

hrir_angles = [azim, elev];
hrir_angles = wrap_angles(hrir_angles, true);
