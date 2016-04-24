-- LOVE-friendly wrapper for the tetrisbubble class
local Bubble = require 'tetrisbubble'

local lg = love.graphics
-- local floor = math.floor


local function drawWord(self)
    return
end

local function drawSignal(self)
    return
end

local draw = function(self)
    if self:getType() == 'word' then
        drawWord(self)
    elseif self:getType() == 'signal' then
        drawSignal(self)
    end
end

local function new(...)
    local b = Bubble.new(...)
    b.draw = draw
    return b
end

return {new = new}

