local ralseiWalker = {}

local function getPath(path)
    return "assets/Fun Gang Walk/" .. path
end

local function ralseiAnim(anim)
    local anims = {}
    for _, file in ipairs(love.filesystem.getDirectoryItems(getPath("Ralsei/Ralsei " .. anim))) do
        if file:match("%.png$") then
            table.insert(anims, love.graphics.newImage(getPath("Ralsei/Ralsei " .. anim .. "/" .. file)))
        end
    end

    return anims
end

function ralseiWalker:init()
    self.curDir = "down" ---@type string
    self.curFrame = 1 ---@type number -- 4 frames per. Idle pose is frame 1

    self.x, self.y = 0, 0 ---@type number, number
    self.speed = 100 ---@type number -- Pixels per second
    self.runSpeedMultiplier = 1.5 ---@type number -- Multiplier for running speed

    self.positions = {} -- Used for followers
    self.followers = {} -- Used for followers

    self.isMoving = false ---@type boolean
    self.isRunning = false ---@type boolean
    self.fps = 8 ---@type number -- Frames per second

    self._anims = {
        down = ralseiAnim("Down"),
        up = ralseiAnim("Up"),
        left = ralseiAnim("Left"),
        right = ralseiAnim("Right"),
    }

    print("Ralsei Walker initialized with animations for directions: down, up, left, right")
end

return ralseiWalker