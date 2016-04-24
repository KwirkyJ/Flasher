-- summary screen on a lesson's conclusion

local Button = require 'lbutton'

local lg = love.graphics

local S = {}

local function prepareButtons()
    return {quit  = Button.new(  0,265, _G.quads.buttons.quit),
            arrow = Button.new(462,262, _G.quads.buttons.arrow)}
end


S.enter = function(self)
    self.profile = _G.profile
    self.results = _G.lessonResults --TODO: if results are nil
    
    self.grade = self.results:getGrade()
    
    self.prevRanks = self.profile:getSkillRanks()
    self.profile:updateRecord(self.results:getScores())
    
    self.buttons = self.buttons or prepareButtons()
end

S.receiveKeypress = function(self, key)
    if key == 'return' then
        _G.setMode('lessons')
    elseif key == 'escape' then
        _G.setMode()
    end
end

S.receiveClick = function(self, mx, my)
    if self.hot == 'quit' then
        _G.setMode()
    elseif self.hot == 'arrow' then
        _G.setMode('lessons')
    end
end

S.update = function(self, dt)
    self.hot = nil
    local mx, my = love.mouse.getPosition()
    for k,b in pairs(self.buttons) do
        if b:isMouseOver(mx, my) then
            self.hot = k
        end
    end
end

local function drawGradeBanner(grade)
--    local q = _G.quads.outcomes[grade]
--    local img = _G.atlases.outcomes
    lg.draw(_G.atlases.outcomes, 
            _G.quads.outcomes[grade], 
            98,163)
end

local function drawUpRank(self, ups, x_offset)
    lg.setColor(0,0,0)
    lg.print("you have strengthened", x_offset + 15, 35)
--    local sq = _G.quads.skills
    lg.setColor(0xff, 0xff, 0xff)
    for i,level in ipairs(ups) do
        local rank = self.profile:getSkillRank(level)
--        local q = sq[rank][level]
        lg.draw(_G.atlases.skills, _G.quads.skills[rank][level], 
                x_offset, 50 + ((i-1) * 40))
    end
end

--[[
local function drawUpProgress(self, level, x_offset)
    lg.setColor(0,0,0)
    lg.print("you have unlocked:", x_offset + 37, 35)
    lg.setColor(0xff, 0xff, 0xff)
    lg.draw(_G.atlases.skills, _G.quads.skills[2][level], x_offset, 50)
end
--]]

local function drawCongratulations(self)
    local ranks = self.profile:getSkillRanks()
    local improvements = {}
    for i,r in ipairs(ranks) do
        if self.prevRanks[i] < r then
            table.insert(improvements, i)
        end
    end
   
    if #improvements > 0 then
        lg.setColor(0,0,0)
        lg.print('CONGRATULATIONS', 191, 20)
        drawUpRank(self, improvements, 150)
    end
end

S.draw = function(self)
    lg.setColor(0xff, 0xff, 0xff, 0xff)
    for k,b in pairs(self.buttons) do
        if k == self.hot then
            b:draw(_G.atlases.hot)
        else
            b:draw(_G.atlases.buttons)
        end
    end
    
    drawGradeBanner(self.grade)
    drawCongratulations(self) -- skill unlocks/up-level
    
    lg.setColor(0,0,0)    
    local total,wrong,told,repeated,perfect = self.results:getBreakdown()
    local correct = tostring(total - wrong)
    repeated, told, total = tostring(repeated), tostring(told), tostring(total)
    if repeated == '0' then repeated = "none" end
    if told == '0' then told = 'none' end
    lg.print("You answered "..correct.." of "..total.." questions correctly", 128,236)
    lg.print("You had "..repeated.." repeated", 128,248)
    lg.print("You had "..told.." answered for you", 128,260)
end

return S

