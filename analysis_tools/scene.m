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
%   reccolor        ([1 0 0]) RGB values for receiver color
%   srccolor        ([0 0 0]) RGB values for source color
%   xl_doors        (false) If true, enlarge doors, such that they are on the top level for top view
%   hide_labels     (false) If true, hide labels for multiple sources and receivers
%   labeloffset     ([0.1 0.1 0.1]) Offset for source and receiver labels (labels are only plotted
%                   for multiple sources and receivers)
%
% Output:
%   h               Strcuture containing graphic handles

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


%% input treatment

% extract adjacencies:
if nargin > 1 && ~ischar(varargin{1});
    adj = varargin{1};
    varargin(1) = [];
else
    adj = {};
end

numRooms = length(rooms);

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
addparam(p, 'reccolor', [1 0 0]);
addparam(p, 'srccolor', [0 0 0]);
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

h.fig = figure;
h.ax = gca;
plot_handles = [];
leg_str = cell(0);

for r = 1:numRooms;
    % abbvrevs:
    room = rooms(r);
    origin = origins(r, :);
    b = room.boxsize;
    
    %% rooms:
    h.plot.room(:, r) = plotbox(...
        h.ax, b, origin, 'linewidth', 3, 'color', p.Results.roomcolors(r, :));
    
    %% doors:
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
            doorbox(wall_idx_abs(d)) = 0;   % thickness of door
            doorbox(other_idxs(d, :)) = room.door(d, [4, 5]);
            door_origin(wall_idx_abs(d)) = ...
                b(wall_idx_abs(d)) * (sign(room.door(d, 1)) == 1) - sign(room.door(d, 1))*0.01;
            door_origin(other_idxs(d, :)) = room.door(d, [2, 3]);
            
            if p.Results.xl_doors
                doorbox(3) = room.boxsize(3) + 1;
            end
            % increased linewidth to be visible in top view, too:
            h.plot.door(:, d) = plotbox(h.ax, doorbox, door_origin + origin, ...
                'linewidth', 5.0, 'color', p.Results.doorcolors(r, :));
            
            % door state (temporally disabled, not important at the moment):
            %door_center_pos = origin + door_origin + doorbox/2;
            %door_str = sprintf('%g', adj.states(doors_of_cur_room == d));
            %text(door_center_pos(1), door_center_pos(2), door_center_pos(3), door_str, ...
            %    'color', colours_rooms(r, :)); 
        end
    end
    
    %% source(s):
    if isfield(room, 'srcpos') && ~isempty(room.srcpos)
        numSrc = size(room.srcpos, 1);
        srcpos = room.srcpos + repmat(origin, numSrc, 1);
        
        if size(p.Results.srccolor, 1) == 1
            srccol = repmat(p.Results.srccolor, numSrc, 1);
        else
            srccol = p.Results.srccolor;
        end
        
        for n = 1:numSrc
            h.plot.src(n) = plot3(srcpos(n, 1), srcpos(n, 2), srcpos(n, 3), ...
                '*', 'color', srccol(n, :), 'Linewidth', 2, ...
                'markersize', 8, 'markerfacecolor', 'w');
            plot_handles = [plot_handles; h.plot.src(n)];
            leg_str = [leg_str, sprintf('Source %d', n)];
            
            % label:
            if numSrc > 1 && ~p.Results.hide_labels
                text(...
                    srcpos(n, 1) + labeloffset(1), ...
                    srcpos(n, 2) + labeloffset(2), ...
                    srcpos(n, 3) + labeloffset(3), ...
                    sprintf('Src %d', n), 'color', srccol(n, :));
            end
        end
        hold on
    else
        room.srcpos = [];
    end
    
    %% receiver(s):
    if isfield(room, 'recpos') && ~isempty(room.recpos)
        numRec = size(room.recpos, 1);
        
        if size(p.Results.reccolor, 1) == 1
            reccol = repmat(p.Results.reccolor, numRec, 1);
        else
            reccol = p.Results.reccolor;
        end
        
        for n = 1:numRec
            recpos = room.recpos(n, :) + origin;
            h.plot.rec(n) = plot3(recpos(1), recpos(2), recpos(3), 'o', ...
                'Linewidth', 2, 'markersize', 8, ...
                'color', reccol(n, :), 'markerfacecolor', reccol(n, :));
            %set(h.plot.rec(n), 'markerfacecolor', 'r');
            plot_handles = [plot_handles; h.plot.rec(n)];
            leg_str = [leg_str, sprintf('Receiver %d', n)];
            
            hold on
            
            % nose, indicating orientation:
            if isfield(room, 'recdir') && ~isempty(room.recdir)
                if size(room.recdir, 1) ~= numRec
                    error('Number of recdir must match number of recpos.');
                end
                [rx, ry, rz] = sph2cart(dg2rd(room.recdir(n, 1)), dg2rd(room.recdir(n, 2)), mean(b)/15);
                nose = [recpos; recpos + [rx, ry, rz]];
                h.plot.nose(n) = plot3(nose(:, 1), nose(:, 2), nose(:, 3), ...
                    '-', 'Linewidth', 3, 'color', reccol(n, :));
            end
            
            % label:
            if numRec > 1 && ~p.Results.hide_labels
                text(...
                    recpos(1) + labeloffset(1), ...
                    recpos(2) + labeloffset(2), ...
                    recpos(3) + labeloffset(3), ...
                    sprintf('Rec %d', n), 'color', reccol(n, :));
            end
        end
    else
        room.recpos = [];
    end
    
    %% materials:
    if isfield(room, 'materials') && iscellstr(room.materials) && p.Results.materials
        mpos = zeros(6,3);                      % text positions
        mpos(1,:) = [1 1 0].*b * 1/2;           % -z
        mpos(2,:) = [1 0 1].*b * 1/2;           % -y
        mpos(3,:) = [0 1 1].*b * 1/2;           % -x
        mpos(4,:) = mpos(3,:) + [1 0 0].*b;     % +x
        mpos(5,:) = mpos(2,:) + [0 1 0].*b;     % +y
        mpos(6,:) = mpos(1,:) + [0 0 1].*b;     % +z
        mpos = mpos + repmat(origin, 6, 1);
        
        h.text = text(mpos(:, 1), mpos(:, 2), mpos(:, 3), room.materials, ...
            'HorizontalAlignment', 'center', 'Interpreter', 'none');
    end
    
    %% reverb sources:
    if plot_reverb_src
        [ans0, pos] = get_hrtf_angles(room, do_cube);
        
        if do_cube
            plotbox(h.ax, [1 1 1], room.recpos - [1 1 1]*0.5, 'color', [1 1 1]*0.6);
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
set(h.ax, 'DataAspectRatio', [1 1 1]);

plot_handles = [plot_handles; h.plot.room(1, :)'];
leg_str      = [leg_str, {rooms.name}];

h.leg = legend(plot_handles, leg_str, 'Location', 'NorthEastOutside', 'Interpreter', 'none');
legend('boxoff')

if nargout == 0
    clear h
end
