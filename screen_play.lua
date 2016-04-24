local Button    = require 'lbutton'
local PausePane = require 'pausepane'
--local Result    = require 'result'
local Tetris    = require 'tetris'

local lg = love.graphics
local lm = love.mouse
local getTime = love.timer.getTime
local random = love.math.random

local GAME_WIDTH = 200
local GAME_HEIGHT = 280


---Get characters to use for the game
-- @param profile
-- @param levels array {true,false,...} with index associated with a skill lvl
-- @return array-table; WARNING: CAN BE EMPTY
local function getChars(profile, levels)
    assert (profile, "profile must exist")
    local t = {}
    local t_count = 0
    for l=1, #levels do
        if levels[l] then 
            local chars = profile:getCharsAtLevel(l)
            for i=1, #chars do
               t[#t + 1] = chars[i]
            end
        end
    end
    return t
end

---Abstracted routine to create a table of buttons
local function makeButtons()
    return {pause = Button.new(0,0, _G.quads.buttons.pause)}
end



local Play = {}

Play.enter = function(self)
    self.paused = false
    self.pausepane = self.pausepane or PausePane.new()
    self.buttons = self.buttons or makeButtons()
    
    self.profile = _G.profile
--    self.results = Result.new()
    
    local chars = getChars(self.profile, _G.tetrisOpts)
    self.game = Tetris.new(GAME_WIDTH,GAME_HEIGHT,
                           self.profile:getTimeUnit(), chars)
    
    _G.tetrisOpts = nil
end

Play.setUnpaused = function(self)
    self.paused = false
end

Play.setPaused = function(self)
    self.paused = true
end

Play.handlePausedClick = function(self, mx, my)
    local b = self.pausepane:getHot(mx,my)
    if b == 'quit' then
        --TODO? fetch results and add to profile
        _G.setMode('tetrisselect')
    elseif b == 'resume' then
        self:setUnpaused()
    end
end

Play.receiveClick = function(self, mx, my)
    if self.paused then 
        self:handlePausedClick(mx, my)
    elseif self.hot == 'pause' then
        --if self.hot == 'pause' then
            self:setPaused()
        --end
    end
end

Play.receiveKeypress = function(self, key)
    if self.paused then
        if key == 'escape' then
            self:setUnpaused()
        elseif key == 'return' then
            _G.setMode('tetrisselect')
        end
    else
        if key == 'escape' then
            self:setPaused()
--        elseif key == ' ' then
--            self.spacedown = true
--            self.spacewhen = getTime()
        else --TODO? handle dictionary-invalid key
             self.game:receiveKey(key)
        end
    end
end

Play.receiveKeyrelease = function(self, key)
--    if self.paused then return end
--    if key == ' ' then
--        self.spacedown = false
--        self.spacewhen = getTime() - self.spacewhen
--        -- self.game:receivePulse(duration)
--    end
end

Play.update = function(self, dt)
    if self.paused then
        return --TODO: tetris paused update()
    else
        self.hot = nil
        if self.buttons.pause:isMouseOver() then
            self.hot = 'pause'
        end
        self.game:update(dt)
    end
end

local function drawGameStatus(game)
    --TODO: prettify game stats
    local level, score, lives, maxlives = game:getStats()
    lg.setColor(0,0,0)
    lg.rectangle("fill", 400, 5, 100,100)
    lg.setColor(0xff, 0xff, 0xff)
    lg.print('score: ' .. score, 405, 8)
    lg.print('level: ' .. level, 405, 18)
    lg.print(string.format("lives: %d/%d", lives, maxlives),405, 28)
end

Play.draw = function(self)
    lg.setColor(0xff, 0xff, 0xff)
    if self.hot == 'pause' then
        self.buttons.pause:draw(_G.atlases.hot)
    else
        self.buttons.pause:draw(_G.atlases.buttons)
    end
    
    self.game:draw(150, 10)
    drawGameStatus(self.game)
    
    if self.paused then
        self.pausepane:draw()
    end
end



return Play

