---Logical bundle for a 'radio button' 
-- that can toggle between on and off.



local toggle = function(self)
    self.selected = not self.selected
end

local isSelected = function(self)
    return self.selected
end



local function new(self)
    return {selected = false,
            isSelected = isSelected,
            toggle     = toggle,
           }
end

return {new = new}

