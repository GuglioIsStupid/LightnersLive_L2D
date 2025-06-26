local susieWalker = {}

local function getPath(path)
    return "assets/Fun Gang Walk/" .. path
end

local function susieAnim(anim)
    local anims = {}
    for _, file in ipairs(love.filesystem.getDirectoryItems(getPath("Susie/Susie " .. anim))) do
        if file:match("%.png$") then
            table.insert(anims, love.graphics.newImage(getPath("Susie/Susie " .. anim .. "/" .. file)))
        end
    end

    return anims
end

function susieWalker:init()
    self.curDir = "down" ---@type string
    self.curFrame = 1 ---@type number -- 4 frames per. Idle pose is frame 1

    self.x, self.y = 0, 0 ---@type number, number
    self.speed = 50 ---@type number -- Pixels per second
    self.runSpeedMultiplier = 1.75 ---@type number -- Multiplier for running speed

    self.positions = {} -- Used for followers
    self.followers = {} -- Used for followers

    self.isMoving = false ---@type boolean
    self.isRunning = false ---@type boolean
    self.fps = 8 ---@type number -- Frames per second

    self._anims = {
        down = susieAnim("Down"),
        up = susieAnim("Up"),
        left = susieAnim("Left"),
        right = susieAnim("Right"),
    }

    print("Susie Walker initialized with animations for directions: down, up, left, right")
end

return susieWalker