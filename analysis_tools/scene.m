function h = scene(rooms, varargin)
% SCENE - Plot a sketch of one or more rooms (connected to each other) with a source and a receiver.
%
% Usage:
%   h = SCENE(room)
%   h = SCENE(rooms, adj)
%   h = SCENE(__, Name, Value)
%
% Input:
%	room, rooms     Room structure (see RAZR) or vector of room structures
%   adj             Adjacency specification for coupled rooms (required, if length(rooms) > 1)
%                   Note: RIR synthesis for coupled rooms not supported yet!
%
% Optional Name-Value-pair arguments (defaults in parentheses):
%   materials       (true) If wall materials are specified as key strings (see RAZR, GETABSCOEFF),
%                   label them on the respective walls
%   topview         (false) Show room sketch from top view
%   roomcolors      (one room: [0 0 0]; multiple rooms: lines(length(rooms))) Matrix containing
%                   rgb values for each room. Each row represents one room.
%   doorcolors      Same as for roomcolors, but for doors.
%   xl_doors        (false) If true, enlarge doors, such that they are on the top level for top view
%   hide_labels     (false) If true, hide labels for multiple sources and receivers
%   labeloffset     ([0.1 0.1 0.1]) Offset for source and receiver labels (labels are only plotted
%                   for multiple sources and receivers)
%
% Output:
%   h                   Strcuture containing graphic handles

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


%% input treatment

% extract adjacencies:
if nargin > 1 && ~ischar(varargin{1});
    adj = varargin{1};
    varargin(1) = [];
else
    adj = {};
end

numRooms = length(rooms);

% check for logical errors:
if numRooms == 1
    adj = {};
    roomcolors_default = zeros(1, 3);
else
    if isempty(adj)
        error('No adjacencies specified.');
    end
    roomcolors_default = lines(numRooms);
end

p = inputParser;
addparam = get_addparam_func;
addparam(p, 'roomcolors', roomcolors_default);
addparam(p, 'doorcolors', roomcolors_default);
addparam(p, 'xl_doors', false);
addparam(p, 'topview', false);
addparam(p, 'materials', true);
addparam(p, 'title', '');
addparam(p, 'hide_labels', false);
addparam(p, 'labeloffset', [0.1, 0.1, 0.1]);
parse(p, varargin{:});

% if adj is empty, it's required to be a cell array:
if isempty(adj)
    adj = cell(0);
end

if ~isfield(rooms, 'name')
    for n = 1:numRooms
        rooms(n).name = sprintf('Room %d', n);
    end
end

labeloffset = [1 1 1].*(p.Results.labeloffset);

if iscell(adj)
    adj = adj2idx({rooms.name}, adj);
end

origins = get_room_origins(rooms, adj);

%%

plot_reverb_src = false;
do_cube = true;

figure;

plot_handles = [];
leg_str = cell(0);

