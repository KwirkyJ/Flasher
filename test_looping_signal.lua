local LuaUnit = require 'luaunit.luaunit'
local Looper = require 'looping_signal'



TestLooper = {}
TestLooper.test_looper = function(self)
    local l = Looper.new(100, 'h')
    assertNotNil(l)
    assertEquals(l:getMessage(), 'h')
    assertEquals(l:getMorse(), '....')
    assert(not l:isOn())
    
    l:setDelay(500)
    l:start()
    local ons = {true, false, true, false, true, false, true, false, 
                 false, false, false, false, false, false, true, true, false}
    local dt = 0.09
    for i=1, #ons do
        --print('t = ' .. i * dt)
        l:update(dt)
        assertEquals(l:isOn(), ons[i])
    end
end
TestLooper.test_setDelay = function(self)
    local l = Looper.new(150, 'thoroughbred')
    l:setDelay() -- valid; defaults to the provided time unit (150)
    l:setDelay(750) -- nominal case: number literal
    l:setDelay(0) -- imprudent but acceptable
    for _,v in pairs({-1, '5', {}, function() end}) do
        assertError(l.setDelay, l, v)
    end
end
TestLooper.test_constructor = function(self)
    assertError(Looper.new, nil, nil) -- must have values
    assertError(Looper.new, nil, 'q') -- ms cannot be nil
    assertError(Looper.new, 'q', 'q') -- ms must be number
    assertError(Looper.new,  {}, 'q') -- ms must be number
    assertError(Looper.new,  -1, 'q') -- ms must be greater than 0
    assertError(Looper.new,   0, 'q') -- ms must be greater than 0
    assertError(Looper.new, 100, nil) -- msg cannot be nil
    assertError(Looper.new, 100, 789) -- msg must be string
    assertError(Looper.new, 100,  {}) -- msg must be string
    -- out of scope: invalid characters in message
end
TestLooper.test_autostart = function(self)
    local l = Looper.new(100, 'n') -- autodelay of 100ms
    assert(not l:isOn())
    local ons = {false, true, true, true, true, true, true, true, false, false, true, true, false}
    local dt = 0.05
    for i=1, #ons do
        --print ('t = ' .. i*dt)
        l:update(dt)
        assertEquals(l:isOn(), ons[i])
    end
end
TestLooper.test_looping_e = function(self)
    -- irregular intervalse (2:3) side-effect of discrete dt intervals
    local l = Looper.new(100, 'e')
    l:start()
    assert(l:isOn())
    local ons = {true, false, false, false, true, true, false, false, false,
                 true, true, false, false, false, true, true, false}
    local dt = 0.07
    for i=1, #ons do
        --print ('t = ' .. i*dt)
        l:update(dt)
        assertEquals(l:isOn(), ons[i])
    end
end



LuaUnit:run()

