---@class NavFlowManager
NavFlowManager = NavFlowManager or class()

function NavFlowManager:init()
    ---@alias flow_index number
    ---@type table<number, flow_index> @segment to navflow map
    self._nav_flow = {}
    ---@alias nav_flow table
    ---@type nav_flow[] @positional index of flow_data along the flow
    self._flow_distance = {}
end

function NavFlowManager:set_flow_distance(flow_dist)
    self._flow_distance = flow_dist
end

function NavFlowManager:flow_distance()
    return self._flow_distance
end