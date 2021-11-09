--[[
Nathan Moore
overlay.lua

This file contains all information to set up an overlay situated in the top leftmost corner of the screen
This overlay is comprised of
   two sliders
      amount of deaths to show >=
      speed multiplier for county representative balls movement
   two information display areas for slider information
      current amount of deaths to display >=
      current movement speed selected
   a single button which when clicked closes the overlay
]]

local composer = require( "composer" )
local scene = composer.newScene()
local widget = require( "widget" )
local scene = composer.newScene()
local localLeft = 300
local localTop = 200

--initialize the rectangles the text for the sliders will display in
local speedRect = display.newRect(300, 130, 130, 30 )
local deathRect = display.newRect(310, 230, 150, 30 )

--intiialize all of the text to display for the sliders
local deathText = display.newText("deaths: ", 280, 230, native.systemFont, 24)
deathText:setFillColor( 0,0,0 )--set the fill color for the 
deathText:toFront( )

local speedText = display.newText("speed: ", 280, 130, native.systemFont, 24)
speedText:setFillColor( 0,0,0 )
speedText:toFront( )

local totDeathText = display.newText("", 350, 230, native.systemFont, 24 )
totDeathText:setFillColor( 0,0,1 ) -- set the display text to blue
totDeathText:toFront( )

local speedChangeText = display.newText("", 340, 130, native.systemFont, 24 )
speedChangeText:setFillColor( 0,0,1 ) -- set the text to blue
speedChangeText:toFront( )


--function to show the main scene
local function showScene1()
   local options = {
      effect = "crossFade",
      time =  250,
   }
   composer.hideOverlay() -- hide the overlay 
end

--event handler for button to click and hide the overlay
local function handleButtonEvent(event)
      if ("ended" == event.phase) then --if the event is in its last phase (up press)
           showScene1() --hide the overlay
      end
end
 
-- creation of the overlay scene
function scene:create(event) --event handler to create the scene
local sceneGroup = self.view --the group is the current scene we are in and everything in it

--local function to update the text for and value of the death slider
local function updateDeath(event)
   local value = map(event.value,0, 100, 20, 2000) -- map the value to be between 0 and 100 for use with slider
   totDeathText.text = value -- display the current actual speed value
   composer.setVariable( "totalDeaths", value ) --set the slider to the value we are creating
end

--local function to update the text for and value of the speed slider
local function updateSpeed(event)
   local displayValue = map(event.value,0, 100, 1, 10) -- map the values to be between 0 and 100 from 1 to 10
   speedChangeText.text = displayValue -- display the value we have set
   composer.setVariable( "totalSpeed", displayValue ) -- set the slider to this value
end

--initialization of slider widgets and this event listeners for death and speed displays
local deathSlider = widget.newSlider({
    top = 210,
    left = 20,
    orientation = "horizontal",
    width = 200,
    value = 0,
   listener = updateDeath
})

local speedSlider = widget.newSlider({
    top = 110,
    left = 20,
    orientation = "horizontal",
    width = 200,
    value = 50,
    listener = updateSpeed
}) 

--add everything to the scene after creation so it will disappear when scene is finished
sceneGroup:insert(deathSlider)
sceneGroup:insert(speedSlider)
sceneGroup:insert(speedRect)
sceneGroup:insert(deathRect)
sceneGroup:insert(deathText)
sceneGroup:insert(speedText)
sceneGroup:insert(totDeathText)
sceneGroup:insert(speedChangeText)

--create the button widget to close the scene
local returnButton= widget.newButton( {
        left = 50,
        top = 5,
        shape = "roundedRect",
        width = 100,
        height = 30,
        label = "Return",
        fontSize = 24,
        onPress = showScene1 --return to the main scene when pressed
    }) 
   sceneGroup:insert(returnButton) -- add this button to the scene group
end
 
--initialization of all scene functions for this case they will not do much other that call self.view functions
function scene:show( event )
   local sceneGroup = self.view
   local phase = event.phase 

   if ( phase == "will" ) then
   elseif ( phase == "did" ) then
   end    
end

function scene:hide( event )
   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
   elseif ( phase == "did" ) then     
   end
end
 
function scene:destroy( event )
   local sceneGroup = self.view
end
 
 
-- scene listener additions
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

--return the scene to the scene that called this script
return scene
