---Module for abstracting the results of a lesson (or play session)



local QUALITIES = {wrong=0, told=1, repeated=2, perfect=3}



---(Result):add(c)
-- Add an element into the record.
-- @param c       String; character.
-- @param quality String; wrong, told, repeated, perfect (default 'perfect').
local add = function(self, c, quality)
    quality = quality or 'perfect'
    assert (type(c) == 'string')
    assert (type(quality) == 'string')
    assert (QUALITIES[quality])
    local n = #self.record.chars
    self.record.chars[n+1]     = c
    self.record.qualities[n+1] = quality
end

---(Result):getBreakdown()
-- Get breakdown counts of wrong, told, repeated, and perfect.
-- @return Numbers: #total, #wrong, #told, #repeated, #perfect.
local getBreakdown = function(self)
    local sum, t = 0, {wrong=0, told=0, repeated=0, perfect=0}
    for _,q in ipairs(self.record.qualities) do
        t[q] = t[q]+1
        sum = sum + 1
    end
    return sum, t.wrong, t.told, t.repeated, t.perfect
end

--TODO? getCount ('quality')
--TODO? getCorrect() :: shortcut for total-wrong
 
---(Result):getCount()
-- How many elements are in the record; faster than getBreakdown
-- @return Number 0..n
local getCount = function(self)
    return #self.record.qualities
end

---(Result):getScores()
-- Get the scores as broken down by character.
-- @return Table.
local getScores = function(self)
    local t = {}
    for i=1, #self.record.chars do
        local c, q = self.record.chars[i], self.record.qualities[i]
        t[c] = t[c] or {}
        t[c][#t[c] + 1] = QUALITIES[q]
    end
    return t
end

---(Result):getGrade()
-- Get the 'grade' of the result set.
-- @return String; cheat, learn, okay, good, perfect
--         nil iff result has no entries in record.
local getGrade = function(self)
    if #self.record.qualities == 0 then return nil end
    local score, honest = 0, false
    for _,q in ipairs(self.record.qualities) do
        score = score + QUALITIES[q]
        if not (q == 'told') then
            honest = true
        end
    end
    if not honest then return 'cheat' end
    local score = score / (#self.record.qualities * 3)
    
    if     score < 0.40 then return 'learn'
    elseif score < 0.70 then return 'okay'
    elseif score < 0.99 then return 'good'
    else                     return 'perfect'
    end
end



---Make a new Result table/object.
local function new()
    return {record = {chars={}, qualities={}},
            add          = add,
            getBreakdown = getBreakdown,
            getCount     = getCount,
            getGrade     = getGrade,
            getScores    = getScores,
           }
end

return {new = new}

