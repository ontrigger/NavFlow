---@class NavFlowManager
NavFlowManager = NavFlowManager or class()

function NavFlowManager:init()
    ---@alias flow_index number
    ---@type table<number, flow_index> @segment to navflow map
    self._nav_flow = {}
    ---@alias nav_flow table
    ---@type nav_flow[] @positional index of flow_data along the flow
    self._flow_distance = {}
    self._player_pace = {}
end

function NavFlowManager:set_flow_distance(flow_dist)
    self._flow_distance = table.collect(flow_dist, function(val)
        return val.seg_id
    end)

    for i, flow in pairs(flow_dist) do
        self._nav_flow[flow.seg_id] = {
            dist = flow.dist,
            accum_area = flow.accum_area,
            flow_i = i
        }
    end
end

function NavFlowManager:flow_distance()
    return self._flow_distance
end

---@alias CriminalData table
---@param criminal_data table<string, CriminalData>
function NavFlowManager:update_player_pace(criminal_data)
    log(tostring("updating pace"))
    --[[for c_key, c_data in pairs(criminal_data) do
        if not c_data.status then
            self._player_pace[c_key] = {
                last_pos = c_data.tracker:position()
            }
        end
    end]]
end

--- Gets all segment ids behind an area and ahead in tables
--- Excludes the input area
---@param seg_id number
---@return (number[], number[])
function NavFlowManager:find_segs_behind_ahead_area(seg_id)
    local idx = self._nav_flow[seg_id]

    local behind, ahead = {}, {}

    for i = idx, #self._flow_distance do
        -- exclude the input area
        if i ~= idx then
            table.insert(ahead, self._flow_distance[i])
        end
    end

    for i = 1, idx do
        -- exclude the input area
        if i ~= idx then
            table.insert(behind, self._flow_distance[i])
        end
    end

    return behind, ahead
end