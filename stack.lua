local stack = {}

function stack.new(queue)
	local self = {
		queue = queue or {}
	}

	local events = {}

	function self.push(name, func)
		table.insert(self.queue, name)
		events[name] = func
	end

	function self.pop()
		events[queue[1]]()
		events[queue[1]] = nil
		table.remove(queue, 1)
	end

	function self.clear()
		for k, v in pairs(events) do events[k] = nil end
		for k, v in pairs(self.queue) do self.queue[k] = nil end
	end

	return self
end