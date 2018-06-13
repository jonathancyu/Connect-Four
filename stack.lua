local stack = {}

local tick = love.timer.getTime

function stack.new(queue)
	local order = {}
	local currentstart
	local currentfunc

	local function push(func, dur, endfunc)
		table.insert(order, {func=func, dur=dur, endfunc=endfunc})
	end

	local function step(dt)
		if currentfunc then
			if tick() - currentstart > currentfunc.dur then
				table.remove(order, 1)
				currentfunc.endfunc(dt)
				currentfunc = nil
			else
				currentfunc.func(dt)
			end
		else
			if order[1] then
				currentfunc = order[1]
				currentstart = tick()
				step(dt)
			end
		end
	end

	local function clear()
		for i, v in pairs(order) do
			table.remove(order, i)
		end
	end

	return {push=push, pop=pop, clear=clear, step=step}
end

return stack