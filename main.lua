--[[
Nathan Moore
CS 371 - Assignment 3 COVID-19 Data Display
Samsung Galaxy S5 - 1080x1920

This application reads in a covid_al.csv file for the information reported from each county in Alabama
and reports the population, cases, and deaths in each county in the form of circles laid within themselves
for each county
	the outside ball = population
	middle ball = total # cases
	inner ball = total # deaths
The speed of the balls is directly correlated to the fatality rate within the county

The user also has an overlay button which can be pressed to display two sliders and a return button
	these sliders control 
		the amount of counties that are shown based on deaths reported
		the speed at which the balls are currently moving
]]

local composer = require("composer") -- require a scene composer
display.setStatusBar(display.HiddenStatusBar) --hide the status bar
composer.gotoScene("covidData") --go to the main scene