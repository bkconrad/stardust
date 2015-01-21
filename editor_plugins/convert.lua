-- Convert Objects
-- Converts selected polygonal objects in to the specified type, keeping the
-- same geometry
--
-- This work is released into the public domain
-- Authored by kaen

local sd = require('stardust')

function getArgsMenu()

  local menu
  if #plugin:getSelectedObjects() ~= 0 then
  	menu = 	{
  		ToggleMenuItem.new("New Object Type", sd.VALID_TYPES, 1, "Object type to convert to"),
  		YesNoMenuItem.new("Delete Old Objects", 2, "Delete the original objects after the new ones are created")
  	}
  end

	return "Convert Objects", "Convert all selected objects to another type", "Ctrl+Shift+.", menu
end

function main()
  local objectType = ObjType[table.remove(arg, 1)]
  local deleteOld  = table.remove(arg, 1)

  local objects = plugin:getSelectedObjects()
  if #objects == 0 then
    plugin:showMessage('Please select at least one object', false)
    return
  end

  for _, obj in pairs(objects) do
    obj:setSelected(false)
    local geom = obj:getGeom()
    print(objectType)
    local newObj = sd.OBJTYPE_TO_CLASS[objectType].new()

    if type(geom) == "table" then
      -- add or remove closing point as needed
      if sd.implicitlyClosed(obj) then
        if not sd.implicitlyClosed(newObj) then
          table.insert(geom, geom[1])
        end
      elseif sd.reallyClose(geom[1], geom[#geom]) then
        if sd.implicitlyClosed(newObj) then
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

