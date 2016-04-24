---Module

local MAX_HISTORY = 50
--local lesson_advance_threshold = 0.8
local MIN_ANSWER_COUNT = 10
local MEMORY_FLOOR_TIME = 40 -- days
local MEMORY_FLOOR_FACTOR = 0.1

local SKILLGROUPS = {{'e', 'a', 't', 'o', 'r', 's'},
                     {'h', 'i', 'l', 'n'},
                     {'d', 'u', 'c', 'm'},
                     {'p', 'g', 'y', 'w'},
                     {'f', 'b', 'k', 'v'},
                     {'x', 'j', 'q', 'z'},
                     {'0', '1', '2', '3', '4', 
                      '5', '6', '7', '8', '9'}
                    }
-- SANITY CHECK
local dict = require 'dict'
for _,group in ipairs(SKILLGROUPS) do
    for _,char in ipairs(group) do
        local found = false
        for k,_ in pairs(dict) do
            if k == char then
                found = true 
                break
            end
        end
        if not found then
            error("character not matched in dictionary: " .. char)
        end
    end
end

-- =====================

---Get formatted string of 'now'
-- @return 'yyyymmdd'
local function getDate()
    local d = os.date("*t")
    return string.format("%04.0f%02.0f%02.0f", d.year, d.month, d.day)
end

local DAYSUM = { 0, 31, 59, 90,120,151,181,212,243,273,304,334}
---Compute how many days have elapsed since '0ad'
-- @return number
local function computeDays(s)
    local y = tonumber(string.sub(s, 1,4))
    local m = tonumber(string.sub(s, 5,6))
    local d = tonumber(string.sub(s, 7,8)) or 0
    local days = math.max(math.floor(365.25 * (y-1)), 0)
    days = days + (DAYSUM[m] or 0)
    if y % 4 == 0 and m > 2 then days = days + 1 end -- leap year
    return days + d
end

---How many days have elapsed between these two dates
-- @param d1 date string
-- @param d2 date string
-- @return 0 if same, else positve integer
local function getDeltaDays(d1, d2)
    if d1 == d2 then return 0 end
    d1, d2 = computeDays(d1), computeDays(d2)
    return math.max(d1, d2) - math.min(d1, d2)
end

-- =====================

---For when getSavedData(file) fails.
-- @return Table with default timeUnit and empty history.
local function getDefaultData()
    return {time_unit_ms = 150,
            record       = {},
           }
end

-- =====================

---(Profile):_setRecord(r)
-- Utility routine to manually set the internal database
-- FOR TESTING PURPOSES ONLY
local _setRecord = function(self, r)
    assert (r)
    assert (type(r) == 'table')
    self.data.record = r
end

---(Profile):updateRecord(results)
-- @param results Formatted table
local updateRecord = function(self, results)
    local d  = getDate()
    local ms = self.data.time_unit_ms
    local maxplus = 3 * MAX_HISTORY + 1
    for c, t in pairs(results) do
        local hist = self.data.record[c] or {}
        for _,score in ipairs(t) do
            table.insert(hist, 1, d)
            table.insert(hist, 1, ms)
            table.insert(hist, 1, score)
            while hist[maxplus] do
                table.remove(hist, maxplus)
            end
        end
        self.data.record[c] = hist
    end
end

---(Profile):getTimeUnit()
-- @return Time unit in milliseconds
local getTimeUnit = function(self)
    return self.data.time_unit_ms
end

---(Profile):setTimeUnit(ms)
-- @param ms Time unit in milliseconds
-- @error iff 'ms' is not a number or <= 0
local setTimeUnit = function(self, ms)
    assert (type(ms) == 'number', "unit must be a number")
    assert (ms > 0, "unit must be >= 0")
    self.data.time_unit_ms = ms
end

