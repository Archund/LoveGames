debug = true

-- Dimensional variables

window = {  height = love.graphics:getHeight(),
            width = love.graphics:getWidth() }

border = 10
invunerableTimerMax = 2.75
reloadTimerMax = 0.5
spawnEnemyTimerMax = 0.5
blinkTimerMax = 0.25
maxLives = 4;
enemySpeed = 200

-- Arrays

player = {  x = 0,
            y = 0,
            invunerable = false }

speed = {   player = 200,
            enemy = 150,
            bullet = 250 }

timers = {  invunerable = invunerableTimerMax,
            spawnEnemy = spawnEnemyTimerMax,
            reload = reloadTimerMax,
            fadeOut = 0,
            fadeIn = 0 }

img = { player = nil,
        enemy = nil,
        bullet = nil,
        heart = nil,
        nohear = nil }

sound = { laser = nil }

enemies = {}

bullets = {}

hearts = {}

score = {   total = 0,
            text = "Points: ",
            x = window.width - border,
            y = border }

-- Global variables
lives = maxLives

function love.load(arg)
    img.player = love.graphics.newImage("assets/ship.png")
    img.bullet = love.graphics.newImage("assets/bullet.png")
    img.enemy = love.graphics.newImage("assets/asteroids/small/a30000.png")
    img.heart = love.graphics.newImage("assets/heart.png")
    img.noheart = love.graphics.newImage("assets/noheart.png")
   
    sound.laser = love.audio.newSource("assets/laser_shot.ogg", "static")

    --love.window.setFullscreen( true )
    window.height = love.graphics:getHeight()
    window.width = love.graphics:getWidth() 

    player.x = (window.width / 2)  - (img.player:getWidth() / 2)
    player.y = window.height - (border * 4) - img.player:getHeight()
    
    for i = 1, maxLives, 1 do
        heart = {   x = border * i / 2 + img.heart:getWidth() * (i - 1),
                    y = border }
        table.insert(hearts, heart)
    end

    math.randomseed( os.time() )
end

function love.keypressed(key, scancode, isRepeat)
    if key == "escape" then
        love.event.push("quit")  
    end
end

function love.update(dt)
    
    checkCollisions()
    updateTimers(dt)
    updateMovements(dt)
    
    score.text = ("Points: " .. tostring(score.total) )
    score.x = window.width - border - (score.text:len() * 10)

    if love.keyboard.isDown("space", "rctrl", "lctrl", "ctrl") and timers.reload < 0 then
        newBullet = { x = player.x + (img.player:getWidth() / 2), y = player.y, img = img.bullet }
        table.insert(bullets, newBullet)
        timers.reload = reloadTimerMax
        sound.laser:stop()
        sound.laser:play()
    end

    for i, heart in ipairs(hearts) do
        if i > lives then
            heart.img = img.noheart
        else
            heart.img = img.heart
        end
    end

    if lives == 0 and love.keyboard.isDown("r") then
        bullets = {}
        enemies = {}
        
        timers.reload = reloadTimerMax
        timers.spawnEnemy = spawnEnemyTimerMax
 
        player.x = (window.width / 2)  - (img.player:getWidth() / 2)
        player.y = window.height - (border * 4) - img.player:getHeight()
        
        score.total = 0
        lives = maxLives
    end

    if love.keyboard.isDown("left", "a") then
        if player.x > 0 then
            player.x = player.x - (speed.player * dt)
        end
    elseif love.keyboard.isDown("right", "d") then
        if player.x < (love.graphics.getWidth() - img.player:getWidth()) then
            player.x = player.x + (speed.player * dt)
        end
    end
end

function love.draw(dt)
    if lives > 0 then
        if player.invunerable then
            if timers.fadeOut > 0 then
                love.graphics.setColor(255, 255, 255, timers.fadeOut*(255/blinkTimerMax))
            else
                love.graphics.setColor(255, 255, 255, timers.fadeIn*(255/blinkTimerMax)) 
            end
        end 
        love.graphics.draw(img.player, player.x, player.y)
        love.graphics.setColor(255, 255, 255) 

        for i, enemy in ipairs(enemies) do
            love.graphics.draw(enemy.img, enemy.x, enemy.y)
            --love.graphics.draw(enemy.img, enemy.x, enemy.y, enemy.angle)
        end

        for i, bullet in ipairs(bullets) do
            love.graphics.draw(bullet.img, bullet.x, bullet.y)
        end

        for i, heart in ipairs(hearts) do
            love.graphics.draw(heart.img, heart.x, heart.y)
        end
 
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(score.text, score.x, score.y)

    else
        love.graphics.print("Press 'R' to restart", love.graphics:getWidth() / 2 - 50, love.graphics:getHeight() / 2 - 10)
    end
end

function checkCollisions()
    for i, enemy in ipairs(enemies) do
        for j, bullet in ipairs(bullets) do
            if checkCollision(  enemy.x,
                                enemy.y,
                                enemy.img:getWidth(),
                                enemy.img:getHeight(),
                                bullet.x,
                                bullet.y,
                                bullet.img:getWidth(),
                                bullet.img:getHeight() ) then
                table.remove(bullets, j)
                table.remove(enemies, i)
                score.total = score.total + 1
            end
        end

        if not player.invunerable and
        checkCollision( enemy.x,
                        enemy.y,
                        enemy.img:getWidth(),
                        enemy.img:getHeight(),
                        player.x,
                        player.y,
                        img.player:getWidth(),
                        img.player:getHeight() ) and
        lives > 0 then
            table.remove(enemies, i)
            lives = lives - 1
            player.invunerable = true
            timers.invunerable = invunerableTimerMax 
        end
    end 
end

function updateTimers(dt)
    timers.reload = timers.reload - dt

    timers.spawnEnemy = timers.spawnEnemy - dt

    if timers.spawnEnemy < 0 then
        timers.spawnEnemy = spawnEnemyTimerMax

        randomNumber = math.random(border, love.graphics.getWidth() - border)
        newEnemy = {    x = randomNumber,
                        y = -border,
                        img = img.enemy,
                        angle = math.random(),
                        rotationSpeed = math.random(4) * math.random(4) }
        table.insert(enemies, newEnemy)
    end
    
    if player.invunerable then
        timers.invunerable = timers.invunerable - dt 
        if (timers.invunerable - blinkTimerMax * 3) > 0 then
            if timers.fadeOut > 0 then
                timers.fadeOut = timers.fadeOut - dt
            elseif timers.fadeIn < blinkTimerMax then
                timers.fadeIn = timers.fadeIn + dt
            else
                timers.fadeOut = blinkTimerMax
                timers.fadeIn = 0
            end
        else
            timers.fadeOut = blinkTimerMax
            timers.fadeIn = 0
        end

        if timers.invunerable < 0 then
            player.invunerable = false    
        end

    end
end

function updateMovements(dt)
    for i, enemy in ipairs(enemies) do
        enemy.y = enemy.y + (speed.enemy * dt)
        enemy.angle = enemy.angle + dt * math.pi / enemy.rotationSpeed


        if enemy.y > window.height then -- remove enemies when they pass off the screen
            table.remove(enemies, i)
        end
    end

    for i, bullet in ipairs(bullets) do
        bullet.y = bullet.y - (speed.bullet * dt)

        if bullet.y < 0 then
            table.remove(bullets, i)
        end
    end
end

function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < (x2 + w2) and
        x2 < (x1 + w1) and
        y1 < (y2 + h2) and
        y2 < (y1 + h1)
end
