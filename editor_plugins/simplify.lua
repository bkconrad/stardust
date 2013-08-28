-- Polygon simplification
-- Simplify (a.k.a smooth) polygons using midpoint reduction
-- This work is released into the public domain
-- Authored by kaen
require('stardust')

function main()

	local objects = plugin:getSelectedObjects()

	for k, v in pairs(objects) do
		if type(v:getGeom()) == "table" then
			newGeom = sd.simplify(v:getGeom())
			v:setGeom(newGeom)
		end
	end
end   

