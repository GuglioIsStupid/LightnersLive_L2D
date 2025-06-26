local krisWalker = {}

local function getPath(path)
    return "assets/Fun Gang Walk/" .. path
end

local susieWalker = require("susieWalker")
local ralseiWalker = require("ralseiWalker")
local lancerWalker = require("LancerWalker")

local function krisAnim(anim)
    local anims = {}
    for _, file in ipairs(love.filesystem.getDirectoryItems(getPath("Kris/Kris " .. anim))) do
        if file:match("%.png$") then
            table.insert(anims, love.graphics.newImage(getPath("Kris/Kris " .. anim .. "/" .. file)))
        end
    end
    return anims
end

local function distanceSquared(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return dx*dx + dy*dy
end

function krisWalker:init()
    self.curDir = "down"
    self.curFrame = 1
    self.x, self.y = 0, 0
    self.speed = 100
    self.runSpeedMultiplier = 1.5

    self.positions = {}
    self.maxTrailLength = 1000

    self.followers = {
        susieWalker,
        ralseiWalker,
        lancerWalker
    }

    self.isMoving = false
    self.isRunning = false
    self.fps = 4
    self.goingBackInFrames = false

    self._anims = {
        down = krisAnim("Down"),
        up = krisAnim("Up"),
        left = krisAnim("Left"),
        right = krisAnim("Right"),
    }

    local firstFrame = self._anims[self.curDir][1]
    self.x = self.x + firstFrame:getWidth() / 2
    self.y = self.y + firstFrame:getHeight()

    self.lastRecordedX = self.x
    self.lastRecordedY = self.y
    self.recordThresholdSq = 1
    self.drawList = {}
    self.hasLancerWalkerSecret = false

    table.insert(self.positions, {x = self.x, y = self.y, dir = self.curDir})

    for i, follower in ipairs(self.followers) do
        follower:init()
        follower.trailOffset = i * 32
        follower.index = 1
        follower.x = self.x
        follower.y = self.y
    end
end

function krisWalker:addLancerWalkerSecret()
    self.hasLancerWalkerSecret = true
    lancerWalker:play()
end

function krisWalker:update(dt)
    local lastDir = self.curDir
    local dx, dy = 0, 0

    local up = love.keyboard.isDown("up", "w")
    local down = love.keyboard.isDown("down", "s")
    local left = love.keyboard.isDown("left", "a")
    local right = love.keyboard.isDown("right", "d")
    local running = love.keyboard.isDown("lshift", "rshift")

    if up then
        dy = dy - 1
    elseif down then
        dy = dy + 1
    end
    if left then
        dx = dx - 1
    elseif right then
        dx = dx + 1
    end

    self.isMoving = dx ~= 0 or dy ~= 0

    if self.isMoving then
        -- Determine direction priority (last pressed direction)
        if up then self.curDir = "up"
        elseif down then self.curDir = "down"
        elseif left then self.curDir = "left"
        elseif right then self.curDir = "right" end

        local moveSpeed = self.speed * (running and self.runSpeedMultiplier or 1)
        self.x = self.x + dx * moveSpeed * dt
        self.y = self.y + dy * moveSpeed * dt

        if distanceSquared(self.x, self.y, self.lastRecordedX, self.lastRecordedY) > self.recordThresholdSq then
            table.insert(self.positions, {x = self.x, y = self.y, dir = self.curDir})
            self.lastRecordedX = self.x
            self.lastRecordedY = self.y

            if #self.positions > self.maxTrailLength then
                table.remove(self.positions, 1)
            end
        end

        self.curFrame = self.curFrame + self.fps * dt * (running and self.runSpeedMultiplier or 1)
        local maxFrame = #self._anims[self.curDir]+1
        if self.curFrame > maxFrame then
            self.curFrame = 1
        end
    else
        self.curFrame = 1
    end

    self.isRunning = running

    for _, follower in ipairs(self.followers) do
        local index = #self.positions - follower.trailOffset
        if index > 0 then
            local pos = self.positions[index]
            follower.x = pos.x
            follower.y = pos.y
            follower.curDir = pos.dir or follower.curDir
            follower.curFrame = self.curFrame
        end
    end

    self.drawList = {
        { sprite = self, y = self.y },
    }
    for _, follower in ipairs(self.followers) do
        table.insert(self.drawList, { sprite = follower, y = follower.y })
    end

    table.sort(self.drawList, function(a, b) return a.y < b.y end)
end

function krisWalker:draw()
    for _, entry in ipairs(self.drawList) do
        local char = entry.sprite
        if char.visible == false then
            goto continue
        end
        local anim = char._anims[char.curDir]
        if not anim then anim = char._anims.idle end
        if anim and #anim > 0 then
            local frame = math.floor(char.curFrame) % #anim + 1
            local image = anim[frame]
            love.graphics.draw(image, char.x, char.y, 0, 1, 1, image:getWidth()/2, image:getHeight())
        end

        ::continue::
    end
end

return krisWalker
