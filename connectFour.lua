local connectFour = {}

local directions = {{c=1, r=0}, {c=0, r=1}, {c=1, r=1}, {c=1, r=-1}}
				 -- right    	up     		upright 	upleft

function connectFour.new()
	local board = {}
	local lastcolumn, lastcolor

	-- setup board
	local function reset()
		lastcolumn, lastcolor = 1, -1
		for i = 1, 7 do
			board[i] = {}
		end
	end
	reset()

	local function place(column, color) --0 red 1 black
		if column > 7 or column < 0 then
			return -1 -- invalid move
		else 
			local count = #board[column]
			if count > 6 then
				return -2 -- column is full
			else 
				table.insert(board[column], color)
				lastcolumn = column
				lastcolor = color
				return 1
			end
		end
	end

	local function print()
		for r = 6, 1, -1 do
			io.write(r.."|")
			for c = 1, 7 do				
				val = board[c][r]
				io.write((r > 1) and " " or "_")
				if val == nil then
					io.write("O")
				elseif val == 0 then
					io.write("R")
				elseif val == 1 then
					io.write("B")
				end
				io.write((r > 1) and " " or "_")
			end
			io.write("|\n")
		end
		io.write("  ")
		for c = 1, 7 do
			io.write(" "..c.." ")
		end
		io.write("\n")
	end 

	local function checkLine(startCol, startRow, dCol, dRow) -- should never be nil color
		local count = 1
		local firstColor = board[startCol][startRow]
		for i = 1, 3 do
			local col, row = startCol + i*dCol, startRow + i*dRow
			if (col < 1 or row < 1) or (col > 7 or row > 6) or (board[col][row] == nil or board[col][row] ~= firstColor) then
				return count
			else
				count = count + 1
			end
		end
		return count
	end

	local function detectWin(column, color) 
		if not column then
			column = lastcolumn 
			color = lastcolor
		end

		local row = #board[column]
		--check {{1, 0}, {0, 1}, {1, 1}, {1, -1}}
		for i, dir in pairs(directions) do
			local left = checkLine(column, row, -dir.c, -dir.r) - 1
			local right = checkLine(column, row, dir.c, dir.r)
			if left + right >= 4 then
				print("direction ", dir.c, dir.r)
				return color
			end
		end
		return -1
	end

	return setmetatable({ 
						 ["print"] 	= print,
						   reset 	= reset,
						   place 	= place,
						   detectWin= detectWin},
						 {__index = board})
end

return connectFour