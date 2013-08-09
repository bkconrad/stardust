-- Convert Objects
-- Converts selected polygonal objects in to the specified type, keeping the
-- same geometry
--
-- This work is released into the public domain
-- Authored by kaen

IMPLICITLY_CLOSED_CLASS_IDS = {
	[ObjType.GoalZone] = true,
	[ObjType.LoadoutZone] = true,
	[ObjType.PolyWall] = true,
	[ObjType.Zone] = true
}

TARGET_TYPES = {
  "WallItem",
  "PolyWall",
  "Zone",
  "LoadoutZone",
  "GoalZone",
  "LineItem",
  "FlagItem",
  "ResourceItem",
  "TestItem",
  "Mine",
  "SpyBug",
  "SoccerBallItem",
  "Spawn",
  "RepairItem",
  "EnergyItem",
  "SpeedZone",
  "Turret",
  "ForceFieldProjector",
  "Teleporter",
  "Asteroid",
}

function getArgsMenu()

	menu = 	{
		ToggleMenuItem.new("New Object Type", TARGET_TYPES, 1, "Object type to convert to"),
		YesNoMenuItem.new("Delete Old Objects", 2, "Delete the original objects after the new ones are created")
	}

	return "Convert Objects", menu
end

-- map of object types to default arguments
OBJECT_MAP = {
}

function main()
  local objectType = table.remove(arg, 1)
  local deleteOld  = table.remove(arg, 1)

  local objects = plugin:getSelectedObjects()

  for _, obj in pairs(objects) do
    obj:setSelected(false)
    local geom = obj:getGeom()
    local constructor = loadstring("return " .. objectType .. ".new")()
    local newObj = constructor()

    if type(geom) == "table" then
      -- add or remove closing point as needed
      if IMPLICITLY_CLOSED_CLASS_IDS[obj:getClassId()] then
        if not IMPLICITLY_CLOSED_CLASS_IDS[newObj:getClassId()] then
          table.insert(geom, geom[1])
        end
      elseif geom[1] == geom[#geom] then
        if IMPLICITLY_CLOSED_CLASS_IDS[newObj:getClassId()] then
          table.remove(geom, #geom)
        end
      end
    end

    newObj:setGeom(geom)
    newObj:setSelected(true)
    bf:addItem(newObj)

    if deleteOld == "Yes" then
      obj:removeFromGame()
    end
  end
end   

