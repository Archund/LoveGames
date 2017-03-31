graphics = {}

debug = true

window = { height = love.graphics:getHeight(), 
           width = love.graphics:getWidth() }

border = { left = 15, 
           right = 15, 
           top = 15, 
           bottom = 15 }

chatBox = { x = border.left, 
            y = window.height - window.height / 3, 
            width = window.width - border.right - border.left, 
            height = window.height / 3 - border.bottom }

chat = { x = chatBox.x + border.left,
         y = chatBox.y + border.top,
         width = chatBox.width - border.left - border.right }

bg = { image = nil, 
       x = border.left, 
       y = border.top, 
       height = window.height - window.height / 3 - border.top - border.bottom, 
       width = window.width - border.left - border.right }

text = { font = nil,
         size = 18,
         full = "",
         printed = "",
         index = 0,
         finished = false }

timers = { printMax = 0.12,
           toPrint = 0,
           accelerate = true }

story = { text = {},
          index = 1,
          readNext = true }
index = 1
maxLines = 1

buttons = { all = nil,
            go = nil,
            previous = nil,
            x =  window.width - 56 - border.left * 2,
            y =  window.height - 48 - border.top * 2 }


function graphics.load(arg)
    timers.toPrint = timers.printMax
    text.font = love.graphics.newFont("assets/neuropol_x.ttf", text.size)
    bg.image = love.graphics.newImage("assets/bg.jpg")
    
    buttons.all = love.graphics.newImage("assets/buttons.png")
    buttons.go = love.graphics.newQuad(0 * 56, 1 * 48, 56, 48, buttons.all:getDimensions())
    buttons.previous = love.graphics.newQuad(1 * 56, 1 * 48, 56, 48, buttons.all:getDimensions())

    file, err = io.open("/Users/mauriciog/Documents/LoveGames/Game 1/story.txt")
    if err then 
        print("Something went wrong while opening \"story.txt\"")
        return
    end
    
    line = file:read()
    while line ~= nil do
        -- print(line)
        story.text[maxLines] = line
        maxLines = maxLines + 1
        line = file:read()
    end    
    
    print(maxLines)
    file:close() 
end

function love.keypressed(key, scancode, isRepeat)
    if key == "escape" then
        love.event.push("quit")
    elseif key == "return" and not isRepeat and text.finshed ~= "Then End" then
        if story.readNext then
            if story.index < maxLines then 
                print(story.index)
                story.readNext = false
                text.full = story.text[story.index]
                text.finished = false
                text.printed = ""
                text.index = 0
                story.index = story.index + 1
            else
                text.printed = "The End"
            end
        elseif not text.finished then
            text.finished = true
            story.readNext = true
            text.printed = text.full
        end
    end
end

function graphics.update(dt)
    timers.accelerated = false    

    if love.keyboard.isDown("space") then
        timers.accelerated = true
    end
    
    speed = 1
    
    if timers.accelerated then
        speed = speed * 10
    end

    timers.toPrint = timers.toPrint - (speed * dt)
    
    if timers.toPrint <= 0 and not text.finished then
        timers.toPrint = timers.printMax
        text.index = text.index + 1
        goChar = string.sub(text.full, text.index, text.index)
        if string.match(goChar, " ") then
            text.index = text.index + 1
        end
        text.printed = string.sub(text.full, 0, text.index)
        
        if text.printed == text.full then
            text.finished = true
            story.readNext = true
        end 
    end
end

function graphics.draw(dt)
    love.graphics.setBackgroundColor(76, 76, 76)
    love.graphics.draw(bg.image, bg.x, bg.y, 0, bg.width / bg.image:getWidth(), bg.height / bg.image:getHeight(), 0, 0)
    love.graphics.setColor(0, 255, 255)
    love.graphics.rectangle("fill", chatBox.x , chatBox.y, chatBox.width, chatBox.height)
    love.graphics.setColor(255, 0, 255)
    love.graphics.setFont(text.font)
    love.graphics.printf(text.printed, chat.x, chat.y, chat.width, "left") 
    love.graphics.setColor(255, 255, 255)
    if story.index > 1 then
        love.graphics.draw(buttons.all, buttons.previous, border.left * 2, buttons.y)
    end
    if text.finished then
        love.graphics.draw(buttons.all, buttons.go, buttons.x, buttons.y)
    end
end

function love.mousereleased(x, y, button, istouch)
    if y >= buttons.y and y <= buttons.y + 48 then
        if x >= (border.left * 2) and x <= (border.left * 2 + 56) then
            print("Previous button clicked")
        elseif x >= buttons.x and x <= (buttons.x + 56) then
            print("Next button clicked")
        end
    end
end
