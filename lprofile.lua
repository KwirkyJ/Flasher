---Wrapper module for the Profile interface; LOVE-friendly.
-- Provides save/loading ability through love.filesystem.

local Profile   = require 'profile'

local serialize = require 'libs.Ser.ser'



---Load saved data from a serialized table as a file.
-- @param filename string  Filename, must be found in requirepath to load;
--                         '.lua' extension is stripped internally.
-- @param dbg      boolean Iff true, prints any error while loading.
-- @return Table iff load is successful; else nil.
local function getSavedData(filename, dbg)
    if not filename or (type(filename) ~= 'string') then 
        return nil 
    end
    if string.sub(filename, #filename-3) == '.lua' then 
        filename = string.sub(filename, 1, #filename-4)
    end
    local data
    local _,err = pcall(function() data = require(filename) end)
    if err and dbg then print(err) end
    return data
end



---(Profile):save()
-- Write savedata to file
-- @error if internal 'savename' is nil
local save = function(self)
    assert (self.filename, "file is nil!")
    assert (type(self.filename) == 'string', 
            "file is not a string but a " .. type(self.filename))
    love.filesystem.write(self.filename, serialize(self.data))
end



---Profile.init(filename)
-- Initialize a profile with data in the save file (if any)
-- @param filename string; Filename directed to LOVE's saveDirectory;
--                 if nil (or error while loading), a default 'empty' profile
--                 is created.
-- @return New Profile instance.
local function init(filename)
    local p = Profile.init()
    local savedata = getSavedData(filename)
    p.filename = filename
    if savedata then
        p.data = savedata
    end
    p.save = save
    return p
end

return {init = init}