---(Profile):getCharStrength(c[, datestr])
-- @param c       character
-- @param datestr Formatted date string of 'now'; FOR TESTING ONLY
-- @return number >= 0
local getCharStrength = function(self, c, datestr)
    local history = self.data.record[c]
    if not history then
        return 0
    end
    local sum, K = 0, (1-MEMORY_FLOOR_FACTOR)/MEMORY_FLOOR_TIME
    local now = datestr or getDate()
    assert (#history % 3 == 0)
    local count = math.floor(#history / 3)
    for n=1, count do
        local i = (n-1)*3 + 1
        local score, ms, d = history[i], history[i+1], history[i+2]
        score = score * (self.data.time_unit_ms / ms)
        local dt = getDeltaDays(now, d)
        score = score * (math.max(1-(dt*K), MEMORY_FLOOR_FACTOR))
        score = score + n/count
        sum = sum + score
    end
    return sum / math.max(MIN_ANSWER_COUNT, count)
end

---(Profile):getCharsAtLevel(level)
-- @param level number; index; error if not in range 1..#SKILLGROUPS 
-- @return table-array of characters
local getCharsAtLevel = function(self, l) -- 'self' unused
    assert (l > 0 and l <= #SKILLGROUPS, "level index "..l.." out of range")
    return SKILLGROUPS[l]
end

---(Profile):getWeakChars(include)
-- @param include If true, include characters with no or empty record.
-- @return Table-array of characters, ordered 'weakest' first;
--         order of equal-strength elements is undefined.
local getWeakChars = function(self, include)
    local chars = {}
    local strengths = {}
    --TODO? point character listing to dictionary
    for _,c in ipairs({'a','b','c','d','e','f','g','h','i','j','k','l','m',
                       'n','o','p','q','r','s','t','u','v','w','x','y','z',
                       '0','1','2','3','4','5','6','7','8','9'}) do
        local strength = self:getCharStrength(c)
        if strength > 0 or (strength == 0 and include) then
            if #chars < 1 or strength <= strengths[1] then
                table.insert(chars, 1, c)
                table.insert(strengths, 1, strength)
            else
                local added = false
                for i=1, #strengths do
                    if strengths[i] > strength then
                        table.insert(chars, i, c)
                        table.insert(strengths, i, strength)
                        added = true
                        break
                    end
                end
                if not added then
                    chars[#chars + 1] = c
                    strengths[#strengths + 1] = strength
                end
            end
        end
    end
    return chars
end

---(Profile):getSkillRank(level)
-- Semi-internal routine, get the rank/grade of a specific level/skill.
-- @param level Number 1..#skills; assumes level is within bounds.
-- @return number (integer)
local getSkillRank = function(self, level)
    local strength = 0
    for _,c in ipairs(SKILLGROUPS[level]) do
        local s = self:getCharStrength(c)
        strength = strength + s
    end
    local avg_strength = strength / #SKILLGROUPS[level]
    if avg_strength < 0.01 then return 1
    elseif avg_strength < 1.0 then return 2
    elseif avg_strength < 2.0 then return 3
    elseif avg_strength < 3.0 then return 4
    else return 5
    end
end

---(Profile):getSkillRanks()
-- @return table; &c., &c.
-- 5-> green; 4-> yellow; 3-> red; 2-> white; 1-> black
local getSkillRanks = function(self)
    local t = {}
    for i=1, #SKILLGROUPS do
        t[i] = getSkillRank(self, i)
    end
    return t
end

---(Profile):reset()  
-- Nuke the savedata and start over.
local reset = function(self)
    self.data = getDefaultData()
end



--TODO? pass a database in this constructor
---Profile.init()
-- Initialize a profile with default data.
-- @return New Profile instance
local init = function()
    return {data = getDefaultData(),
            _setRecord      = _setRecord,
            getTimeUnit     = getTimeUnit,
            setTimeUnit     = setTimeUnit,
            updateRecord    = updateRecord,
            getCharsAtLevel = getCharsAtLevel,
            getCharStrength = getCharStrength,
            getWeakChars    = getWeakChars,
            getSkillRank    = getSkillRank,
            getSkillRanks   = getSkillRanks,
            reset           = reset,
           }
end



return {init = init,
        -- below included for testing and verification
        computeDays  = computeDays,
        getDeltaDays = getDeltaDays,
       }

