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
	addEvoThreshold(function(force, surface) return force.technologies[tech].researched end, evo, minT, maxT)
end

---@param item string
---@param amtFunc fun(force: LuaForce, surface: LuaSurface, evo: number): number
---@param evo number
---@param minT? number
---@param maxT? number
local function addResourceEvoThreshold(item, amtFunc, evo, minT, maxT)
	addEvoThreshold(function(force, surface)
		local form = getItemOrFluidType(item)
		local stats = form == "fluid" and force.get_fluid_production_statistics(surface) or force.get_item_production_statistics(surface)
		return stats.get_output_count(item) >= amtFunc(force, surface, evo)
	end,
	evo, minT, maxT)
end

---@param entity string
---@param number int
---@param evo number
---@param minT? number
---@param maxT? number
--these are not safe - mods can change the entity type progression
local function addConstructionEvoThreshold(entity, number, evo, minT, maxT)
	addEvoThreshold(function(force, surface) return force.get_entity_count(entity) >= number end, evo, minT, maxT)
end

addTechEvoThreshold("automation-science", 0) --do not allow evo if you have not 
addTechEvoThreshold("automation-science-pack", 0.01)
addTechEvoThreshold("gun-turret", 0.05)
addTechEvoThreshold("military", 0.1)
addTechEvoThreshold("steel-processing", 0.2)
addTechEvoThreshold("military-2", 0.3)
addTechEvoThreshold("advanced-electronics", 0.5)
addTechEvoThreshold("military-3", 0.7)
addTechEvoThreshold("concrete-2", 0.75)
addTechEvoThreshold("military-4", 0.895)
addTechEvoThreshold("advanced-electronics-2", 0.8)

addResourceEvoThreshold("chemical-science-pack", function(force, surface, evo) return 25*game.difficulty_settings.technology_price_multiplier end, 0.5)
addResourceEvoThreshold("crude-oil", function(force, surface, evo) return 1 end, 0.4)