require "config"
require "constants"

function clampEvoAsNecessary(fresh)
	local evo = game.forces.enemy.evolution_factor
	local base = evo
	for thresh,checks in pairs(THRESHOLDS) do
		if thresh < evo then
			for _,check in pairs(checks) do
				if not check(game.forces.player) then
					if game.players["Reika"] then
						game.print("Failed a check at level " .. thresh)
					end
					evo = thresh
					break
				end
			end
		end
	end
	if base ~= evo then
		game.forces.enemy.evolution_factor = evo
		
		if fresh then --once every 15 min
			local kill = {}
			if evo <= 0.2 then
				table.insert(kill, "medium-biter")
			end
			if evo <= 0.25 then
				table.insert(kill, "small-spitter")
			end
			if evo <= 0.4 then
				table.insert(kill, "medium-spitter")
			end
			if evo <= 0.5 then
				table.insert(kill, "big-biter")
			end
			if evo <= 0.5 then
				table.insert(kill, "big-spitter")
			end
			if evo <= 0.9 then
				table.insert(kill, "behemoth-biter")
			end
			if evo <= 0.9 then
				table.insert(kill, "behemoth-spitter")
			end
			if #kill > 0 then
				for _,e in pairs(game.surfaces.nauvis.find_entities_filtered{name = kill, force = game.forces.enemy}) do
					e.destroy()
				end
			end
		end
	end
end

local function getEvo(entity)
	return (entity and entity.force or game.forces.enemy).evolution_factor
end

function modifySpawner(entity)
	if entity.name == "spitter-spawner" and getEvo(entity) < 0.3 then
		local pos = entity.position
		local f = entity.force
		local dir = entity.direction
		local s = entity.surface
		entity.destroy()
		s.create_entity{name = "biter-spawner", position = pos, force = f, direction = dir}
	end
end

function modifyWorm(entity)
	local evo = getEvo(entity)
	if entity.name == "big-worm-turret" and evo < 0.7 then
		local pos = entity.position
		local f = entity.force
		local dir = entity.direction
		local s = entity.surface
		entity.destroy()
		s.create_entity{name = evo < 0.4 and "small-worm-turret" or "medium-worm-turret", position = pos, force = f, direction = dir}
		return
	end
	if entity.name == "medium-worm-turret" and evo < 0.4 then
		local pos = entity.position
		local f = entity.force
		local dir = entity.direction
		local s = entity.surface
		entity.destroy()
		s.create_entity{name = "small-worm-turret", position = pos, force = f, direction = dir}
	end
end