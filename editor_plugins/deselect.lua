-- Reduce Selection
--
-- Randomly deselect a percentage of selected objects
--
-- This work is released into the public domain
-- Authored by kaen

function getArgsMenu()
	menu = 	{
    CounterMenuItem.new("Percentage",  50, 1,       1,    100, "", "", "Percentage of objects to deselect"),
	}

	return "Reduce Selection", "Randomly deselect a percentage of selected objects", "Ctrl+Shift+5", menu
end

function main()
  local percentage = table.remove(arg, 1)
  local objects = plugin:getSelectedObjects()

  for _, obj in pairs(objects) do
    if math.random() < percentage / 100 then
      obj:setSelected(false)
    end
  end
end   

