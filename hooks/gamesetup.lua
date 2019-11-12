Hooks:PostHook(GameSetup, "init_managers", "nav_flow_GameSetup", function(self, managers)
    managers.navflow = NavFlowManager:new()
end)