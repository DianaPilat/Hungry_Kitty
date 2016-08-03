display.setStatusBar(display.HiddenStatusBar)

local physics = require("physics")
physics.start()

local w = display.contentWidth
local h = display.contentHeight

--Declaration of variables
local titleBg, playBtn, creditsBtn, rulesBtn, titleView, creditsView,  rulesView
local kitty, heart, timerSrc, timeLeft, score, bg, lives, cup
local times = 0 -- increased to 2 on update timer function(500) to count a second

-- Functions
local MenuScreen, startButtonListeners
local showRules, hideRules, showCredits, hideCredits
local showInfoBar, showKitty, showGameView, gameListeners
local dragKitty, update, onCollision, gameWon, gameLost

function MenuScreen()
	
	titleBg = display.newImage("images/menu_bg.png", w/2, h/2)
    playBtn = display.newImage("images/play.png", w/2, 350)
    rulesBtn = display.newImage("images/rules.png", w/2, 520)
    creditsBtn = display.newImage("images/info.png", w/2, 670)
    titleView = display.newGroup(titleBg, playBtn, rulesBtn, creditsBtn) -- adds buttons to the group
    
   -- transition.from(titleView, {time = 5000}) 
     
    startButtonListeners("add") -- adds an event to the event container
end

function showRules(event) 
    rulesView = display.newImage("images/rules1.png", w/2, h/2+75)
    transition.to(rulesView, {time = 300, x = w/2, onComplete = rulesView:addEventListener("tap", hideRules)}) 
end

function hideRules(event)
    transition.to(rulesView, {time = 300, y = h+rulesView.height})
end

function showCredits(event)
    creditsView = display.newImage("images/credits_image.png", w/2, h/2-15)
    transition.to(creditsView, {time = 300, x = w/2, onComplete = creditsView:addEventListener("tap", hideCredits)})
end

function hideCredits(event)
    transition.to(creditsView, {time = 300, y = h+creditsView.height})
end

function startButtonListeners(event) 
    if(event == "add") then 
        playBtn:addEventListener("tap", showGameView)
        rulesBtn:addEventListener("tap", showRules)
        creditsBtn:addEventListener("tap", showCredits) 
    end 
end

local kittyTable = { 
	width = 939/7, height = 115,
	numFrames = 7, 
	sheetContentHeight = 115, sheetContentWidth = 939
}

local sequenceData = {
	{ 
	name = "jump",
	start = 1, count = 7, time = 500,
	loopDirection = "bounce", loopCount = 2
	}
}

local function jumpRight(event)
	kitty:setSequence("jump")
	kitty:play()
end

-- Info Bar and scores 
function showInfoBar()  
	cup = display.newImage("images/cup.png", 80, 70)
	score = display.newText("0", 170, 70, Arial, 50)
	score:setTextColor(0,1,0)
	
	heart = display.newImage("images/heart.png", 300, 70)
	lives = display.newText("3", 390, 70, Arial, 50)
	lives:setFillColor(1,0,0)
	
	timeLeft = display.newText("20", 510, 70, Arial, 40)
	timeLeft:setTextColor(1, 0, 0)
end

function showKitty()
	sheet = graphics.newImageSheet( "images/kitty2.gif", kittyTable )
	kitty = display.newSprite( sheet, sequenceData ) 
	kitty.x = w/2
	kitty.y = 860
	kitty.xScale, kitty.yScale = 2, 2

kitty:addEventListener("tap", jumpRight)
physics.addBody(kitty, "static")
end

function showGameView(event)
    bg = display.newImage("images/bg1.png", w/2, h/2)
	showInfoBar() 
	showKitty() 
	
-- Game Listeners    
	gameListeners("add")
end

function gameListeners(event)
    if(event == "add") then
        timerSrc = timer.performWithDelay(500, update, 0)
        kitty:addEventListener("collision", onCollision)
        kitty:addEventListener("touch", dragKitty)
    else
        timer.cancel(timerSrc)
        timerSrc = nil
        kitty:removeEventListener("collision", onCollision)
        kitty:removeEventListener("touch", dragKitty)
        physics.stop()
    end
end

-- Drag kitty
function dragKitty(event)
    if(event.phase == "began") then
        lastX = event.x - kitty.x
    elseif(event.phase == "moved") then
        kitty.x = event.x - lastX
    end   
-- Prevent the character from moving outside of screen boundaries
    if((kitty.x - kitty.width * 0.9) < 0) then --left side
             kitty.x = kitty.width * 0.9
           elseif((kitty.x + kitty.width * 0.5) > display.contentWidth) then --right side
             kitty.x = display.contentWidth - kitty.width * 0.5
           end
end

local function temp(event)
	if (event=="tap") then
	MenuScreen()
	end
end

function gameWon()	
gameListeners("remove")
	local bg_w = display.newImage("images/3.png", w/2, h/2-100)
	local bg2 = display.newRect(w/2, 1040, w, 200)
	
    local totalScore = display.newText(score.text, w/2-10, 1000, Arial , 40)
    totalScore:setFillColor(255, 0, 255)
    
    local applause = audio.loadSound("applause.wav")
    audio.play(applause)
    
    transition.from(bg_w, {time = 1000, xScale = 0.5, yScale = 0.5})
    transition.from(bg2, {time = 1000, xScale = 0.5, yScale = 0.5})
    
    bg_w:addEventListener("tap", temp)
    bg2:addEventListener("tap", temp)
    totalScore:addEventListener("tap", temp)
end

-- Decrease Timer
local function updateTimer()    
times = times + 1
if(times == 2) then
    timeLeft.text = tostring(tonumber(timeLeft.text) - 1)
    times = 0
end
-- Check if time is over  
    if(timeLeft.text == "0") then
     gameWon()
    end
end

function update(event)
    -- Add Candy or Frog 
    local rx = math.floor(math.random() * w)
    local r = math.floor(math.random() * 4) -- 0, 1, 2, or 3 (3 is frog)
     
    if(r == 3) then
        local frog = display.newImage("images/frog.png", rx, -20)
        frog.name = "frog"
        physics.addBody(frog)
    else
        local candy = display.newImage("images/candy.gif", rx, -40)
        candy.name = "candy"
        physics.addBody(candy)
    end  
     
--Walls for the candies
local leftWall=display.newRect(0,h/2,2,h)
local rightWall=display.newRect(w,h/2,1,h)
physics.addBody(leftWall,"static")
physics.addBody(rightWall,"static")

updateTimer()    
end



function gameLost()
	gameListeners("remove")
	
	local bgLost = display.newImage ("images/4.png", w/2, h/2)	
	transition.from(bgLost, {time = 3000, xScale = 0.5, yScale = 0.5})
	
	 local sad = audio.loadSound("sad.wav")
     audio.play(sad)  
     
     bgLost:addEventListener("tap", temp)
       
end



function onCollision(event)
    if(event.other.name == "candy") then
        display.remove(event.other) -- Remove candy
        score.text = tostring(tonumber(score.text) + 10) -- Update Score
        
        elseif(event.other.name == "frog") then
        display.remove(event.other)
        score.text = tostring(tonumber(score.text) - 10)
        lives.text= tostring(tonumber(lives.text) - 1)
        
         	if(lives.text=="0") then
         		gameLost()
         		
         	end
    end
end
    
MenuScreen()



































