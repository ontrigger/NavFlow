function NavFlow:Init()
end

if not _G.NavFlow then
	local success, err = pcall(function() NavFlow:new() end)
	if not success then
		log("[ERROR] An error occured on the initialization of ProjectilePin. " .. tostring(err))
	end
end


log("regregrtgrtgrtgrtgt")