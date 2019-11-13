
local nawflow_groupaistatebeseige_upd_police_activity = GroupAIStateBesiege._upd_police_activity
function GroupAIStateBesiege:_upd_police_activity()
    nawflow_groupaistatebeseige_upd_police_activity(self)

    if self._ai_enabled and self._enemy_weapons_hot then
        managers.navflow:update_player_pace(self._criminals)
    end
end