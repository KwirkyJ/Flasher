---LOVE-friendly module for a 'radio button'

local LButton = require 'lbutton'
local Radio   = require 'radioswitch'



---(LRButton):isSelected()
-- @return true or false.
local isSelected = function(self)
    return self._radio:isSelected()
end

---(LRButton):toggle()
-- Toggles between (un)selected state.
local toggle = function(self)
    self._radio:toggle()
    if self._radio:isSelected() then
        self:setQuad(self._q2)
    else
        self:setQuad(self._q1)
    end
end



---LRadioButton.new(x,y,q1,q2)
-- Make a new RadioButton; just like an LButton, but has built-in
-- select/deselect logic and accessor.
-- @param x Upper-left coordinate.
-- @param y Upper-left coordinate.
-- @param q1 Quad object for when unselected.
-- @param q1 Quad object for when selected.
-- @return new Radio Button.
local function new(x,y,q1,q2)
    local b = LButton.new(x,y,q1)
    b._radio = Radio.new()
    b._q1, b._q2 = q1, q2
    b.isSelected = isSelected
    b.toggle     = toggle
    return b
end

return {new = new}

