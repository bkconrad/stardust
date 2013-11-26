-- Bezier curve fitter
-- Adaptations are released into the public domain
-- Authored by kaen

local sd = require('stardust')

IMPLICITLY_CLOSED_CLASS_IDS = {
	[ObjType.GoalZone] = true,
	[ObjType.LoadoutZone] = true,
	[ObjType.PolyWall] = true,
	[ObjType.Zone] = true
}

function getArgsMenu()

  menu = {
    CounterMenuItem.new("Subdivisions", 32, 1, 1, 0xFFFF, "", ""                 , "Number of points in the generated objects"), 
    CounterMenuItem.new("Bezier Power", 20, 1, 1, 0xFF  , "", "No Bezier fitting", "Strength of Bezier curve fitting"), 
  }
  return "Bezier Curve Fitter", "Fit curve to polygons", "Ctrl+Shift+]", menu
end

function fitBezier(poly, subdivisions, power)
  if type(poly) ~= 'table' then
    return
  end

  -- true if the polygon's start and end are equal
  local inputClosed = false
  if poly[1] == poly[#poly] then
    inputClosed = true
  end

  local newPoly = {}
  local totalLength = sd.lengthOf(poly)

  local t = 0.0
  while t < 1.0 do
    -- find the segment in which t lies
    local segment, segmentStart, segmentEnd = sd.segmentAt(poly, t)
    local segment_t = (t - segmentStart) / (segmentEnd - segmentStart)

    -- evaluate the bezier for that segment
    local points = sd.getPoints(poly, segment - 1, 4)
    local newPoint = sd.evaluateCubicBezier(points, segment_t, power)
    table.insert(newPoly, newPoint)

    t = t + (1.0/subdivisions)
  end

  -- if the input poly is closed, close the output poly
  if poly[1] == poly[#poly] then
    table.insert(newPoly, newPoly[1])
  end

  return newPoly
end

function main()
  -- arg table will include values from menu items above, in order

  local gridsize = plugin:getGridSize()

  local scriptName = arg[0]
  local subdivisions = table.remove(arg, 1)
  local power = table.remove(arg, 1) / 100

  local objects = plugin:getSelectedObjects()

  for k, v in pairs(objects) do
    local geom = v:getGeom()
    if sd.implicitlyClosed(v) then
      table.insert(geom, geom[1])
    end
    newGeom = fitBezier(geom, subdivisions, power)
    if newGeom then
      v:setGeom(newGeom)
    end
  end
end 

