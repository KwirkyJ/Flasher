--Modular-if-inflexible solution for the skills listing

-- sp = Skillpane.new(x,y,skillLevels) {5,3,5,2[,1...]}
-- hotLevel = sp:getMousedOverElem(mx, my)
-- sp:draw()

local lg = _G.love.graphics

local S = {}

local function makeQuads(skill_strengths)
    local sq = _G.quads.skills
    local t = {}
    for i=1,7 do
        local l = skill_strengths[i] or 1
        t[i] = sq[l][i] -- abuse of data encapsulation; oh, well
    end
    return t
end

local function makeCanvas(quads)
    local atlas = _G.atlases.skills
    local c = lg.newCanvas(200, 278)
    lg.setCanvas(c)
    lg.setColor(0xff, 0xff, 0xff)
    for i,q in ipairs(quads) do
        lg.draw(atlas, q, 0, (i-1)*40)
    end 
    lg.setCanvas()
    return c
end

local draw = function(self)
    lg.setColor(0xff, 0xff, 0xff)
    if self.canvas then
        lg.draw(self.canvas, self.x, self.y)
    else
        local atlas = _G.atlases.skills
        for i,q in ipairs(self.quads) do
            lg.draw(atlas, q, 0, (i-1)*40)
        end
    end
end

local getMousedOverElem = function(self, mx,my)
    mx = mx - self.x
    my = my - self.y
    if mx < 0 or mx > 200 or my < 0 or my > 278 then return nil end
    for i=1, #self.quads do
        if my <= i*40 then return i end
    end
    return nil
end

S.new = function(ulx, uly, skill_strengths)
    local quads = makeQuads(skill_strengths)
    
    local pane = {x = ulx, 
                  y = uly,
                  quads = quads}
    if lg.isSupported("canvas") then
        pane.canvas = makeCanvas(quads)
    end
    
    pane.draw = draw
    pane.getMousedOverElem = getMousedOverElem
    
    return pane
end

return S

