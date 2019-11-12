local navflow_original_navigationmanager_sendnavfieldtoengine = NavigationManager.send_nav_field_to_engine
function NavigationManager:send_nav_field_to_engine()
    self:build_coarse_flow()
    return navflow_original_navigationmanager_sendnavfieldtoengine(self)
end

function NavigationManager:build_coarse_flow()
    local src_id = 151

    self._flow_data = {
        start_id = 8,
        end_id = 151
    }

    local pq = PriorityQueue()
    local dist = {}
    local history = {}
    local dist_history = {}

    for nav_seg_id, _ in pairs(self._nav_segments) do
        dist[nav_seg_id] = src_id == nav_seg_id and 0 or math.huge
        history[nav_seg_id] = false
        dist_history[nav_seg_id] = false
    end

    pq:put(src_id, 0)

    while not pq:empty() do
        local seg_id = pq:pop()
        local seg = self._nav_segments[seg_id]
        for neigh_i_seg, _ in pairs(seg.neighbours) do
            local weight = mvector3.distance(seg.pos, self._nav_segments[neigh_i_seg].pos)

            local pending_distance = dist[seg_id] + weight
            if pending_distance < dist[neigh_i_seg] then
                dist[neigh_i_seg] = pending_distance

                history[neigh_i_seg] = seg_id
                dist_history[neigh_i_seg] = weight

                pq:put(neigh_i_seg, dist[neigh_i_seg])
            end
        end
    end

    self._seg_flow = {}
    local seg_flow_dist = {}
    self._nav_seg_units = {}
    local all_shortest_paths = {}
    for seg_id, _ in pairs(self._nav_segments) do
        --if seg_id ~= src_id then
        local start = seg_id
        local path = {}
        local total_dist = 0
        while start do
            table.insert(path, start)
            self._seg_flow[start] = history[start]
            total_dist = total_dist + (dist_history[start] or 0)
            start = history[start]
        end

        -- filter out lone segs that don't connect to the end
        if #path > 1 or path[1] == src_id then
            all_shortest_paths[seg_id] = path
            table.insert(seg_flow_dist, {
                seg_id = seg_id,
                dist = total_dist,
            })
        end
        --end

        -- for debug purposes
        local unit = managers.worlddefinition:get_unit_on_load(seg_id, function(_) end)
        if alive(unit) then
            self._nav_seg_units[seg_id] = unit
        end
    end

    table.sort(seg_flow_dist, function(a, b) return a.dist < b.dist end)

    local accum_area = 0
    for i, flow in ipairs(seg_flow_dist) do
        accum_area = accum_area + self:_compute_seg_area(flow.seg_id)
        flow.accum_area = accum_area
    end

    self._seg_flow_dist_area = seg_flow_dist[#seg_flow_dist].accum_area

    print_table(seg_flow_dist)
    log(tostring(total_area))

    self._seg_flow_dist = seg_flow_dist
end

function NavigationManager:_compute_seg_area(seg_id)
    local total_area = 0
    if self._nav_segments[seg_id] and next(self._nav_segments[seg_id].vis_groups) then
        for _, i_vis_group in ipairs(self._nav_segments[seg_id].vis_groups) do

            local vis_group_rooms = self._visibility_groups[i_vis_group].rooms
            for room_id, _ in pairs(vis_group_rooms) do
                total_area = total_area + self._builder:_calc_room_area(self._rooms[room_id].borders)
            end
        end
    end

    return total_area
end

function NavigationManager:_draw_coarse_graph()
    local all_nav_segments = self._nav_segments
    local seg_flow = self._seg_flow
    local all_doors = self._room_doors
    local all_vis_groups = self._visibility_groups
    local cone_height = Vector3(0, 0, 50)

    for seg_id, seg_data in pairs(all_nav_segments) do
        local neighbours = seg_data.neighbours

        for neigh_i_seg, door_list in pairs(neighbours) do
            local pos = all_nav_segments[neigh_i_seg].pos
            local color = {
                1,
                1,
                0
            }

            if all_nav_segments[neigh_i_seg].disabled then
                color = {
                    1,
                    0,
                    0
                }
            elseif seg_data.blocked_group or all_nav_segments[neigh_i_seg].blocked_group then
                color = {
                    1,
                    0.5,
                    0
                }

                self._draw_data.brush.blocked:center_text(pos + cone_height * 2, all_nav_segments[neigh_i_seg].blocked_group)
            end

            --Application:draw_cone(pos, seg_data.pos, 12, unpack(color))
            --Application:draw_cone(pos, pos + cone_height, 40, unpack(color))
        end

        local to_seg_id = seg_flow[seg_id]
        local to_unit = self._nav_seg_units[to_seg_id]
        local from_unit = self._nav_seg_units[seg_id]
        if alive(to_unit) and alive(from_unit) then
            Application:draw_link({
                from_unit = from_unit,
                to_unit = to_unit,
                r = 0,
                g = 1,
                b = 0,
                thick = true
            })
        end

        local start_seg = self._nav_seg_units[self._flow_data.start_id]
        local end_seg = self._nav_seg_units[self._flow_data.end_id]
        if alive(start_seg) and alive(end_seg) then
            Application:draw_cone(start_seg:position(), start_seg:position() + cone_height, 30, 1, 0, 0)
            Application:draw_cone(end_seg:position(), end_seg:position() + cone_height, 30, 1, 0, 0)
        end
    end
end