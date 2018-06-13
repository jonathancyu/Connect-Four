--[[
TODO:
add settings
	change colors
	write toggles
	add sliders
	color pallette?	


 write animations?
]]
-- testing environment
do

end
-- end testing environment
local connectFour 	= require("connectFour")
local color 		= require("color")
local stack 		= require("stack")

local input 		= {}
local menu 			= {}
local game 			= {}



local board 		= connectFour.new()
local currentColor 	= 0

function love.load()
	love.window.setTitle("Connect Four")
	love.graphics.setBackgroundColor(131, 192, 240)
end

--draw
do 
	local firstCirclePos 	= _G.boardWidth/14 + _G.padding
	local circleDistance 	= _G.boardWidth/7
	local circleSize 		= 30

	function love.draw()
		if game.state == "playing" then
			love.graphics.setColor(255, 255, 204)
			for c = 0, 6 do
				for r = 0, 5 do
					if c+1 == input.column then
						love.graphics.setColor(255, 255, 204)
					else
						love.graphics.setColor(255, 255, 255)
					end
					local col, row = c+1, 6-r
					if board[col][row] ~= nil then
						if board[col][row] == 0 then
							love.graphics.setColor(196, 30, 58)
						else
							love.graphics.setColor(52, 52, 52)
						end
					end
					love.graphics.circle("fill", firstCirclePos + circleDistance*c, firstCirclePos + circleDistance*r, circleSize)
				end
			end
		elseif game.state == "menu" then
			menu.draw()
		end
	end
end

--input handling
do
	local firstColumn 		= _G.padding
	local columnSize 		= _G.boardWidth/7
	input.column 			= 1
	function love.update(dt)
		if game.state == "playing" then
			input.column = 1 + math.floor((love.mouse.getX() - _G.padding)/columnSize)
		elseif game.state == "menu" then
			menu.step(dt)
			local mouseX, mouseY = love.mouse.getX(), love.mouse.getY()
			for k, button in pairs(menu.getLocation().buttons) do
				if menu.isInBounds(mouseX, mouseY, 
								   button.x, button.y, button.width, button.height)	then
					button.mouseIsOver = true
				else					
					button.mouseIsOver = false
				end
				button.step(dt, mouseX, mouseY)
			end
		end
	end

	function love.mousepressed(x, y, button, istouch)
		if game.state == "playing" then
			if button == 1 then
				if input.column > 0 and input.column <= 7 then
					local result = board.place(input.column, game.currentColor)
					if result > 0 then
						game.swapColor()
						local winner = board.detectWin()
						if winner >= 0 then
							game.currentColor = 0
							board.reset()
							print(winner, "won")
						end
					end
				end
			end
		elseif game.state == "menu" then
			for k, button in pairs(menu.getLocation().buttons) do
				if button.mouseIsOver then
					button.clicked(x, y)
				end
			end
		end
	end
