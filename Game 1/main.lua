require "graphics"

GRAPHICS = 1

states = {  [1] = graphics }

state = GRAPHICS

function love.load(arg)
    states[state].load(arg)
end

function love.update(dt)
    states[state].update(dt)
end

function love.draw(dt)
    states[state].draw(dt)
end
