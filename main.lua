-- Morse-learning game
-- (c) 2016 Jacob "KwirkyJ" Smith <fallback1681@gmail.com> all rights reserved

local AboutScreen        = require 'screen_about'
local MainScreen         = require 'screen_main'
local DictionaryScreen   = require 'screen_dictionary'
local SettingScreen      = require 'screen_settings'
local LessonSelectScreen = require 'screen_lessonselect'
local LessonScreen       = require 'screen_lesson'
local LessonResultScreen = require 'screen_lessonresult'
local TetrisSelectScreen = require 'screen_playsetup'
local TetrisScreen       = require 'screen_play'

local love = love or _G["love"]

local lg = love.graphics
local lk = love.keyboard
local lm = love.mouse
local lw = love.window
local lf = love.filesystem 

local Profile = require 'lprofile'
local SAVENAME = 'default_profile' --.lua extension added internally

local winmode -- = main, dictionary, settings, about, splash?
local windows = {}

local function prepareAtlases()
    return {buttons   = lg.newImage("assets/buttons.png"),
            hot       = lg.newImage("assets/buttons_hot.png"),
            chars     = lg.newImage("assets/characters.png"),
            hotchars  = lg.newImage("assets/characters_hot.png"),
            darkchars = lg.newImage("assets/characters_dark.png"),
            skills    = lg.newImage("assets/skills.png"),
            outcomes  = lg.newImage("assets/outcomes.png"),
           }
end


local function prepareButtonQuads()
    local dx, dy = _G.atlases.buttons:getDimensions()
    return {learn      = lg.newQuad(  0, 36, 242,50, dx,dy),
            play       = lg.newQuad(  0, 87, 242,50, dx,dy),
            dictionary = lg.newQuad(  0,138, 242,50, dx,dy),
            settings   = lg.newQuad(  0,189, 242,50, dx,dy),
            about      = lg.newQuad(101,  0, 100,35, dx,dy),
            quit       = lg.newQuad(  0,  0, 100,35, dx,dy),
            
            practice = lg.newQuad(243,149, 110,90, dx,dy),
            back     = lg.newQuad(243,113, 100,35, dx,dy),
            stop     = lg.newQuad(243, 77, 100,35, dx,dy),
            pause    = lg.newQuad(243, 41, 100,35, dx,dy),
            tell     = lg.newQuad(202,  0, 105,35, dx,dy),
            resume   = lg.newQuad(111,240, 100,35, dx,dy),
            signals  = lg.newQuad(  0,240, 110,35, dx,dy),
            letters  = lg.newQuad(121,240, 110,35, dx,dy),
            
            signal = lg.newQuad(78, 276, 200, 30, dx,dy), -- 'spacebar'
            
            arrow = lg.newQuad( 0,276, 38,38, dx,dy),
            redo  = lg.newQuad(39,276, 38,38, dx,dy),
            
            box_selected   = lg.newQuad(308,0, 20,20, dx,dy),
            box_unselected = lg.newQuad(329,0, 20,20, dx,dy),
           }
end

local function prepareCharQuads()
    local dx,dy = _G.atlases.chars:getDimensions()
    local cs = 'abcdefghijklmnopqrstuvwxyz0123456789'
    local t = {}
    for y=0, 5 do
        for x=0, 5 do
            local i = 1 + x + y*6
            local c = string.sub(cs, i, i)
--            assert (type(c) == 'string', "not a string at: "..x..', '..y)
--            print("adding charquad: "..c)
            t[c] = lg.newQuad(x*55,y*55, 54,54, dx,dy)
        end
    end
    return t
end

