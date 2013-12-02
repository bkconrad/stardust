-- Offset ID
--
-- Add/subtract a number to the ID of all selected objects which have
-- user-assigned IDs.
--
-- This work is released into the public domain
-- Authored by kaen

function getArgsMenu()
	menu = 	{
		CounterMenuItem.new("Offset",  0, 1, -0xFFFF, 0xFFFF, "", "", "The number to add to each ID"),
	}
	return "Offset ID", "Add a value to the ID numbers of selected objects", menu
end

function main()
  local offset = table.remove(arg, 1)

	local objects = plugin:getSelectedObjects()

  for _, obj in ipairs(objects) do
    local id = obj:getId()
    if id >= 0 and id + offset >= 0 then
      obj:setId(id + offset)
    end
  end

end   

