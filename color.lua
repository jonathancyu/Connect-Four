local color = {}

function color.new(r, g, b)
	return setmetatable(
			{__type = "color", r = r, g = g, b = b,
			["print"] = function()
				print(r, g, b)
			end}, {
			__mul = function(a, b)			
				if type(b) == "number" then
					return color.new(a.r*b, a.g*b, a.b*b)
				else
					return color.new(b.r*a, b.g*a, b.b*a)
				end
			end,
			__div = function(a, b)			
				if type(b) == "number" then
					return color.new(a.r/b, a.g/b, a.b/b)
				else
					return color.new(b.r/a, b.g/a, b.b/a)
				end
			end,
			__add = function(a, b)
				return color.new(a.r + b.r, a.g + b.g, a.b + b.b)
			end,
			__sub = function(a, b)
				return color.new(a.r - b.r, a.g - b.g, a.b - b.b)
			end,
			__unm = function(a)
				return color.new(-a.r, -a.g, -a.b)
			end,
			__call = function(a)
				return color.new(a.r, a.g, a.b)
			end
		})
end

return color