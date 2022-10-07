require "config"

require "__DragonIndustries__.items"

THRESHOLDS = {
	
}

local function addTechEvoThreshold(tech, evo)
	--if not game.technology_prototypes[tech] then return end
	if not THRESHOLDS[evo] then
		THRESHOLDS[evo] = {}
	end
	table.insert(THRESHOLDS[evo], function(force) return force.technologies[tech].researched end)
end

local function addResourceEvoThreshold(item, amtFunc, evo)
	--if not game.technology_prototypes[tech] then return end
	if not THRESHOLDS[evo] then
		THRESHOLDS[evo] = {}
	end
	table.insert(THRESHOLDS[evo],
	function(force)
		local form = getItemType(item)
		local stats = form == "fluid" and force.fluid_production_statistics or force.item_production_statistics
		return stats.get_output_count(item) >= amtFunc(force, evo)
	end
	)
end

--these are not safe - mods can change the entity type progression
local function addConstructionEvoThreshold(evo, entity, number)
	if not THRESHOLDS[evo] then
		THRESHOLDS[evo] = {}
	end
	table.insert(THRESHOLDS[evo], function(force) return force.get_entity_count(entity) >= number end)
end

local function addMiscEvoThreshold(evo, func)
	if not THRESHOLDS[evo] then
		THRESHOLDS[evo] = {}
	end
	table.insert(THRESHOLDS[evo], func)
end

addTechEvoThreshold("gun-turret", 0.01)
addTechEvoThreshold("steel-processing", 0.2)
addTechEvoThreshold("military", 0.1)
addTechEvoThreshold("military-2", 0.3)
addTechEvoThreshold("advanced-electronics", 0.5)
addTechEvoThreshold("military-3", 0.7)
addTechEvoThreshold("military-4", 0.895)
addTechEvoThreshold("advanced-electronics-2", 0.895)

addResourceEvoThreshold("chemical-science-pack", function(force, evo) return 25*game.difficulty_settings.technology_price_multiplier end, 0.5)
addResourceEvoThreshold("crude-oil", function(force, evo) return 1 end, 0.4)

--addResourceProductionEvoThreshold("coal", 0.25)
--addResourceProductionEvoThreshold("iron-ore", 0.25)
--addResourceProductionEvoThreshold("copper-ore", 0.25)

--addConstructionEvoThreshold(0.05, "electric-mining-drill", 2)
--addConstructionEvoThreshold(0.4, "oil-refinery", 1)