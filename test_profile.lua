local Profile = require 'profile'
local LuaUnit = require 'luaunit.luaunit'

local fail = _G.assertFail



TestClass = {}
TestClass.setUp = function(self)
    self.results = {}
    for _,c in ipairs({'e', 'a', 't', 'o', 'r', 's'}) do
        local t = {}
        for i=1,111 do
            t[i] = 2 -- everything mediocre; unrealistic but simple
        end
        self.results[c] = t
    end
    return
end
TestClass.test_initialization = function(self)
    local p = Profile.init()
    assertNotNil(p)
    assertEquals(p:getTimeUnit(), 150) -- default value
    assertNumber(p:getSkillRank(3))
    assertEquals(p:getSkillRanks(), {1,1,1,1,1,1,1})
    assertEquals(p:getSkillRank(3), 1)
    assertError(p.getSkillRank, p, 0) -- too low
    assertError(p.getSkillRank, p, 10) -- too high
    assertEquals(p:getCharStrength('r'), 0)
end
TestClass.test_reset = function(self)
    local p = Profile:init()
    p:updateRecord(self.results)
    p:setTimeUnit(100)
    assert(p:getCharStrength('r') > 0, 'verify')
    p:reset()
    assertEquals(p:getTimeUnit(), 150)
    assertEquals(p:getCharStrength('r'), 0)
    assertEquals(p:getSkillRanks(), {1,1,1,1,1,1,1})
end
TestClass.test_getCharsAtLevel = function(self)
    p = Profile.init()
    assertEquals(p:getCharsAtLevel(1), {'e','a','t','o','r','s'})
    assertError(p.getCharsAtLevel, p, 0)
    assertError(p.getCharsAtLevel, p, 9)
end



TestWeak = {}
TestWeak.test_empty = function(self)
    local p = Profile.init()
    assertEquals(p:getWeakChars(), {})
end
TestWeak.test_empty_include = function(self)
    local p = Profile.init()
    local cs = p:getWeakChars(true)
    assertTable(cs)
    assertEquals(#cs, 36)
    for _,c in ipairs(cs) do
        assertString(c)
    end
end
TestWeak.test_with_record = function(self)
    local p = Profile.init()
    p:updateRecord({a = {3,3,2,3,1,1},
                    b = {1,1,1,1}})
    assert (p:getCharStrength('b') < p:getCharStrength('a'), '|b| < |a|')
    local weaks = p:getWeakChars()
    assertEquals(#weaks, 2)
    assertEquals(weaks, {'b', 'a'})
    weaks = p:getWeakChars(true)
    assertEquals(#weaks, 36)
    assertEquals(weaks[35], 'b')
    assertEquals(weaks[36], 'a')
end



TestDates = {}
TestDates.test_0 = function(self)
    assertEquals(Profile.computeDays('00000000'), 0)
end
TestDates.test_1 = function(self)
    assertEquals(Profile.computeDays('20000101'), 730135)
end
TestDates.test_delta_0 = function(self)
    assertEquals(Profile.getDeltaDays('20151221', '20151221'), 0)
end
TestDates.test_delta_1 = function(self)
    assertEquals(Profile.getDeltaDays('20151221', '20161221'), 366)
end
TestDates.test_delta_3 = function(self)
    assertEquals(Profile.getDeltaDays('20141221', '20151221'), 365)
end



TestStrength = {}
TestStrength.setUp = function(self)
    self.p = Profile.init()
end
TestStrength.test_empty = function(self)
    assertEquals(self.p:getCharStrength('a'), 0)
end
TestStrength.test_batch_of_wrongs = function(self)
    self.p:_setRecord({a={0,150,'20160227'}})
    assertAlmostEquals(self.p:getCharStrength('a', '20160227'), 0.1, 1e-12)
    -- wrongs aren't changed with time?
    assertAlmostEquals(self.p:getCharStrength('a', '20170227'), 0.1, 1e-12)
    local a = {0,150,'20160227', 0,150,'20160227', 
               0,150,'20160227', 0,150,'20160227'}
    self.p:_setRecord({a=a})
    assertAlmostEquals(self.p:getCharStrength('a', '20160227'), 0.25, 1e-12)
end
TestStrength.test_homogenous_same_same = function(self)
-- same speed, same date
    local sc, ms, d = 2, 150, '20160227'
    self.p:updateRecord({a={2,2,2,2}})
    local str1 = self.p:getCharStrength('a')
    self.p:updateRecord({a={2}})
    local str2 = self.p:getCharStrength('a')
    assert(str2 > str1)
    assertAlmostEquals(str2, 1.3, 1e-12)
end
TestStrength.test_homogenous_same_later_1 = function(self)
    -- same speed, later date
    local d1 = '20160227'
    local d2 = '20160327'
    assert (Profile.getDeltaDays(d2, d1) == 29)
    local r = {a = {2,150,d1, 2,150,d1, 
                    2,150,d1, 2,150,d1}}
    self.p:_setRecord(r)
    local s1 = self.p:getCharStrength('a', d1)
    local s2 = self.p:getCharStrength('a', d2) -- longer ago, lower strength
    assert(s1 > s2)
--    assertAlmostEquals(self.p:getCharStrength('a', d2), 4, 1e-12)
end



TestRanking = {}
TestRanking.setUp = function(self)
    local groups = {{'e', 'a', 't', 'o', 'r', 's'},
                    {'h', 'i', 'l', 'n'},
                    {'d', 'u', 'c', 'm'},
                    {'p', 'g', 'y', 'w'},
                    {'f', 'b', 'k', 'v'},
                    {'x', 'j', 'q', 'z'},
                    {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}}
    local results = {}
    for _,c in ipairs(groups[1]) do
        local t = {}
        for i=1, 88 do
            table.insert(t, 3)
        end
        results[c] = t
    end
    for _,c in ipairs(groups[2]) do
        local t = {}
        for i=1, 50 do
            table.insert(t, 2)
        end
        for i=1, 25 do
            table.insert(t, 3)
        end
        results[c] = t
    end
    for _,c in ipairs(groups[3]) do
        local t = {}
        for i=1, 100 do
            table.insert(t, 1)
        end
        results[c] = t
    end
    for _,c in ipairs(groups[4]) do
        local t = {}
        for i=1, 20 do
            table.insert(t, 2)
        end
        for i=1, 20 do
            table.insert(t, 0)
        end
        results[c] = t
    end
    results['f'] = {3,3,3,3,3,3,}
    self.results = results
end
TestRanking.test_ranking = function(self)
    local p = Profile.init()
    assert (p:getTimeUnit() == 150)
    
    p:updateRecord(self.results)
    
    local t = p:getSkillRanks()
    assertEquals(t, {5,5,3,3,2,1,1})
    for i,v in ipairs(t) do
        assertEquals(p:getSkillRank(i), v)
    end
end



LuaUnit:run()

