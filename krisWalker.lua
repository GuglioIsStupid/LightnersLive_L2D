local krisWalker = {}

local function getPath(path)
    return "assets/Fun Gang Walk/" .. path
end

local susieWalker = require("susieWalker")
local ralseiWalker = require("ralseiWalker")

local function krisAnim(anim)
    local anims = {}
    for _, file in ipairs(love.filesystem.getDirectoryItems(getPath("Kris/Kris " .. anim))) do
        if file:match("%.png$") then
            table.insert(anims, love.graphics.newImage(getPath("Kris/Kris " .. anim .. "/" .. file)))
        end
    end
    return anims
end

-- New helper function
local function distanceSquared(x1, y1, x2, y2)
    return (x2 - x1)^2 + (y2 - y1)^2
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
    }

    self.isMoving = false
    self.isRunning = false
    self.fps = 8

    self._anims = {
        down = krisAnim("Down"),
        up = krisAnim("Up"),
        left = krisAnim("Left"),
        right = krisAnim("Right"),
    }

    self.x = self.x + self._anims[self.curDir][1]:getWidth() / 2
    self.y = self.y + self._anims[self.curDir][1]:getHeight()

    self.lastRecordedX = self.x
    self.lastRecordedY = self.y
    self.recordThresholdSq = 2^2
    self.drawList = {}

    table.insert(self.positions, {x = self.x, y = self.y, dir = self.curDir})

    for i, follower in ipairs(self.followers) do
        follower:init()
        follower.trailOffset = i * 16
        follower.index = 1
        follower.x = self.x
        follower.y = self.y
    end
end

function krisWalker:update(dt)
    local lastDir = self.curDir
    if self.isMoving then
        self.curFrame = self.curFrame + self.fps * dt
        if self.curFrame > #self._anims[self.curDir]+1 then
            self.curFrame = 1
        end
    end

    local dx, dy = 0, 0
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        dy = -self.speed * dt
        self.curDir = "up"
    elseif love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        dy = self.speed * dt
        self.curDir = "down"
    end
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        dx = -self.speed * dt
        self.curDir = "left"
    elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        dx = self.speed * dt
        self.curDir = "right"
    end
    if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
        dx = dx * self.runSpeedMultiplier
        dy = dy * self.runSpeedMultiplier
        self.isRunning = true
    else
        self.isRunning = false
    end

    local moved = dx ~= 0 or dy ~= 0

    if self.curDir ~= lastDir or not moved then
        self.curFrame = 1
    end

    self.isMoving = moved
    if moved then
        self.x = self.x + dx
        self.y = self.y + dy

        if distanceSquared(self.x, self.y, self.lastRecordedX, self.lastRecordedY) > self.recordThresholdSq then
            table.insert(self.positions, {x = self.x, y = self.y, dir = self.curDir})
            self.lastRecordedX = self.x
            self.lastRecordedY = self.y
        end

        if #self.positions > self.maxTrailLength then
            table.remove(self.positions, 1)
        end
    end

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

    for i = #self.drawList, 1, -1 do
        self.drawList[i] = nil
    end

    self.drawList[1] = { sprite = self, y = self.y }
    for _, follower in ipairs(self.followers) do
        self.drawList[#self.drawList+1] = { sprite = follower, y = follower.y }
    end

    table.sort(self.drawList, function(a, b) return a.y < b.y end)
end

function krisWalker:draw()
    for _, entry in ipairs(self.drawList) do
        local char = entry.sprite
        local anim = char._anims[char.curDir]
        if anim and #anim > 0 then
            local frame = math.floor(char.curFrame)
            love.graphics.draw(anim[frame], char.x, char.y, 0, 1, 1, anim[frame]:getWidth()/2, anim[frame]:getHeight())
        end
    end
end

return krisWalker
