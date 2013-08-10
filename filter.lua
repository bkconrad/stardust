-- Filter Selection
--
-- Reduce selection to objects of a certain type
--
-- This work is released into the public domain
-- Authored by kaen

VALID_TYPES = {
  "Asteroid",
  "AsteroidSpawn",
  "Core",
  "EnergyItem",
  "Flag",
  "FlagSpawn",
  "ForceFieldProjector",
  "GoalZone",
  "LineItem",
  "LoadoutZone",
  "Mine",
  "Nexus",
  "PolyWall",
  "RepairItem",
  "ResourceItem",
  "SoccerBallItem",
  "ShipSpawn",
  "SpeedZone",
  "SpyBug",
  "Teleporter",
  "TestItem",
  "TextItem",
  "Turret",
  "WallItem",
  "Zone",
}

-- return an ordered table of unique values in t
function uniqueValues(t)
  local values = { }
  local result = { }

  for k, v in pairs(t) do
    values[v] = true
  end

  for k, _ in pairs(values) do
    table.insert(result, k)
  end

  return result
end

function getArgsMenu()

  local selectedTypes = {}

  for _, obj in pairs(plugin:getSelectedObjects()) do
    for _, typeName in ipairs(VALID_TYPES) do
      if ObjType[typeName] == obj:getClassId() then
        table.insert(selectedTypes, typeName)
      end
    end
  end

	menu = 	{
		ToggleMenuItem.new("Filter by Type:", uniqueValues(selectedTypes), 1, "The desired object type")
	}

	return "Filter Selection", menu
end

function main()
  local objectType = table.remove(arg, 1)

  local objects = plugin:getSelectedObjects()

  for _, obj in pairs(objects) do
    if obj:getClassId() ~= ObjType[objectType] then
      obj:setSelected(false)
    end
  end
end   

