local Button    = require 'lbutton'
local Signal    = require 'signal'
local PausePane = require 'pausepane'
local Result    = require 'result'

local lg = love.graphics
local random = love.math.random

local correct_answer_target = 10
local WEAK_PRACTICE_COUNT   = 6

local S = {mode = 'none'}
--modes : none, report, choice, supply[, signal], paused

S.startSignal = function(self)
    self.signal = Signal.Signal(self.profile:getTimeUnit(), self.correctchar)
end

---Make a 'light' copy of a table (opposed to deep copy).
local function table_copy(t)
    local cpy = {}
    for k,v in pairs(t) do
        cpy[k] = v
    end
    return cpy
end

local function prepareChoices(correct, possibles)
    local possible_copy = table_copy(possibles)
    local chars = {}
    local added_correct = false
    local most = math.min(4, #possibles) -- (premature) catch for tiny lesson sets
    for _=1,most do
        local i = random(#possible_copy)
        local c = possible_copy[i]
        table.remove(possible_copy, i)
        table.insert(chars, c)
        if c == correct then added_correct = true end
    end
    if not added_correct then
        chars[random(#chars)] = correct
    end
    
    local choices = {}
    local cq = _G.quads.chars
    local uls = {{195, 170}, {251, 170}, {195, 226}, {251,226}}
    for i,c in ipairs(chars) do
        choices[c] = Button.new(uls[i][1], uls[i][2], cq[c])
    end
    return choices
end

S.nextQuestion = function(self)
    --if _G.lessonResults:getRight() == correct_answer_target then
    --if self.results:getCount() == correct_answer_target then
    local total, wrong = self.results:getBreakdown()
    if (total-wrong) == correct_answer_target then
        _G.lessonResults = self.results
        _G.setMode('lessonresults')
    end
    local chars = self.chars_to_learn
    local switch = random(4)
    self.correctchar = chars[random(#chars)]
    
    if switch < 2 then
        self.mode = 'supply'
        self.instruction = 'What is this?'
    else
        self.mode = 'choice'
        self.instruction = 'Choose one:'
        self.choices = prepareChoices(self.correctchar, chars)
    end
    
    self.buttons.tell = self.buttons.tell or self.tellbutton
    self.buttons.next = nil
    
    self.told = false
    self.correct = false
    self.repeated = false
    
    self:startSignal()
end

local function prepareButtons(self)
    local bq = _G.quads.buttons
    self.buttons = {tell  = Button.new(395,265, bq.tell),
                    redo  = Button.new(  5,155, bq.redo),
                    pause = Button.new(  0,  0, bq.pause)}
    self.nextbutton = Button.new(462,262, bq.arrow)
end

S.enter = function(self)
    self.profile = _G.profile
    
    self.pausepane = self.pausepane or PausePane.new()
    self.mode = 'none' 
    prepareButtons(self)
    
    local level = _G.lessonLevel 
    _G.lessonLevel = nil
    if level then
        self.chars_to_learn = self.profile:getCharsAtLevel(level)
    else
        local t = {}
        local weakordered = self.profile:getWeakChars(true)
        for i=1, WEAK_PRACTICE_COUNT do
            if not weakordered[i] then 
                break
            else
                t[i] = weakordered[i]
            end
        end
--        if #t < WEAK_PRACTICE_COUNT then
--            -- naive catch to add random letters if not enough
--            -- getWeakChars(true) should ensure this is redundant
--            local d = require 'dict'
--            local chars = {}
--            for c,_ in pairs(d) do
--                chars[#chars+1] = c
--            end
--            for i=#t+1, WEAK_PRACTICE_COUNT do
--                t[i] = chars[love.math.random(#chars)]
--            end
--        end
        self.chars_to_learn = t
    end
    
    self.results = Result.new()
    
    self:nextQuestion()
end

S.repeatSignal = function(self)
    self.repeated = true
    self:startSignal()
end

S.report = function(self, correct, told)
    self.mode = 'report'
    
    self.quality = 'wrong'
    if told then self.quality = 'told'
    elseif correct then
        self.quality = 'perfect'
        if self.repeated then self.quality = 'repeated' end
    end
    self.results:add(self.correctchar, self.quality)
    
    self.signal = nil
    self.tellbutton = self.buttons.tell
    self.buttons.tell = nil
    self.buttons.next = self.nextbutton
    self.choices = nil
end

S.setPaused = function(self)
    self.prevmode = self.mode
    self.mode = 'paused'
end

S.setUnpaused = function(self)
    self.mode = self.prevmode
end

S.receiveKeypress = function(self, key)
    self.last_key_pressed = key
    if self.mode == 'report' then
        self:nextQuestion()
        return
    end
    if key == 'escape' then
        if self.mode == 'paused' then
            self:setUnpaused()
        else
            self:setPaused()
        end
    elseif key == 'return' then
        if self.mode == 'paused' then
            if self.results:getCount() == 0 then
                _G.setMode('lessons')
            else
                _G.lessonResults = self.results
                _G.setMode('lessonresults')
            end
        end
    elseif key == 'tab' then 
        if self.mode == 'supply' or self.mode == 'choice' then
            self:repeatSignal()
        end
    elseif key == ' ' then
        --TODO: manual signaling stuff
        return
    else
        if self.mode == 'supply' or self.mode == 'choice' then
            local correct = false
            if key == self.correctchar then
                correct = true
            end
            self:report(correct)
        end
    end
end

S.handlePausedClick = function(self, mx, my)
    local b = self.pausepane:getHot(mx,my)
    if b == 'quit' then
        if self.results:getCount() == 0 then
            _G.setMode('lessons')
        else
            _G.lessonResults = self.results
            _G.setMode('lessonresults')
        end
    elseif b == 'resume' then
        self:setUnpaused()
    end
end

S.receiveClick = function(self, mx, my)
    if self.mode == 'paused' then 
        self:handlePausedClick(mx, my) 
        return
    elseif self.mode == 'report' then
        self:nextQuestion()
        return
    end
    if self.hot == 'tell' then
        if self.mode == 'choice' or self.mode == 'supply' then
            self:report(true, true)
        end
    elseif self.hot == 'pause' then
        self:setPaused()
    elseif self.hot == 'redo' then
        self:repeatSignal()
    elseif self.hot and self.choices then
        if self.choices[self.hot] and self.hot == self.correctchar then
            self:report(true)
        else
            self:report(false)
        end
    end
end

S.update = function(self, dt)
    self.hot = nil
    if self.mode == 'paused' then
        return --TODO? forward any time offset for signaling
    elseif self.mode == 'report' then
        if self.buttons.next:isMouseOver(love.mouse.getPosition()) then
            self.hot = 'next'
        end
    else
        local mx, my = love.mouse.getPosition()
        for k,b in pairs(self.buttons) do
            if b:isMouseOver(mx, my) then
                self.hot = k
                break
            end
        end
        if self.choices and not self.hot then
            for k,b in pairs(self.choices) do
                if b:isMouseOver(mx, my) then
                    self.hot = k
                    break
                end
            end
        end
        if self.signal then
            if self.signal:isDone() then
                self.signal = nil
            else
                self.signal:update(dt)
            end
        end
    end
end

S.showReport = function(self)
    lg.setColor(0,0,0)
    local correctstr = "CORRECT!"
    if self.quality == 'cheated' then
        correctstr = string.format(
            "THE CORRECT ANSWER IS: %s",
            string.upper(self.correctchar))
    elseif self.quality == 'wrong' then
        correctstr = string.format(
            "NO, THE CORRECT ANSWER WAS: %s",
            string.upper(self.correctchar))
    end
    lg.print(correctstr, 200, 190)
    if self.quality == 'repeated' then
        lg.print("YOU HAD A HINT", 200, 210)
    end
    lg.print('press any key to continue...', 200, 230)
end

S.draw = function(self)
    lg.setColor(0,0,0)
    lg.rectangle("fill", 0,0, 500, 150)
    
    lg.setColor(0xff, 0xff, 0xff)
    local buttonAtlas = _G.atlases.buttons
    for k,b in pairs(self.buttons) do
        if k == self.hot then
            b:draw(_G.atlases.hot)
        else
            b:draw(buttonAtlas)
        end
    end
    
    if self.signal and self.signal:isOn() then
        lg.setColor(0xff, 0xff, 0xff)
        lg.circle("fill", 250, 75, 44)
    end
    
    --progress bar
    lg.setColor(0xff, 0xff, 0xff)
    lg.rectangle('fill', 324, 155, 154, 19)
    lg.setColor(0, 0xff, 0)
    local total, wrong = self.results:getBreakdown()
--    local rights = _G.lessonResults:getRight()
    local rights = total - wrong
    local w = math.floor(150 * rights / correct_answer_target)
    lg.rectangle('fill', 326, 157, w, 15)
    
    if self.mode == 'supply' or self.mode == 'choice' then
        lg.setColor(0,0,0)
        lg.print(self.instruction, 53, 155)
    end
    if self.mode == 'choice' then
        lg.setColor(0xff, 0xff, 0xff)
        local charatlas = _G.atlases.chars
        for k,b in pairs(self.choices) do
            if self.hot == k then
                b:draw(_G.atlases.hotchars)
            else
                b:draw(charatlas)
            end
        end
    elseif self.mode == 'report' then
        self:showReport()
    elseif self.mode == 'paused' then 
        self.pausepane:draw()
    end
    
    -- DEBUG
    --lg.setColor(0,0,0)
    --lg.print(self.correctchar or '', 10, 190)
    --lg.print(self.last_key_pressed or '', 10, 200)
    --local h = self.hot or ''
    --lg.print("hot: " .. h, 10, 210)
end

return S

