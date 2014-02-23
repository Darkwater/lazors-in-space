function love.conf(t)
    t.title                 = "Lazors in Space"
    t.author                = "Darkwater"
    t.url                   = "http://novaember.com/"
    t.identity              = "lis"
    t.version               = "0.9.0"
    t.window.icon           = "icon.png"
    t.window.width          = 1024
    t.window.height         = 640
    t.window.minwidth       = 320
    t.window.minheight      = 240
    t.window.fullscreen     = false
    t.window.fullscreentype = "normal"
    t.window.fsaa           = 0
    t.window.display        = 1
    t.window.vsync          = true
    t.window.borderless     = false
    t.window.resizable      = true
    t.window.centered       = true
    t.modules.joystick      = true
    t.modules.audio         = true
    t.modules.keyboard      = true
    t.modules.event         = true
    t.modules.image         = true
    t.modules.graphics      = true
    t.modules.timer         = true
    t.modules.mouse         = true
    t.modules.sound         = true
    t.modules.physics       = true
end