local function prepareSkillQuads()
    local dx,dy = _G.atlases.skills:getDimensions()
    local w, h = 200, 38 
    return    {{lg.newQuad(  0,273, w,h, dx,dy), -- black
                lg.newQuad(  0,312, w,h, dx,dy),
                lg.newQuad(  0,351, w,h, dx,dy),
                lg.newQuad(  0,390, w,h, dx,dy),
                lg.newQuad(  0,429, w,h, dx,dy),
                lg.newQuad(  0,468, w,h, dx,dy),
                lg.newQuad(  0,507, w,h, dx,dy)
               },
               {lg.newQuad(  0,  0, w,h, dx,dy), -- white
                lg.newQuad(  0, 39, w,h, dx,dy),
                lg.newQuad(  0, 78, w,h, dx,dy),
                lg.newQuad(  0,117, w,h, dx,dy),
                lg.newQuad(  0,156, w,h, dx,dy),
                lg.newQuad(  0,195, w,h, dx,dy),
                lg.newQuad(  0,234, w,h, dx,dy)
               },
               {lg.newQuad(201,273, w,h, dx,dy), -- red
                lg.newQuad(201,312, w,h, dx,dy),
                lg.newQuad(201,351, w,h, dx,dy),
                lg.newQuad(201,390, w,h, dx,dy),
                lg.newQuad(201,429, w,h, dx,dy),
                lg.newQuad(201,468, w,h, dx,dy),
                lg.newQuad(201,507, w,h, dx,dy)
               },
               {lg.newQuad(201,  0, w,h, dx,dy), -- yellow
                lg.newQuad(201, 39, w,h, dx,dy),
                lg.newQuad(201, 78, w,h, dx,dy),
                lg.newQuad(201,117, w,h, dx,dy),
                lg.newQuad(201,156, w,h, dx,dy),
                lg.newQuad(201,195, w,h, dx,dy),
                lg.newQuad(201,234, w,h, dx,dy)
               },
               {lg.newQuad(402,273, w,h, dx,dy), -- green
                lg.newQuad(402,312, w,h, dx,dy),
                lg.newQuad(402,351, w,h, dx,dy),
                lg.newQuad(402,390, w,h, dx,dy),
                lg.newQuad(402,429, w,h, dx,dy),
                lg.newQuad(402,468, w,h, dx,dy),
                lg.newQuad(402,507, w,h, dx,dy)
               },
              }
end

local function prepareOutcomeQuads()
    local w,h,dx,dy = 307,60, _G.atlases.outcomes:getDimensions()
    return {perfect = lg.newQuad(0,  0, w,h, dx,dy),
            good    = lg.newQuad(0, 61, w,h, dx,dy),
            okay    = lg.newQuad(0,122, w,h, dx,dy),
            learn   = lg.newQuad(0,183, w,h, dx,dy),
            cheat   = lg.newQuad(0,244, w,h, dx,dy)
           }
end

local function prepareQuads()
    return {buttons = prepareButtonQuads(),
            chars   = prepareCharQuads(),
            skills  = prepareSkillQuads(),
            outcomes = prepareOutcomeQuads(),
           }
end

-- global function to navigate between screens?
function setMode(m)
    winmode = m or 'main' -- upvalue 'local winmode'
    if winmode == 'main' then
        MainScreen:enter()
    else
        windows[winmode]:enter()
    end
end

function love.load()
    package.path = string.format('%s;%s.?.lua',
                                 package.path,
                                 lf.getSaveDirectory())
    _G.profile = Profile.init(SAVENAME..'.lua')
    
    _G.atlases = prepareAtlases()
    _G.quads   = prepareQuads()
    
    windows = {about         = AboutScreen,
               main          = MainScreen,
               dictionary    = DictionaryScreen,
               settings      = SettingScreen,
               lessons       = LessonSelectScreen,
               lesson        = LessonScreen,
               lessonresults = LessonResultScreen,
               tetrisselect  = TetrisSelectScreen,
               tetrisplay    = TetrisScreen,
              }
    setMode('main')
    love.math.setRandomSeed = love.timer.getTime()
    -- math.randomseed(os.time())
end

function love.quit()
    profile:save()
end

function love.update(dt)
    windows[winmode]:update(dt)
end

function love.keypressed(key)
    if winmode == 'main' then 
        love.event.push('quit') 
    else
        if windows[winmode].receiveKeypress then
            windows[winmode]:receiveKeypress(key)
        end
    end
end

function love.keyreleased(key)
    local win = windows[winmode]
    if win.receiveKeyrelease then
        win:receiveKeyrelease(key)
    end
end


function love.mousepressed(x, y, button)
    if button ~= 'l' then return end
    windows[winmode]:receiveClick(x,y)
end

--function love.mousereleased()
--end

function love.draw()
    lg.setBackgroundColor(0xdd, 0xdd, 0xdd)
    
    windows[winmode]:draw()
end

