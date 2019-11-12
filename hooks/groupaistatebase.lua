local navflow_original_groupaistatebase_oncriminalnavsegchange = GroupAIStateBase.on_criminal_nav_seg_change
function GroupAIStateBase:on_criminal_nav_seg_change(unit, nav_seg_id)
    navflow_original_groupaistatebase_oncriminalnavsegchange(self, unit, nav_seg_id)
    local flow, i = table.find_value(managers.navigation._seg_flow_dist, function(flow)
        return flow.seg_id == nav_seg_id
    end)

    if nav_seg_id == managers.navigation._flow_data.end_id then
        managers.chat:send_message(
            ChatManager.GAME,
            managers.network.account:username() or "Offline",
            "You made it!"
        )
    end

    if not flow then
        return
    end

    local progress = math.abs(flow.accum_area / managers.navigation._seg_flow_dist_area - 1) * 100

    local text = "Progress: " ..tostring(math.round(progress, 0.5)) .. "%"

    managers.chat:send_message(
        ChatManager.GAME,
        managers.network.account:username() or "Offline",
        text
    )

    managers.navigation._selected_segment = flow.seg_id

    log("tostring current flow is", tostring(flow.accum_area), tostring(managers.navigation._seg_flow_dist_area))
    print_table(flow)
end