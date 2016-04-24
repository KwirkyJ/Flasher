local Profile = require 'lprofile'
local LuaUnit = require 'luaunit.luaunit'

-- =====================

---Util to pretty-print a table
local function _tblstr(t, d)
    d = d or 0
    local gap = ''
    for i=1, d do gap = gap .. '  ' end
    
    local s = gap .. '{'
    local first = true
    for k,v in pairs(t) do
        if type(v) == 'table' then
            v = '\n' .. _tblstr(v, d+1)
        else 
            v = tostring(v)
        end
        
        if first then -- no extra space after '{'
            s = string.format('%s%s : %s,\n', s, k, v)
            first = false
        else
            s = string.format('%s %s%s : %s,\n', s, gap, k, v)
        end
    end
    return s .. gap .. '}'
end

---Wrapper/util to pretty-print a table
local function printTable(t)
    print('')
    print("PRINTING TABLE")
    print(_tblstr(t, 0))
end

-- =====================

---mock-up of Love to satisfy the tested module
_G.love = {filesystem = {}}
---Gets the full path to the designated save directory.
_G.love.filesystem.getSaveDirectory = function()
    return './libs'
end
---Write data to a file in the save directory. 
-- If the file existed already, 
-- it will be completely replaced by the new contents. 
-- @param name string The name (and path) of the file.
-- @param data string The string data to write to the file.
-- @param size number How many bytes to write. (default (all))
-- @return success boolean True iff the operation was successful.
_G.love.filesystem.write = function(name, data, ...)
    if not name then return false end
    local path = _G.love.filesystem.getSaveDirectory()
    local file = io.open(path..'/'..name, 'w')
    if not file then 
        print("ERROR OPENING FILE: "..name)
        return false 
    end
    file:write(data)
    file:flush()
    file:close()
    return true
end
local lfs_w   = _G.love.filesystem.write
local lfs_gsd = _G.love.filesystem.getSaveDirectory

-- =====================

--TODO? '/' may break test on windows machines?
TestLFSMock = {}
TestLFSMock.setUp = function(self)
    self.pp = package.path
    package.path = string.format('%s;%s/?.lua', self.pp, lfs_gsd())
end
TestLFSMock.tearDown = function(self)
    package.path = self.pp
end
TestLFSMock.test_framework = function(self)
    local wrote = lfs_w("framework.lua", 'return {yes = true}')
    assert (wrote)
    
    local t = require('framework')
    assertNotNil(t)
    assertTrue(t.yes)
    assertEquals('./libs', lfs_gsd())
    
    os.remove(lfs_gsd() .. '/' .. 'framework.lua')
end
TestLFSMock.test_profile_load = function(self)
    lfs_w("load.lua", 
          'return {time_unit_ms=80,record={a={3,100,"20160103"},},}')
    local p = Profile.init("load.lua")
    --printTable(p.data)
    
    assertEquals(p:getTimeUnit(), 80)
    assertNumber(p:getCharStrength('a'))
    
    os.remove(lfs_gsd() .. '/' .. 'load.lua')
end
TestLFSMock.test_profile_save = function(self)
    local p = Profile.init('save.lua')
    -- printTable(p.data)
    assertEquals(p:getTimeUnit(), 150)
    assert (p:getTimeUnit() == 150, 'sanity check: default 150ms')
    p:setTimeUnit(90)
    p:updateRecord({a={2}})
    p:setTimeUnit(85)
    p:save()
    
    local t = require ('save')
    assertEquals(#t.record.a, 3)
    assertEquals(t.time_unit_ms, 85)
    local now = os.date('*t')
    local now = string.format("%04.f%02.f%02.f", now.year, now.month, now.day)
    assertEquals(t.record.a, {2,90,now})
    
    os.remove(lfs_gsd() .. '/' .. 'save.lua')
end
TestLFSMock.test_ops = function(self)
    local p = Profile.init("tmp.lua")
    p:setTimeUnit(90)
    p:updateRecord({a={2}})
    p:setTimeUnit(85)
    p:save()
    p = nil
    
    p = Profile.init("tmp.lua")
    assertEquals(p:getTimeUnit(), 85)
    assertNumber(p:getCharStrength('a'))
    
    os.remove(lfs_gsd() .. '/' .. 'tmp.lua')
end



LuaUnit:run()

