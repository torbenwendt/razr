function h = scene(rooms, varargin)
% SCENE - Plot a sketch of one or more rooms (connected to each other) with a source and a receiver.
%
% Usage:
%   h = SCENE(room)
%   h = SCENE(rooms, adj)
%   h = SCENE(__, Name, Value)
%
% Input:
%   room, rooms     Room structure (see RAZR) or vector of room structures
%   adj             Adjacency specification for coupled rooms (required, if length(rooms) > 1)
%                   Note: RIR synthesis for coupled rooms not supported yet!
%
% Optional Name-Value-pair arguments (defaults in parentheses):
%
% Plotting:
% ---------
%   topview         (false) Show room sketch from top view
%   roomcolors      (one room: [0 0 0]; multiple rooms: lines(length(rooms))) Matrix containing
%                   rgb values for each room. Each row represents one room.
%   doorcolors      Same as for roomcolors, but for doors.
%   reccolor        ([1 0 0]) RGB values for receiver color
%   srccolor        ([0 0 0]) RGB values for source color
%   noselen         (0.1) Length of receiver nose in units of the geometric mean of the room
%                   dimensions
%   xl_doors        (false) If true, enlarge doors, such that they are on the top level for top view
%
% Labels:
% -------
%   materials       (true) If wall materials are specified as key strings (see RAZR, GETABSCOEFF),
%                   label them on the respective walls
%   srclabel        ('') Labels for source(s). Cell array of strings or single string. If empty,
%                   sources will be labeled with a default string (automatic labeling only for
%                   multiple sources)
%   reclabel        ('') Same as for srclabel, but for receivers
%   hide_labels     (true) If true, hide labels for source(s) and receiver(s)
%   labeloffset     ([0.1 0.1 0.1]) Offset for source and receiver labels (labels are only plotted
%                   for multiple sources and receivers)
%   title           ('') Axes title with interpreter 'none'
%
% Image sources:
% --------------
% (for these plotting options, the ism_data structure, returned by razr, is required):
%   ism_data        (empty struct) ism_data-structure as being returned by razr
%   plot_ispos      (false) If true, plot image source positions, stored in ism_data
%   plot_ispos_jit  (false) If true, plot jittered image source positions (only correct
%                   for op.ism_jitter_type == 'cart')
%   plot_refl       (false) If true, plot reflection paths for image sources (only first order
%                   supported up to now)
%   ism_order       ([]) ISM orders to be plotted. Set empty for all orders available in ism_data
%   ism_discd_dir   ([]) Indices of directions for image sources to be discarded. Translation:
%                   [+/-z, +/-y, +/-x] <--> [+/-3, +/-2, +/-1]
%
% Output:
%   h               Strcuture containing graphic handles

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
addparam(p, 'reccolor', [1 1 1]*0.35);
addparam(p, 'srccolor', [0 0 0]);
addparam(p, 'noselen', 0.1);
addparam(p, 'xl_doors', false);
addparam(p, 'topview', false);
addparam(p, 'materials', true);
addparam(p, 'title', '');
addparam(p, 'srclabel', '');
addparam(p, 'reclabel', '');
addparam(p, 'hide_labels', false);
addparam(p, 'labeloffset', [0.1, 0.1, 0.1]);
addparam(p, 'ism_data', struct);
addparam(p, 'plot_ispos', false);
addparam(p, 'plot_ispos_jit', false);
addparam(p, 'plot_refl', false);
addparam(p, 'ism_order', []);
addparam(p, 'ism_discd_dir', []);
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
    adjx = adj2adjx(rooms, adj);
end

