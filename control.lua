require "functions"

require "__DragonIndustries__.strings"

script.on_init(function()

end)


local function addCommands()
	commands.add_command("updateEvo", {"cmd.update-evo-help"}, function(event)
		if game.players[event.player_index].admin then
			clampEvoAsNecessary(game.players[event.player_index].force, game.players[event.player_index].surface)
		end
	end)
end

addCommands()

local function runEvoClamp()
	local activeSurfaces = splitString(settings.startup["lossp-surface-list"].value, ",") 
	for name,force in pairs(game.forces) do
		if #force.players > 0 then
			for _,surf in pairs(activeSurfaces) do
				if surf and game.surfaces[surf] and game.surfaces[surf].valid then clampEvoAsNecessary(force, game.surfaces[surf]) end
			end
		end
	end
end

script.on_configuration_changed(function(data)
	runEvoClamp()
end)

script.on_nth_tick(300, function(data)
	runEvoClamp()
end)

script.on_event(defines.events.on_biter_base_built, function(event)
	local base = event.entity
	if base.type == "unit-spawner" and settings.startup["regulate-spawner-growth"].value then
		modifySpawner(base)
		return
	end
	if base.type == "turret" and settings.startup["regulate-worm-growth"].value then
		modifyWorm(base)
		return
	end
end)