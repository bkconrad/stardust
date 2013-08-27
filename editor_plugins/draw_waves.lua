-- Parametric object generator
-- Create objects using math!
-- Adapted from the work of _k, raptor, and watusimoto.
-- Adaptations are released into the public domain
-- Authored by kaen

--
-- If this function exists, it should return a list of menu items that can be used to build an options menu
-- If this function is not implemented, or returns nil, the menu will not be displayed, and main() will be
-- run without args
--
-- For a full list of the menu widgets available, see the Bitfighter wiki on bitfighter.org
--
CONVENIENCE_VARIABLES = {
	"a",
	"b",
	"c",
	"d"
}

CONVENIENCE_DICTIONARY = { }

LIMITS_DICTIONARY = {
	BarrierMaker = 62,
	LoadoutZone = 30,
	GoalZone = 30,
	LineItem = 14
}

EVALUATE_CONTEXT = { TAU=6.28, PI=3.14}
for key, value in pairs(math) do
	EVALUATE_CONTEXT[key] = math[key]
end

function getArgsMenu()

	menu = 	{
		TextEntryMenuItem.new("X Equation",   "t", "", 256, "X coordinate in terms of t"),
		TextEntryMenuItem.new("Y Equation",   "t", "", 256, "Y coordinate in terms of t"),
		TextEntryMenuItem.new("t Min",   "0", "0", 256, "Starting value of t"),
		TextEntryMenuItem.new("t Max",   "100", "200", 256, "Maximum value of t"),
		TextEntryMenuItem.new("t Step",   "10", "10", 256, "Value add to t each step"),
		CounterMenuItem.new("Barrier Width",  50, 1,       1,    50, "grid units", "", "Width of wall if BarrierMaker is selected below"),
		TextEntryMenuItem.new("iterations",   "1", "1", 256, "Number of iterations to run"),
		ToggleMenuItem.new ("Type", { "BarrierMaker", "LoadoutZone", "GoalZone", "LineItem" }, 1, true, "Type of item to insert"),
	}

	for index, var in ipairs(CONVENIENCE_VARIABLES) do
		table.insert(menu, 
			TextEntryMenuItem.new(var,   "1", "1", 256, "Value of convenience variable " .. var)
		)
	end
	return "Function to Polygon", menu
end

function valueOf(str)
	return loadstring('return ' .. str)()
end

-- evaluates str in terms of t and i
function evaluate(str, t, i)
	EVALUATE_CONTEXT["t"] = t
	EVALUATE_CONTEXT["i"] = i
	f = loadstring('return ' .. str)
	setfenv(f, EVALUATE_CONTEXT)
	return f()
end

--
-- The main body of the code gets put in main()
--
function main()
	-- arg table will include values from menu items above, in order

	local gridsize = plugin:getGridSize()

	local scriptName = arg[0]
	local xFunction = table.remove(arg, 1)
	local yFunction = table.remove(arg, 1)
	local tMin = valueOf(table.remove(arg, 1))
	local tMax = valueOf(table.remove(arg, 1))
	local tStep = valueOf(table.remove(arg, 1))
	local barrierWidth = valueOf(table.remove(arg, 1))
	local iterations = valueOf(table.remove(arg, 1))
	local itemType = table.remove(arg, 1)

	for index, var in ipairs(CONVENIENCE_VARIABLES) do
		EVALUATE_CONTEXT[var] = table.remove(arg, 1)
	end

	local gridSize = plugin:getGridSize()

	for i = 1, iterations do
		t = tMin
		while t <= tMax do
			-- First part of the level line
			if(itemType == "BarrierMaker") then
				levelLine = itemType .. " " .. barrierWidth .. " "
			elseif(itemType == "LineItem") then
				levelLine = itemType .. " 0 " .. "1 "
			else
				levelLine = itemType .. " 0 "
			end
			numPoints = 0
			while t <= tMax do
				x = evaluate(xFunction, t, i) / gridSize
				y = evaluate(yFunction, t, i) / gridSize
				levelLine = levelLine .. " " .. x .. " " .. y
				numPoints = numPoints + 1

				if numPoints > LIMITS_DICTIONARY[itemType] then
					break
				end
				t = t + tStep
			end
			-- Now add item to the level
			plugin:addLevelLine(levelLine)
		end
	end
end   

