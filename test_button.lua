local Button = require 'button'
local LuaUnit = require 'luaunit.luaunit'



TestButton = {}
TestButton.test_behaviors = function(self)
    local b = Button.new()
    local x,y = b:getPosition()
    assertEquals(x, 0)
    assertEquals(y, 0)
    assertEquals(b:getX(), x)
    assertEquals(b:getY(), y)
    
    b:setX(-3)
    b:setY(4)
    x,y = b:getPosition()
    assertEquals(x, -3)
    assertEquals(y, 4)
    
    b:setPosition(5,-2)
    assertEquals(b:getX(), 5)
    assertEquals(b:getY(),-2)
    
    local w,h = b:getDimensions()
    assertEquals(w, 10)
    assertEquals(h, 10)
    assertEquals(b:getWidth(),  h)
    assertEquals(b:getHeight(), h)
    
    b:setWidth(3)
    b:setHeight(4)
    w,h = b:getDimensions()
    assertEquals(w, 3)
    assertEquals(h, 4)
    
    b:setDimensions(5,22)
    assertEquals(b:getWidth(),  5)
    assertEquals(b:getHeight(),22)
end
TestButton.test_defined = function(self)
    local b = Button.new(4,5,6,7)
    local x,y = b:getPosition()
    local w,h = b:getDimensions()
    assertEquals({x,y,w,h}, {4,5,6,7})
end
TestButton.test_nil_sets = function(self)
    local b = Button.new(3,4,5,6)
    b:setPosition(5)
    assertEquals(b:getX(), 5)
    assertEquals(b:getY(), 4)
    b:setPosition(nil, -3)
    assertEquals(b:getX(), 5)
    assertEquals(b:getY(), -3)
    b:setPosition()
    assertEquals(b:getX(), 5)
    assertEquals(b:getY(), -3)
    
    b:setDimensions(nil, 10)
    assertEquals(b:getWidth(), 5)
    assertEquals(b:getHeight(), 10)
    b:setDimensions(11)
    assertEquals(b:getWidth(), 11)
    assertEquals(b:getHeight(), 10)
    b:setDimensions()
    assertEquals(b:getWidth(), 11)
    assertEquals(b:getHeight(), 10)
end
TestButton.test_errors = function(self) --TODO: non-number sets?
    local new = Button.new
    assertError(new, 3,3,5,-1) -- negative dimension
    assertError(new, 3,3,0,5) -- zero dimension
    local b = new(3,3,5,5)
    assertError(b.setWidth, b, -4) -- negative dimension
    assertError(b.setHeight, b, 0) -- zero dimension
    assertError(b.setDimensions, b, 0,0) -- zero dimensions
end
TestButton.test_contains = function(self)
    local b = Button.new()
    assert(b:contains(0,0))
    assert(b:contains(10,10))
    assert(not b:contains(11,3))
    assert(not b:contains(1,-2))
    b:setX(-3)
    assert(b:contains(-2, 4))
    assert(not b:contains(9, 4))
    b = Button.new(8,-2, 4,2)
    assert(b:contains(12, -1))
    assert(not b:contains(12, 1))
    assert(b:contains(10, -1))
    assert(not b:contains(7, -1))
end



LuaUnit:run()

