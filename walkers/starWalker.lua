local starWalker = {}

local function getPath(path)
    return "assets/Fun Gang Walk/" .. path
end

function starWalker:init()
    self.curDir = "down" ---@type string
    self.curFrame = 1 ---@type number -- 4 frames per. Idle pose is frame 1

    self.x, self.y = 0, 0 ---@type number, number
    self.speed = 50 ---@type number -- Pixels per second
    self.runSpeedMultiplier = 1.75 ---@type number -- Multiplier for running speed

    self.isMoving = false ---@type boolean
    self.isRunning = false ---@type boolean
    self.fps = 8 ---@type number -- Frames per second

    self._anims = {
        idle = {
            love.graphics.newImage(getPath("StarWalker/StarWalker.png"))
        }
    }

    self.hasWalkingAnims = false
    self.visible = true

    print("StarWalker initialized with animations for directions: down, up, left, right")
end

return starWalker