for r = 1:numRooms;
    % abbvrevs:
    %room = complement_room(rooms(r));
    room = rooms(r);
    origin = origins(r,:);
    b = room.boxsize;
    
    %check_door(room);
    
    % keep only unique src/rec:
    if 0
        uni_src = unique([room.srcpos, room.srcdir], 'rows');
        uni_rec = unique([room.recpos, room.recdir], 'rows');
        if size(uni_src, 1) == 1
            room.srcpos = uni_src(:, [1 2 3]);
            room.srcdir = uni_src(:, [4 5]);
        end
        if size(uni_rec, 1) == 1
            room.recpos = uni_rec(:, [1 2 3]);
            room.recdir = uni_rec(:, [4 5]);
        end
    end
    
    handles_rooms_tmp = plotbox(...
        gca, b, origin, 'linewidth', 3, 'color', p.Results.roomcolors(r, :));
    plot_handles_rooms(r) = handles_rooms_tmp(1);
    
    % doors:
    if isfield(room, 'door')
        [rows, cols] = find(adj.rooms == r);
        numA = length(rows);
        doors_of_cur_room = zeros(numA, 1);
        states_of_cur_room = zeros(numA, 1);
        for a = 1:numA
            doors_of_cur_room(a) = adj.doors(rows(a), cols(a));
            states_of_cur_room(a) = adj.states(rows(a));
        end
        
        [wall_idx_abs, other_idxs] = idx_door_wall(room);
        
        for d = 1:size(room.door, 1)
            doorbox(wall_idx_abs(d)) = 0;							% thickness of door = 0
            doorbox(other_idxs(d, :)) = room.door(d, [4, 5]);
            door_origin(wall_idx_abs(d)) = ...
                b(wall_idx_abs(d)) * (sign(room.door(d, 1)) == 1) - sign(room.door(d, 1))*0.01;
            door_origin(other_idxs(d, :)) = room.door(d, [2, 3]);
            
            if p.Results.xl_doors
                doorbox(3) = room.boxsize(3) + 1;
            end
            % increased linewidth to be visible in top view, too:
            plotbox(gca, doorbox, door_origin + origin, ...
                'linewidth', 5.0, 'color', p.Results.doorcolors(r, :));
            
            % door state (temporally disabled, not important at the moment):
            %door_center_pos = origin + door_origin + doorbox/2;
            %door_str = sprintf('%g', adj.states(doors_of_cur_room == d));
            %text(door_center_pos(1), door_center_pos(2), door_center_pos(3), door_str, ...
            %    'color', colours_rooms(r, :)); 
        end
    end
    
    % source(s):
    if isfield(room, 'srcpos') && ~isempty(room.srcpos)
        numSrc = size(room.srcpos, 1);
        srcpos = room.srcpos + repmat(origin, numSrc, 1);
        for n = 1:numSrc
            spos = plot3(srcpos(n, 1), srcpos(n, 2), srcpos(n, 3), ...
                '*', 'color', 'k', 'Linewidth', 2, 'markersize', 8, 'markerfacecolor', 'w');
            plot_handles = [plot_handles, spos];
            leg_str = [leg_str, sprintf('Source %d', n)];
            
            % label:
            if numSrc > 1 && ~p.Results.hide_labels
                text(...
                    srcpos(n, 1) + labeloffset(1), ...
                    srcpos(n, 2) + labeloffset(2), ...
                    srcpos(n, 3) + labeloffset(3), ...
                    sprintf('Src %d', n));
            end
        end
        hold on
    end
    
    % receiver(s):
    if isfield(room, 'recpos') && ~isempty(room.recpos)
        numRec = size(room.recpos, 1);
        for n = 1:numRec
            recpos = room.recpos(n, :) + origin;
            rpos = plot3(recpos(1), recpos(2), recpos(3), 'ro', 'Linewidth', 2, 'markersize', 8);
            plot_handles = [plot_handles, rpos];
            set(rpos,'markerfacecolor','r')
            leg_str = [leg_str, sprintf('Receiver %d', n)];
            
            hold on
            
            % nose, indicating orientation:
            [rx, ry, rz] = sph2cart(dg2rd(room.recdir(n, 1)), dg2rd(room.recdir(n, 2)), mean(b)/15);
            nose = [recpos; recpos + [rx, ry, rz]];
            plot3(nose(:, 1), nose(:, 2), nose(:, 3), 'r-', 'Linewidth', 3);
            
            % label:
            if numRec > 1 && ~p.Results.hide_labels
                text(...
                    recpos(1) + labeloffset(1), ...
                    recpos(2) + labeloffset(2), ...
                    recpos(3) + labeloffset(3), ...
                    sprintf('Rec %d', n), 'color', 'r');
            end
        end
    end
    
    % materials:
    if isfield(room, 'materials') && iscellstr(room.materials) && p.Results.materials
        mpos = zeros(6,3);						% text positions
        mpos(1,:) = [1 1 0].*b * 1/2;			% -z
        mpos(2,:) = [1 0 1].*b * 1/2;			% -y
        mpos(3,:) = [0 1 1].*b * 1/2;			% -x
        mpos(4,:) = mpos(3,:) + [1 0 0].*b;		% +x
        mpos(5,:) = mpos(2,:) + [0 1 0].*b;		% +y
        mpos(6,:) = mpos(1,:) + [0 0 1].*b;		% +z
        mpos = mpos + repmat(origin, 6, 1);
        
        htext = text(mpos(:, 1), mpos(:, 2), mpos(:, 3), room.materials, ...
            'HorizontalAlignment', 'center', 'Interpreter', 'none');
    end
    
    % reverb sources:
    if plot_reverb_src
        [ans0, pos] = get_hrtf_angles(room, do_cube);
        
        if do_cube
            plotbox(gca, [1 1 1], room.recpos - [1 1 1]*0.5, 'color', [1 1 1]*0.6);
        end
        
        plot3(pos(:, 1), pos(:, 2), pos(:, 3), 'x', 'color', [1 1 1]*0.6);
    end
end

xlabel('x')
ylabel('y')
zlabel('z')

if ~isempty(p.Results.title)
    title(p.Results.title, 'interpreter', 'none');
end

if numRooms == 1 && ...
        (isempty(room.srcpos) || ...
        all(all(room.srcpos <= repmat(room.boxsize, numSrc, 1))) && all(all(room.srcpos >= 0))) ...
        && ...
        (isempty(room.recpos) || ...
        all(all(room.recpos <= repmat(room.boxsize, numRec, 1))) && all(all(room.recpos >= 0)))
    xlim([0 b(1)] + origin(1))
    ylim([0 b(2)] + origin(2))
    zlim([0 b(3)] + origin(3))
end

if p.Results.topview
    view(0, 90);
else
    view(-30, 20);
end
set(gca, 'DataAspectRatio', [1 1 1]);

plot_handles = [plot_handles, plot_handles_rooms];
leg_str      = [leg_str, {rooms.name}];

hleg = legend(plot_handles, leg_str, 'Location', 'NorthEastOutside', 'Interpreter', 'none');
legend('boxoff')

%% argout

if nargout > 0
    h.fig = gcf;
    h.ax = gca;
    h.plot = plot_handles;
    h.leg = hleg;
    if exist('htext', 'var')
        h.text = htext;
    end
end
