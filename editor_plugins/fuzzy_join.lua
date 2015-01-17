local sd = require('stardust')
function getArgsMenu()
	return "Fuzzy Join", "Join stubborn barriers", "Ctrl+Shift+J"
end

function main()
	local objects = plugin:getSelectedObjects()
	local joinOccured = true
	objects = sd.keep(objects, WallItem)
  print(#objects)

	while joinOccured do
		joinOccured = false

		for i=1,#objects do
			local a = objects[i]:getGeom()

			for j=i+1,#objects do
				local b = objects[j]:getGeom()
				local result = fuzzyJoin(a, b)

				if i ~= j and result then
					-- TODO: average width?
					local newWallItem = WallItem.new(result, 50)
					objects[i]:removeFromGame()
					objects[j]:removeFromGame()
					table.remove(objects, j)
					table.remove(objects, i)
					table.insert(objects, newWallItem)
					bf:addItem(newWallItem)
					joinOccured = true
					break
				end
			end

			if joinOccured then
				break
			end
		end
	end
end

function fuzzyJoin(a, b)
	local delta = 2500.0
	local result

	-- check end point connections
	for aIndex=1,#a,#a-1 do
		for bIndex=1,#b,#b-1 do
      print()
      print(aIndex)
      print(bIndex)
			-- TODO: average join point
			if point.distSquared(a[aIndex], b[bIndex]) <= delta then
				local first, last
				if aIndex == 1 and bIndex == 1 then
					first, last = sd.reverse(a), b
				elseif aIndex == 1 then
					first, last = b, a
				elseif bIndex == 1 then
					first, last = a, b
				else
					first, last = a, sd.reverse(b)
				end

				local mid = midpoint(first[#first], last[1])

				-- remove the connected points
				table.remove(first, #first)
				table.remove(last, 1)

				return sd.concat(first, mid, last)
			end
		end
	end
end

function midpoint(a, b)
	return a + (.5 * (b-a))
end
