local Result = require 'result'
local LuaUnit = require 'luaunit.luaunit'

--local fail = _G.assertFail -- from LuaUnit



TestResult = {}
TestResult.test_empty = function(self)
    local r = Result.new()
    assertEquals(r:getScores(), {})
    assertEquals({r:getBreakdown()}, {0,0,0,0,0})
    assertNil(r:getGrade())
    assertEquals(r:getCount(), 0)
end
TestResult.test_operations = function(self)
    local r = Result.new()
    r:add('s') -- default of 'perfect'
    r:add('s', 'wrong')
    r:add('t', 'told')
    r:add('a', 'repeated')
    r:add('7', 'perfect')
    assertEquals(r:getScores(), {s={3,0}, t={1}, a={2}, ['7']={3}})
    assertEquals({r:getBreakdown()}, {5,1,1,1,2})
    assertString(r:getGrade())
    assertEquals(r:getCount(), 5)
end
TestResult.test_errors = function(self)
    local r = Result.new()
    assertError(r.add, r, 's',         2) -- TODO: numeric quality made valid?
    assertError(r.add, r, 's',        {}) -- table quality
    assertError(r.add, r, 's',   'WroNg') -- unrecognized
    assertError(r.add, r, 's', 'prefect') -- typo unrecognized
    
    assertError(r.add, r,  3) -- char must be string
    assertError(r.add, r, {}) -- char must be string
    --TODO? more error conditions
end
TestResult.test_getGrade_upper = function(self)
    r = Result.new()
    r:add('s', 'perfect')
    assertEquals(r:getGrade(), 'perfect') -- 3/3
    r:add('s', 'perfect')
    r:add('s', 'repeated')
    assertEquals(r:getGrade(), 'good') -- score:8/9
end
TestResult.test_getGrade_lower = function(self)
    r= Result.new()
    r:add('t', 'wrong')
    assertEquals(r:getGrade(), 'learn') --0/3
    r:add('t', 'told')
    assertEquals(r:getGrade(), 'learn') --1/6
    r:add('t', 'perfect')
    assertEquals(r:getGrade(), 'okay') --4/9
end
TestResult.test_getGrade_cheat = function(self)
    r = Result.new()
    r:add('t', 'told')
    assertEquals(r:getGrade(), 'cheat') --1/3
    r:add('t', 'told')
    assertEquals(r:getGrade(), 'cheat') --2/6
    
    r = Result.new()
    r:add('t', 'wrong')
    r:add('t', 'repeated')
    assertEquals(r:getGrade(), 'learn') --2/6
end



LuaUnit:run()

