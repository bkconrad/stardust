-- Enumerate
-- This work is released into the public domain
-- Authored by kaen

function getArgsMenu()
	menu = 	{
		CounterMenuItem.new("Starting Number",  0, 10, 0, 0xFFFF, "", "", "The number to start the IDs at"),
		CounterMenuItem.new("Increment",  1, 1, -0xFFFF, 0xFFFF, "", "", "The number to start the IDs at"),
	}
	return "Enumerate", menu
end

function main()
	local start = table.remove(arg, 1)
  local inc = table.remove(arg, 1)

	local objects = plugin:getSelectedObjects()

	if #objects < 1 then
		return
	end

  local current = start
  for _, obj in ipairs(objects) do
    obj:setId(current)
    current = current + inc
  end

end   

