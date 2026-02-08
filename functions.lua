require "constants"

---@param force LuaForce
---@param surface LuaSurface
function clampEvoAsNecessary(force, surface)
	local evo = game.forces.enemy.get_evolution_factor(surface)
	if evo < 0.9 and force.get_entity_count("rocket-silo") > 0 then return end -- rocket silo -> always up to 90% evo
	local base = evo
	local mixRule = settings.startup["lossp-threshold-combination-rule"].value
	local seconds = game.tick/60
	local failed = {}
	local passed = {}
	for _,check in pairs(THRESHOLDS) do
		local relevant = check.failEvoCeiling < evo and (check.minTime == nil or seconds >= check.minTime) and (check.maxTime == nil or seconds < check.maxTime)
		if relevant then
			if check.criterion(force, surface) then
				table.insert(passed, check)
			else
				table.insert(failed, check)
				if mixRule == "all" then
					evo = math.min(evo, check.failEvoCeiling)
				end
			end
		end
	end
	if mixRule == "average" then
		local cap = 0
		for _,val in pairs(passed) do
			cap = cap+val
		end
		cap = cap/#passed
		evo = math.min(evo, cap)
	elseif mixRule == "any" then
		local max = -1
		for _,val in pairs(failed) do
			max = math.max(max, val)
		end
		evo = math.min(evo, max)
	end
	if base ~= evo then
		game.forces.enemy.set_evolution_factor(evo, surface)
	end
end

---@param entity LuaEntity
---@return number
local function getEvo(entity)
	local valid = entity and entity.valid
	return (valid and entity.force or game.forces.enemy).get_evolution_factor(valid and entity.surface or game.surfaces.nauvis)
end

---@param entity LuaEntity
function modifySpawner(entity)
	if entity.name == "spitter-spawner" and getEvo(entity) < settings.startup["lossp-spitter-evo-threshold"].value then
		local pos = entity.position
		local f = entity.force
		local dir = entity.direction
		local s = entity.surface
		entity.destroy()
		s.create_entity{name = "biter-spawner", position = pos, force = f, direction = dir}
	end
end

---@param entity LuaEntity
function modifyWorm(entity)
	local evo = getEvo(entity)
	local req = WORM_LIMITS[entity.name]
	if not req then return end
	req = req*settings.startup["lossp-worm-evo-threshold-factor"].value

	if evo >= req then return end

	local repl = ""
	local selthresh = -1
	for name,thresh in pairs(WORM_LIMITS) do
		if (thresh <= evo and thresh > selthresh) then
			repl = name
			selthresh = thresh
		end
	end

	local pos = entity.position
	local f = entity.force
	local dir = entity.direction
	local s = entity.surface
	entity.destroy()
	s.create_entity{name = repl, position = pos, force = f, direction = dir}
end