--Base module for button-like things.

---(Button):contains(x,y)
-- Is a point within the boundaries of the button?
-- @param x x-component of the point.
-- @param y y-component of the point.
-- @return Whether or not the provided point is 'within' the button;
--         edges are considered 'within'.
local function contains(self, x, y)
    return x >= self[1] and x <= self[1]+self[3] and
           y >= self[2] and y <= self[2]+self[4]
end

---(Button):getPosition()
-- @return x,y coordinates.
local getPosition = function(self)
    return self[1], self[2]
end

---(Button):getX()
-- @return x coordinate (a number).
local getX = function(self) return self[1] end

---(Button):getY()
-- @return y coordinate (a number).
local getY = function(self) return self[2] end

---(Button):setPosition(x, y)
-- Move the upper-left corner to a new position.
-- @param x Number; if nil, prior x value is unchanged.
-- @param y Number; if nil, prior y value is unchanged.
local function setPosition(self, x, y)
    x = x or self[1]
    y = y or self[2]
    assert (type(x)=='number', "x must be a number")
    assert (type(y)=='number', "y must be a number")
    self[1], self[2] = x, y
end

---(Button):setX(x)
-- @param x Number; new x-coordinate of upper-left corner.
local function setX(self, x)
    assert (type(x)=='number', "x must be a number")
    self[1] = x
end

---(Button):setY(y)
-- @param y Number; new y-coordinate of upper-left corner.
local function setY(self, y)
    assert (type(y)=='number', "y must be a number")
    self[2] = y
end

---(Button):getDimensions()
-- @return width,height of button area.
local function getDimensions(self)
    return self[3], self[4]
end

---(Button):getHeight()
-- @return Number; height of button area.
local function getHeight(self) return self[4] end

---(Button):getWidth()
-- @return Number; width of button area.
local function getWidth(self)  return self[3] end

---(Button):setDimensions(w, h)
-- @param w Number greater than zero; width of the button area;
--          can be nil, in which case the prior value is unchanged.
-- @param h Number greater than zero; height of the button area;
--          can be nil, in which case the prior value is unchanged.
local setDimensions = function(self, w, h)
    w = w or self[3]
    h = h or self[4]
    assert (w > 0, 'width must be greater than zero')
    assert (h > 0, 'height must be greater than zero')
    self[3], self[4] = w, h
end

---(Button):setHeight(h)
-- @param h Number greater than zero; height of the button area.
local setHeight = function(self, h)
    assert (h > 0, 'height must be greater than zero')
    self[4] = h
end

---(Button):setWidth(w)
-- @param w Number greater than zero; width of the button area.
local setWidth = function(self, w)
    assert (w > 0, 'width must be greater than zero')
    self[3] = w
end



---Make a button
-- @param x Number; upper-left coordinate; can be negative (default 0).
-- @param y Number; upper-left coordinate; can be negative (default 0).
-- @param w Number greater than zero; width (default 10).
-- @param h Number greater than zero; height (default 10).
-- @return Button instance.
local function new(x,y,w,h)
    x,y,w,h = (x or 0), (y or 0), (w or 10), (h or 10)
    assert (w > 0, 'width must be greater than zero')
    assert (h > 0, 'height must be greater than zero')
    return {x,y,w,h,
            contains      = contains,
            getDimensions = getDimensions,
            getPosition   = getPosition,
            getX          = getX,
            getY          = getY,
            getHeight     = getHeight,
            getWidth      = getWidth,
            setDimensions = setDimensions,
            setPosition   = setPosition,
            setX          = setX,
            setY          = setY,
            setHeight     = setHeight,
            setWidth      = setWidth,
           }
end

return {new = new}

