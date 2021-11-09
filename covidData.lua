--[[
Nathan Moore
covidData.lua

	This file creates a scene which reads from a .csv file to
	populate a series of balls representing
		county population
		cases of COVID-19
		deaths from COVID-19
	inside of each county

	The ball movement speed is initialized as a ratio of the cases of COVID-19 in that county

	An 'Overlay' button is initialized to allow for two sliders which control
		the amount of counties shown based on COVID-19 cases
		the speed at which the balls representing counties move
]]

local composer = require( "composer" ) --require a scene composer
local scene = composer.newScene() --create a new scene
local csv = require("csv") --require our csv reader file
local widget = require("widget") --require there to be a widget
local path = system.pathForFile("covid_al.csv") -- find the file path for the covid data
local file = csv.open(path, {separator = ",", header = true}) --read in the csv file
local balls = {} -- create an empty list for the amount of balls

--set a change in speed to start on both the x and y axis
local deltaX = math.random() * 10 
local deltaY = math.random() * 10

--set the content bounds so we can always see the balls we create
W = display.contentWidth - 10
H = display.contentHeight - 40


--[[
  * @param {float} value            The incoming value to be converted
  * @param {float} lowCurRange      Lower bound of the value's current range
  * @param {float} upCurRange       Upper bound of the value's current range
  * @param {float} lowTargRange     Lower bound of the value's target range
  * @param {float} upTargRange      Upper bound of the value's target range
]]
function map (value, lowCurRange, upCurRange, lowTargRange, upTargRange) 
    return lowTargRange + (upTargRange - lowTargRange) * ((value - lowCurRange) / (upCurRange - lowCurRange));
 end

--function to allow for the slider to update the range of counties we want to view based on number of total deaths
local function updateDeaths()
	local totalDeaths = composer.getVariable("totalDeaths")
	
	for  _, ball in ipairs(balls) do
		if ball.death < totalDeaths then --if the county has less than the amount of deaths the slider represents
			ball.isVisible = false -- dont show the balls representing those counties
		else 						--otherwise
			ball.isVisible = true   --show the balls representing counties that have greater or equal to the amount of deaths selected
		end
	end
end

--function to allow for the overlay to display properly
local function switchOverlay()
	local options = {
	  isModal = true,
      effect = "crossFade",
      time =  250
   }
   composer.showOverlay("overlay", options) -- call the composer to show the overlay by citing its class
end

--public function to create a new scene
function scene:create( event )
	composer.setVariable( "totalDeaths", 0 ) --set the total deaths to 0 to start
	composer.setVariable("totalSpeed", 1) --set the total speed to 1 to start

	local sceneGroup = self.view -- this scene group is the scene we are currently viewing

	--add a button to click to display the overlay
	local overlayButton = widget.newButton({
	        left = 200,
	        top = -10,
	        shape = "roundedRect",
	        width = 200,
	        height = 50,
	        label = "OVERLAY",
	        fontSize = 28,
	        onPress = switchOverlay
	    } ) 
	sceneGroup:insert(overlayButton)

	--local function within the scene to allow setting our balls to random colors
	local function setFillColorRandom(obj)
		obj:setFillColor(math.random(),math.random(),math.random())
	end

	for record in file:lines() do
		--create some local variables within this loop to assign to each individual circle group
		local population = record.Population
		local cases = record.Cases
		local deaths = record.Death 
		local county = record.Countyname
		local fatalityRate = record.Fatalityrate

		--create a new group of balls
		local ballGroup = display.newGroup()
		ballGroup.death = deaths + 0 --set the deaths of this group to the incoming deaths reported in the file

		local radiusPop = map(population,10, 1000000, 2, 100) --population can have large variance so set this to cover extremely small and extremely large cities
		local radiusCase =  map(cases,50, 1000000, 20, 100) --cases can potentially be as large as the entire city so we set this similarly
		local radiusDied = map(deaths,20, 10000, 2, 100) --deaths are more rare so this should have smaller bounds so the circle shows but is not too large and throws off visuals

		--start the balls at a random coordinate
		local xCord = math.random(10,100)
		local yCord = math.random(5, 100)

		local ballOuter = display.newCircle( ballGroup, xCord, yCord, radiusPop ) --outer ball represents the entire population of an area
		local ballMiddle = display.newCircle( ballGroup, xCord, yCord, radiusCase ) -- middle ball represents the number of citizens who contracted COVID-19
		local ballInner = display.newCircle( ballGroup, xCord, yCord, radiusDied ) -- center ball represents the number of citizens who died of COVID-19
		
		--set all the balls to random colors 
		setFillColorRandom(ballOuter)
		setFillColorRandom(ballMiddle)
		setFillColorRandom(ballInner)

		--set the speed of each balls movement to be related to their fatality rate in the county
		ballGroup.deltaX = fatalityRate*50
		ballGroup.deltaY = fatalityRate*50

		local ballText = display.newText(ballGroup, county, xCord, yCord + 10, native.systemFont, radiusCase)

		--set the balls to start at random position within the screen width bounds
		ballGroup.x = math.random(10, 1000)
		ballGroup.y = math.random(10, 1000)

		table.insert(balls, ballGroup) --insert the balls into a group
		sceneGroup:insert(ballGroup) -- insert that group into our scene
	end

	timer.performWithDelay( 0, updateDeaths, 0 ) --call frame timer immediately and indefinitely

end

function scene:show( event )
   local sceneGroup = self.view --the scene group is this scene
   local phase = event.phase --make an local variable for the phase we are currently in
 
   if ( phase == "will" ) then -- if the scene is coming up
   	local function update() --start updating
   		local speed = composer.getVariable("totalSpeed") --get the total speed and set it to a variable to move balls
		for  _, ball in ipairs(balls) do --for all the balls in our ball group 
			local ballInner = ball[1] -- balls radius we want to stop from moving outside of the screen is the center of all three balls or the radius of the center most ball

			--if we fall outside the x bounds
			if ((ball.x + ball.deltaX) > (display.contentWidth - 80))  or (ball.x + ball.deltaX < - 20) then
				ball.deltaX = -ball.deltaX
			end

			--if we fall outside the y bounds
			if ((ball.y + ball.deltaY) > (display.contentHeight - ballInner.path.radius)) or ((ball.y + ball.deltaY) < (ballInner.path.radius - 40)) then 
				ball.deltaY = -ball.deltaY
			end

			--if we are inside of both bounds
			ball.x = ball.x + ball.deltaX * speed
			ball.y = ball.y + ball.deltaY * speed
	
		end
	end
   timer.performWithDelay( 0, update, 0) -- call frame timer immediately and indefinitely
   elseif ( phase == "did" ) then    -- Called when the scene is still off screen (but is about to come on screen).
   	--do nothing
   end
end -- end of scene:show()

--functions to hide and destroy scene if needed
function scene:hide( event )
   local sceneGroup = self.view
 end


function scene:destroy( event )
   local sceneGroup = self.view
   -- Called prior to the removal of scene's view ("sceneGroup").
   -- Insert code here to clean up the scene.
   -- Example: remove display objects, save state, etc.
end

-- scene listener addition
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

--make sure to return the scene for the main.lua to pick up this scene properly
return scene