end
--menu
do	


	local location = {"main"}
	local status = "inactive" -- inactive, animating
	local animation = stack.new()
	local totalOffset = {x = 0, y = 0}
	local function tween(start, goal, delta)
		return start + ((goal-start) * delta)
	end

	local function newButton(text, x, y, width, height, _color, alpha, textColor, textAlpha, fontSize, clicked, mouseover, tweens, tweentime, data)
		local self = {
				text = text, 
				x = x, y = y, width = width, height = height, 
				startx = x, starty = y,
				color = _color,
				alpha = alpha,
				delta = 0,
				textColor = textColor,
				textAlpha = textAlpha,
				clicked = clicked, 
				mouseIsOver = false}
		if data then
			for i, v in pairs(data) do
				self[i] = v
			end
		end

		local tweenstarts = {}
		for val, goal in pairs(tweens) do
			tweenstarts[val] = self[val]
		end

		local font = love.graphics.newFont("Roboto.ttf", fontSize)

		function self.draw()
			love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.alpha)
			love.graphics.rectangle("fill", totalOffset.x + self.x, totalOffset.y + self.y, width, height) -- make text look better
			love.graphics.setColor(self.textColor.r, self.textColor.g, self.textColor.b, self.textAlpha)
			love.graphics.setFont(font)
			love.graphics.print(text, totalOffset.x + self.x, totalOffset.y + self.y)
		end

		function self.step(dt, x, y)
			if self.mouseIsOver then
				if self.delta < 1 then
					self.delta = math.min(self.delta + (dt/tweentime), 1)
				end
			else
				if self.delta > 0 then
					self.delta = math.max(self.delta - (dt/tweentime), 0)
				end
			end
			for val, goal in pairs(tweens) do
				self[val] = tween(tweenstarts[val], goal, self.delta)
			end
		end

		function self.reset()
			self.delta = 0
			for val, goal in pairs(tweens) do
				self[val] = tweenstarts[val]
			end
		end

		return self
	end

	local function resetButtons()
		local buttons = menu.getLocation().buttons
		for name, button in pairs(buttons) do
			button.reset()
		end
	end

	local hierarchy = {
		main = {
			name = "main",
			buttons = {
				play 		= newButton("PLAY",
								20, 330, 100, 40, 
								color.new(255, 255, 255),
								10,
								color.new(255, 255, 255),
								255,
								40,
								function(x, y)
									resetButtons()
									status = "animating"
									animation.push(
										function(dt)
											print(totalOffset.x)
											totalOffset.x = totalOffset.x + 500*dt
										end, 
										1, 
										function()
											status = "inactive"
											game.state = "playing"
										end)
								end,
								function(self, dt)
									tweenMouseOver(self, dt)
									tweenTextColorMouseOver(self, dt)
								end,
								{textColor = color.new(0, 0, 0), 
								x = 30},
								.2
								),
				settings 	= newButton("settings",
								20, 370, 100, 30, 
								color.new(255, 255, 255),
								0,
								color.new(255, 255, 255),
								255,
								30,
								function(x, y)
									resetButtons()
									table.insert(location, "settings")
								end,
								function(self, dt)
									tweenMouseOver(self, dt)
									tweenTextColorMouseOver(self, dt)
								end,
								{textColor = color.new(0, 0, 0), 
								x = 30},
								.2
								),
				credits 	= newButton("credits",
								20, 400, 100, 30,
								color.new(255, 255, 255),
								0,
								color.new(255, 255, 255),
								255,
								30,
								function(x, y)
									resetButtons()
									table.insert(location, "credits")
								end,
								function(self, dt)
									tweenMouseOver(self, dt)
									tweenTextColorMouseOver(self, dt)
								end,
								{textColor = color.new(0, 0, 0), 
								x = 30},
								.2
								),
				quit		= newButton("quit",
								20, 430, 100, 30,
								color.new(255, 255, 255),
								0,
								color.new(255, 255, 255),
								255,
								30,
								function(x, y)
									love.window.close()
								end,
								function(self, dt)
									tweenMouseOver(self, dt)
									tweenTextColorMouseOver(self, dt)
								end,
								{textColor = color.new(0, 0, 0), 
								x = 30},
								.2
								),
			},
			settings = {
				name = "settings",
				buttons = {
						back 	= newButton("back",
									20, 430, 100, 30,
									color.new(255, 255, 255),
									0,
									color.new(255, 255, 255),
									255,
									30,
									function(x, y)
										table.remove(location, #location)
									end,
									function(self, dt)
										tweenMouseOver(self, dt)
										tweenTextColorMouseOver(self, dt)
									end,
									{textColor = color.new(0, 0, 0), 
									x = 30},
									.2
									),
				}
			},
			credits = {
				name = "settings",
				buttons = {
						back 	= newButton("back",
									20, 430, 100, 30,
									color.new(255, 255, 255),
									0,
									color.new(255, 255, 255),
									255,
									30,
									function(x, y)
										table.remove(location, #location)
									end,
									function(self, dt)
										tweenMouseOver(self, dt)
										tweenTextColorMouseOver(self, dt)
									end,
									{textColor = color.new(0, 0, 0), 
									x = 30},
									.2
									),
				}
			}			
		},
	}

	function menu.getLocation()
		local currentLocation = hierarchy
		for k, v in pairs(location) do
			currentLocation = currentLocation[v]
		end
		return currentLocation
	end

	function menu.isInBounds(mouseX, mouseY, x, y, width, height)
		return ((mouseX > x and mouseX < x + width) and (mouseY > y and mouseY < y + height))
	end

	function menu.draw()
		local currentLocation = menu.getLocation()
		for k, button in pairs(currentLocation.buttons) do
			button.draw()
		end
	end

	function menu.step(dt)
		animation.step(dt)
	end
end

--game state
do 
	game.currentColor 	= 0
	game.state 			= "menu"
	function game.swapColor()
		game.currentColor = (game.currentColor + 1)%2
	end

	function game.setState(newState)
		game.state = newState
	end
end