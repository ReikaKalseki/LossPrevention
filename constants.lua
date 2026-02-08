require "__DragonIndustries__.items"

---@class (exact) EvoCondition
---@field criterion fun(force: LuaForce, surface: LuaSurface): boolean The actual check for whether this condition is met.
---@field failEvoCeiling number The maximum evolution factor value if this condition is not true
---@field minTime? number The minimum game time (s) before this factor is checked.
---@field maxTime? number The game time (s) after which this factor is no longer checked.

---@type [EvoCondition]
THRESHOLDS = {}

WORM_LIMITS = {
	["behemoth-worm-turret"] = 0.95,
	["big-worm-turret"] = 0.7,
	["medium-worm-turret"] = 0.4,
	["small-worm-turret"] = 0,
}

---@param func fun(force: LuaForce, surface: LuaSurface): boolean
---@param evo number
---@param minT? number
---@param maxT? number
local function addEvoThreshold(func, evo, minT, maxT)
	table.insert(THRESHOLDS, {criterion=func, failEvoCeiling = evo, minTime = minT, maxTime = maxT})
end

---@param tech string
---@param evo number
---@param minT? number
---@param maxT? number
local function addTechEvoThreshold(tech, evo, minT, maxT)
	if not prototypes.technology[tech] then fmterror("No such technology '%s'!", tech) end
	addEvoThreshold(function(force, surface) return force.technologies[tech].researched end, evo, minT, maxT)
end

---@param item string
---@param amtFunc fun(force: LuaForce, surface: LuaSurface, evo: number): number
---@param evo number
---@param minT? number
---@param maxT? number
local function addResourceEvoThreshold(item, amtFunc, evo, minT, maxT)
	if not prototypes.item[item] and not prototypes.fluid[item] then fmterror("No such item '%s'!", item) end
	addEvoThreshold(function(force, surface)
		local stats = prototypes.fluid[item] and force.get_fluid_production_statistics(surface) or force.get_item_production_statistics(surface)
		return stats.get_output_count(item) >= amtFunc(force, surface, evo)
	end,
	evo, minT, maxT)
end

---@param entity string
---@param number int
---@param evo number
---@param minT? number
---@param maxT? number
--these are not very safe - mods can change the entity type progression
local function addConstructionEvoThreshold(entity, number, evo, minT, maxT)
	if not prototypes.entity[entity] then fmterror("No such entity '%s'!", entity) end
	addEvoThreshold(function(force, surface) return force.get_entity_count(entity) >= number end, evo, minT, maxT)
end

addTechEvoThreshold("electronics", 0) --do not allow evo if you have not started using copper
addTechEvoThreshold("automation-science-pack", 0.01)
addTechEvoThreshold("automation", 0.02)
addTechEvoThreshold("logistics", 0.02)
addTechEvoThreshold("gun-turret", 0.05)
--addTechEvoThreshold("military", 0.1)
addTechEvoThreshold("steel-processing", 0.2)
addTechEvoThreshold("military-2", 0.3)
addTechEvoThreshold("oil-processing", 0.4)
--addTechEvoThreshold("advanced-circuit", 0.5)
--addTechEvoThreshold("military-4", 0.75)
--addTechEvoThreshold("rocket-silo", 1.0)

addResourceEvoThreshold("automation-science-pack", function(force, surface, evo) return 200*game.difficulty_settings.technology_price_multiplier end, 0.25, -1, 3600*5)
addResourceEvoThreshold("logistic-science-pack", function(force, surface, evo) return 500*game.difficulty_settings.technology_price_multiplier end, 0.4, -1, 3600*8)
addResourceEvoThreshold("chemical-science-pack", function(force, surface, evo) return 200*game.difficulty_settings.technology_price_multiplier end, 0.6, 3600*2)
addResourceEvoThreshold("chemical-science-pack", function(force, surface, evo) return 1000*game.difficulty_settings.technology_price_multiplier end, 0.75, 3600*2, 3600*12)
addResourceEvoThreshold("production-science-pack", function(force, surface, evo) return 50*game.difficulty_settings.technology_price_multiplier end, 0.8, 3600, 3600*24)
addResourceEvoThreshold("utility-science-pack", function(force, surface, evo) return 50*game.difficulty_settings.technology_price_multiplier end, 0.8, 3600, 3600*24)
--addResourceEvoThreshold("crude-oil", function(force, surface, evo) return 1 end, 0.4)

--addConstructionEvoThreshold("rocket-silo", 1, 0.95)

--tesla turet on gleba - but entity count is not surface specific