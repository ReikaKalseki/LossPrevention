require "config"

THRESHOLDS = {
	
}

local function addTechEvoThreshold(tech, evo)
	--if not game.technology_prototypes[tech] then return end
	if not THRESHOLDS[evo] then
		THRESHOLDS[evo] = {}
	end
	table.insert(THRESHOLDS[evo], function(force) return force.technologies[tech].researched end)
end

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

addTechEvoThreshold("turrets", 0.01)
addTechEvoThreshold("steel-processing", 0.2)
addTechEvoThreshold("military", 0.1)
addTechEvoThreshold("military-2", 0.3)
addTechEvoThreshold("military-3", 0.7)

addConstructionEvoThreshold(0.05, "electric-mining-drill", 2)
addConstructionEvoThreshold(0.4, "oil-refinery", 1)

addMiscEvoThreshold(0.5, function(force)
	return force.item_production_statistics.get_output_count("science-pack-3") >= 25*game.difficulty_settings.technology_price_multiplier
end)