rooms = add_room_origins(rooms, adjx);

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
    b = room.boxsize;
    
    %% rooms:
    h.plot.room(:, r) = plotbox(...
        h.ax, b, room.origin, 'linewidth', 3, 'color', p.Results.roomcolors(r, :));
    
    hold on
    
    %% doors:
    if isfield(room, 'door')
        [rows, cols] = find(adjx.rooms == r);
        numA = length(rows);
        doors_of_cur_room = zeros(numA, 1);
        states_of_cur_room = zeros(numA, 1);
        for a = 1:numA
            doors_of_cur_room(a) = adjx.doors(rows(a), cols(a));
            states_of_cur_room(a) = adjx.states(rows(a));
        end
        
        [wall_idx_abs, other_idxs] = idx_door_wall(room);
        
        for d = 1:length(room.door)
            doorbox(wall_idx_abs(d)) = 0;   % thickness of door
            doorbox(other_idxs(d, :)) = room.door(d).size;
            door_origin(wall_idx_abs(d)) = ...
                b(wall_idx_abs(d)) * (sign(room.door(d).wall) == 1) - sign(room.door(d).wall)*0.01;
            door_origin(other_idxs(d, :)) = room.door(d).pos;
            
            if p.Results.xl_doors
                doorbox(3) = room.boxsize(3) + 1;
            end
            % increased linewidth to be visible in top view, too:
            h.plot.door(:, d) = plotbox(h.ax, doorbox, door_origin + room.origin, ...
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
        srcpos = room.srcpos + repmat(room.origin, numSrc, 1);
        srclabel = get_labels(p.Results.srclabel, numSrc, 'Src');
        
        if size(p.Results.srccolor, 1) == 1
            srccol = repmat(p.Results.srccolor, numSrc, 1);
        else
            srccol = p.Results.srccolor;
        end
        
        for n = 1:numSrc
            h.plot.src(n) = plot3(srcpos(n, 1), srcpos(n, 2), srcpos(n, 3), ...
                'x', 'color', srccol(n, :), 'Linewidth', 2, ...
                'markersize', 8, 'markerfacecolor', 'w');
            plot_handles = [plot_handles; h.plot.src(n)];
            leg_str = [leg_str, sprintf('Source %d', n)];
            
            % label:
            if ~p.Results.hide_labels
                text(...
                    srcpos(n, 1) + labeloffset(1), ...
                    srcpos(n, 2) + labeloffset(2), ...
                    srcpos(n, 3) + labeloffset(3), ...
                    srclabel{n}, 'color', srccol(n, :));
            end
        end
    else
        room.srcpos = [];
    end
    
    %% receiver(s):
    if isfield(room, 'recpos') && ~isempty(room.recpos)
        numRec = size(room.recpos, 1);
        reclabel = get_labels(p.Results.reclabel, numRec, 'Rec');
        
        if size(p.Results.reccolor, 1) == 1
            reccol = repmat(p.Results.reccolor, numRec, 1);
        else
            reccol = p.Results.reccolor;
        end
        
        for n = 1:numRec
            recpos = room.recpos(n, :) + room.origin;
            h.plot.rec(n) = plot3(recpos(1), recpos(2), recpos(3), 'o', ...
                'Linewidth', 2, 'markersize', 8, ...
                'color', reccol(n, :), 'markerfacecolor', reccol(n, :));
            %set(h.plot.rec(n), 'markerfacecolor', 'r');
            plot_handles = [plot_handles; h.plot.rec(n)];
            leg_str = [leg_str, sprintf('Receiver %d', n)];
            
            % nose, indicating orientation:
            if isfield(room, 'recdir') && ~isempty(room.recdir)
                if size(room.recdir, 1) ~= numRec
                    error('Number of recdir must match number of recpos.');
                end
                noselen = p.Results.noselen*prod(b).^(1/3);
                [rx, ry, rz] = sph2cart(dg2rd(room.recdir(n, 1)), dg2rd(room.recdir(n, 2)), noselen);
                nose = [recpos; recpos + [rx, ry, rz]];
                h.plot.nose(n) = plot3(nose(:, 1), nose(:, 2), nose(:, 3), ...
                    '-', 'Linewidth', 3, 'color', reccol(n, :));
            end
            
            % label:
            if ~p.Results.hide_labels
                text(...
                    recpos(1) + labeloffset(1), ...
                    recpos(2) + labeloffset(2), ...
                    recpos(3) + labeloffset(3), ...
                    reclabel{n}, 'color', reccol(n, :));
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
        mpos = mpos + repmat(room.origin, 6, 1);
        
        h.text = text(mpos(:, 1), mpos(:, 2), mpos(:, 3), room.materials, ...
            'HorizontalAlignment', 'center', 'Interpreter', 'none');
    end
    
    %% image sources
    
    if p.Results.plot_ispos || p.Results.plot_ispos_jit || p.Results.plot_refl
        if isempty(fieldnames(p.Results.ism_data))
            error('ism_data must be passed to scene if ISM positions shall be plotted.');
        end
        
        h = plot_ism(h, room, p);
        
        if isfield(h.plot, 'img_src') && ~isempty(h.plot.img_src)
            for is = 1:length(h.plot.img_src)
                plot_handles = [plot_handles; h.plot.img_src{is}(1)];
                leg_str = [leg_str, sprintf('Img src ord %d', h.plot.img_src_orders(is))];
            end
        end
        if isfield(h.plot, 'img_src_jittered') && ~isempty(h.plot.img_src_jittered)
            for is = 1:length(h.plot.img_src_jittered)
                plot_handles = [plot_handles; h.plot.img_src_jittered{is}(1)];
                leg_str = [leg_str, sprintf('Jit. img src ord %d', h.plot.img_src_orders(is))];
            end
        end
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

axis('tight')

if p.Results.topview
    view(0, 90);
else
    view(-30, 20);
end
set(h.ax, 'DataAspectRatio', [1 1 1]);

plot_handles = [h.plot.room(1, :)'; plot_handles];
leg_str      = [{rooms.name}, leg_str];

h.leg = legend(plot_handles, leg_str, 'Location', 'NorthEastOutside', 'Interpreter', 'none');
legend('boxoff')

if nargout == 0
    clear h
end

hold off

end

function labels_out = get_labels(labels_in, num, default_str)
% Labels for src and rec.

if ~iscell(labels_in)
    labels_in = {labels_in};
end
if length(labels_in) == 1 && isempty(labels_in{1}) && num > 1
    labels_out = strsplit(sprintf([default_str, ' %d#'], 1:num), '#');
    % strsplit(...) produces num + 1 elements, last is empty:
    labels_out = labels_out(1:(end-1));
elseif length(labels_in) < num
    error('Not enough labels for %s specified.', default_str);
else
    labels_out = labels_in;
end

end

function h = plot_ism(h, room, p)

if isempty(p.Results.ism_order)
    desired_orders = unique(p.Results.ism_data.order);
else
    desired_orders = p.Results.ism_order;
end

idx_ord = ismember(p.Results.ism_data.order, desired_orders);

if any(~ismember(desired_orders, p.Results.ism_data.order))
    warning('Not all ISM orders that shall be plotted are available in ism_data.');
end

% ----- keep only desired directions ----- %
absdir = abs(p.Results.ism_discd_dir);
sgn = sign(p.Results.ism_discd_dir);
idx_dir = true(size(p.Results.ism_data.order));
for k = 1:length(p.Results.ism_discd_dir)
    idx_dir = idx_dir & sign(p.Results.ism_data.pattern(:, absdir(k))) ~= sgn(k);
end

numSrc = size(p.Results.ism_data.positions, 1);

pos     = p.Results.ism_data.positions(:, 1:3) + repmat(room.origin, numSrc, 1);
pos_jit = p.Results.ism_data.relpos(:, 1:3) + repmat(room.origin, numSrc, 1) + repmat(room.recpos, numSrc, 1);
idx_a = p.Results.ism_data.idx_auralize;


%% img-src positions

if p.Results.plot_ispos || p.Results.plot_ispos_jit
    cmap = copper(length(desired_orders) + 1);
    cmap(1, :) = [];
    h.plot.img_src_orders = desired_orders;
    
    if p.Results.plot_ispos
        h.plot.img_src = {};
        h.plot.img_src_invis = {};
    end
    if p.Results.plot_ispos_jit
        h.plot.img_src_jittered = {};
    end
    
    for ord = 1:length(desired_orders)
        idx = idx_ord & idx_dir & p.Results.ism_data.order == desired_orders(ord);
        
        if p.Results.plot_ispos
            h.plot.img_src{end + 1} = plot3(...
                pos(idx_a & idx, 1), ...
                pos(idx_a & idx, 2), ...
                pos(idx_a & idx, 3), ...
                'x', 'color', cmap(ord, :), 'linewidth', 2);
            
            % not auralized img src:
            h.plot.img_src_invis{end + 1} = plot3(...
                pos(~idx_a & idx, 1), ...
                pos(~idx_a & idx, 2), ...
                pos(~idx_a & idx, 3), ...
                '.', 'color', cmap(ord, :), 'linewidth', 1);
        end
        if p.Results.plot_ispos_jit
            % jittered img src:
            h.plot.img_src_jittered{end + 1} = plot3(...
                pos_jit(idx_a & idx, 1), ...
                pos_jit(idx_a & idx, 2), ...
                pos_jit(idx_a & idx, 3), ...
                'x', 'color', cmap(ord, :), 'linewidth', 1);
        end
    end
end

%% reflection paths
% only up to 1st order implemented up to now:

if p.Results.plot_refl
    idx_path = idx_ord & idx_dir & p.Results.ism_data.order <= 1;
    
    pos_subset = pos(idx_a & idx_path, 1:3);
    
    % get wall intersection points
    % (returns [-1 -1 -1] for no intersection, i.e. direct sound):
    intsecs = get_intsecpoints_on_box(...
        room.boxsize, ...
        pos_subset, ...
        room.recpos);
    
    % if no intersection, move dummy point to receiver:
    [ans0, idx_no_intsec] = ismember([-1 -1 -1], intsecs, 'rows');
    if idx_no_intsec ~= 0
        intsecs(idx_no_intsec, :) = room.recpos;
    end
    
    for n = 1:size(pos_subset, 1)
        % reflection paths:
        h.plot.refl = plot3(...
            [room.srcpos(1), intsecs(n, 1), room.recpos(1)], ...
            [room.srcpos(2), intsecs(n, 2), room.recpos(2)], ...
            [room.srcpos(3), intsecs(n, 3), room.recpos(3)], ...
            'color', [1 1 1]*0.75);
        
        if p.Results.plot_ispos
            % lines img-src --> intecpoint
            h.plot.img_src_to_intsec = plot3(...
                [pos_subset(n, 1), intsecs(n, 1)], ...
                [pos_subset(n, 2), intsecs(n, 2)], ...
                [pos_subset(n, 3), intsecs(n, 3)], ...
                '--', 'color', [1 1 1]*0.75);
        end
    end
end

end
