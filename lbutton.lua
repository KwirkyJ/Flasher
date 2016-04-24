---LOVE-friendly wrapper module to interface with the Button module

local Button = require 'button'

local lg = love.graphics
local lm = love.mouse



---(LButton):isMouseOver(mx, my)
-- Interactivity check.
-- @param mx X-coordinate of the mouse (optional).
-- @param my Y-coordinate of the mouse (optional).
-- @return True iff base button 'contains' the coordinate.
local isMouseOver = function(self, mx, my)
    mx = mx or lm.getX()
    my = my or lm.getY()
    return self:contains(mx, my)
end

---(LButton):setQuad(q)
-- Change this button's Quad (and associated width/height).
-- @param q    New Quad.
local setQuad = function(self, q) -- TODO: sanity-checking?
    self[5] = q
end

---(LButton):draw(img)
-- Button draws itself with the given texture.
-- @param img Texture, usually an atlas of which the Quad is a region.
local draw = function(self, img)
    lg.draw(img, self[5], self:getPosition())
end

---LButton.new(x,y,q)
-- Make a Button instance.
-- @param x upper-left corner of the button (number, can be negative).
-- @param y upper-left corner of the button (number, can be negative).
-- @param q Quad table from LOVE; provides width/height and drawing info.
-- @return A Button.
local function new(x,y,q) --TODO? sanitize inputs
    local _,_,w,h = q:getViewport()
    local b = Button.new(x,y,w,h)
    b[5] = q
    b.draw        = draw
    b.isMouseOver = isMouseOver
    b.setQuad     = setQuad
    return b
end



return {new = new}

