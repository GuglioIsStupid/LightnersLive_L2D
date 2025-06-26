love.graphics.setDefaultFilter("nearest", "nearest")
local res = {320, 240}
local canvas = love.graphics.newCanvas(res[1], res[2])

local curState = nil
function switchState(newState)
    if curState and curState.exit then
        curState:exit()
    end

    curState = newState

    if curState and curState.enter then
        curState:enter()
    end
end

cafe = require("states.cafe")
live = require("states.live")

switchState(cafe)

function love.update(dt)
    if curState and curState.update then
        curState:update(dt)
    end
end

function love.keypressed(key)
    if key == "l" and curState == cafe then
        cafe:addLancerWalkerSecret()
    end
end

function love.draw()
    love.graphics.setCanvas(canvas)
        love.graphics.clear()
        if curState and curState.draw then
            curState:draw()
        end
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(canvas, 0, 0, 0, love.graphics.getWidth() / res[1], love.graphics.getHeight() / res[2])

    love.graphics.setColor(0, 0, 0)
    for x = -1, 1 do
        for y = -1, 1 do
            love.graphics.printf("FPS: " .. love.timer.getFPS(), x, y, love.graphics.getWidth(), "right")
        end
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("FPS: " .. love.timer.getFPS(), 0, 0, love.graphics.getWidth(), "right")
end
