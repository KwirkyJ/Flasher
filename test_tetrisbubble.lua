local LuaUnit = require 'luaunit.luaunit'

local Bubble  = require 'tetrisbubble'



TestBubble = {}
TestBubble.test_construct_flawed = function(self)
    assertError(Bubble.new, nil,nil)
    assertError(Bubble.new, '5', {})
    assertError(Bubble.new,  {}, 80)
    local msgs = {'t', nil, 't'}
    local Tmss = {nil, 100, 150}
    for i=1, #msgs do
        local msg, Tms = msgs[i], Tmss[i]
        assertError(Bubble.new, msg,Tms,'blue') -- speed must be a number
        assertError(Bubble.new, msg,Tms,    {}) -- speed must be a number
        assertError(Bubble.new, msg,Tms,     1,'h') -- lifetime must be number
        assertError(Bubble.new, msg,Tms,     1, {}) -- lifetime must be number
        assertError(Bubble.new, msg,Tms,     1, -1) -- lifetime must be > 0
    end
    assertError(Bubble.new, 'word', -2) -- time unit must be > 0
end
TestBubble.test_construct_signal = function(self)
    -- Bubble.new(string, +number, ...)
    for _,v in ipairs({-5, 5, nil}) do
        for _,l in ipairs({5, nil}) do
            local b = Bubble.new('5', 150, v, l)
            assertNotNil(b)
            assertEquals(b:getType(), 'signal')
        end
    end
    assertError(Bubble.new, 't',-5) -- time unit must be positive
    assertError(Bubble.new, 't', 0) -- time unit must be greater than zero
end
TestBubble.test_construct_word = function(self)
    -- Bubble.new(string, nil, ...)
    for _,v in ipairs({-5, 5, nil}) do
        for _,l in ipairs({5, nil}) do
            local b = Bubble.new('t', nil, v, l)
            assertNotNil(b)
            assertEquals(b:getType(), 'word')
        end
    end
end
--TestBubble.test_construct_listener = function(self)
    -- Bubble.new(nil, +number, ...)
--end
TestBubble.test_getMessage = function(self)
    local c = 'c'
    local b = Bubble.new(c)
    assertEquals(b:getMessage(), c)
end
TestBubble.test_position = function(self)
    local x, y = 50, -50
    local b = Bubble.new('t')
    assertNumber(b:getPosition())
    b:setPosition(x,y)
    local bx, by = b:getPosition()
    assertEquals(bx,x)
    assertEquals(by,y)
end
TestBubble.test_update_drops = function(self)
    local b = Bubble.new('t') -- implicit positive dropspeed
    local x1, y1 = b:getPosition()
    b:update(1/60)
    assert(b:isAlive())
    local x2, y2 = b:getPosition()
    assertEquals(x1, y1)
    assert(y1 < y2)
end
TestBubble.test_update_lifespan = function(self)
    local b = Bubble.new('t', nil, 1, 2)
    b:update(1)
    assert(b:isAlive())
    assertAlmostEquals(b:getLifeProgress(), 0.5, 1e-7) 
    b:update(1)
    assert(not b:isAlive())
end
TestBubble.test_isOn_word = function(self) -- always on
    local b = Bubble.new('t') -- immortal, falling word
    assert(b:isOn())
    for i=1, 100 do
        local v = math.random() / 10
        b:update(v)
        assert(b:isOn())
    end
end
TestBubble.test_isOn_signal = function(self)
    local b = Bubble.new('r', 100) -- ".-." 
    assert(b:isOn()) -- starts on
    
    local ons = {true, false, true, true, true, false, true, 
                 false,false,false,false,false,false,false,false,false, 
           true, true, false, true, true, true, false, true, false, false}
    for i=1, #ons do
        --print('t = ' .. 0.09*i)
        b:update(0.09)
        assertEquals(b:isOn(), ons[i])
    end
end

--TODO: 'listener' bubbles



LuaUnit:run()

