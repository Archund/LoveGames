-- Configuration
function love.conf(t)
    t.title = "Game 1" -- The title of the window the game is in (string)
    t.version = "0.10.2"         -- The LÖVE version this game was made for (string)
    t.window.width = 960        -- we want our game to be long and thin.
    t.window.height = 640

    -- For Windows debugging
    t.console = true
end
