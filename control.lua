require "functions"
require "config"

function initGlobal(force)
	if not global.lossp then
		global.lossp = {}
	end
end

--initGlobal(true)

script.on_init(function()

end)


local function addCommands()
	commands.add_command("updateEvo", {"cmd.init-creative-help"}, function(event)
		if game.players[event.player_index].admin then
			clampEvoAsNecessary(global.lossp, true, true)
		end
	end)
end

addCommands()

script.on_configuration_changed(function(data)
	clampEvoAsNecessary(global.lossp, true)
end)

script.on_event(defines.events.on_tick, function(event)
	if event.tick%300 == 0 then
		local cache = global.lossp
		clampEvoAsNecessary(cache, false)
	end
end)

script.on_event(defines.events.on_biter_base_built, function(event)
	local base = event.entity
	if base.type == "unit-spawner" then
		modifySpawner(base)
		return
	end
	if base.type == "turret" then
		modifyWorm(base)
		return
	end
end)