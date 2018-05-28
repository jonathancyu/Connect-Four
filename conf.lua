io.stdout:setvbuf("no")
_G.boardWidth = 525
_G.boardHeight = 450
_G.padding = 15
function love.conf(t)
	t.console = false
	t.window.width = _G.boardWidth + (_G.padding * 2)
	t.window.height = _G.boardHeight + (_G.padding * 2)
end