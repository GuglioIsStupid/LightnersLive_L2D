local cafe = {}

local krisWalker = require("krisWalker")

function cafe:enter()
    krisWalker:init()
end

function cafe:update(dt)
    krisWalker:update(dt)
end

function cafe:draw()
    krisWalker:draw()
end

return cafe