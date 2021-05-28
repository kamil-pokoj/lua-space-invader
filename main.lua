function love.load()
    game_over = false
    game_won = false

    invadersWhoCanFire = 3
    -- Player vars
    player = {}
    player.x = 0
    player.bullets = {}
    player.speed = 5
    bullets_generation_tick = 30
    player.fire = function()
        if bullets_generation_tick <= 0 then
            love.audio.play(player_shoot_sound)
            bullets_generation_tick = 30
            bullet = {}
            bullet.x = player.x + 25
            bullet.y = 550
            table.insert(player.bullets, bullet)
        end
    end    

    --Enemy & enemy controllers
    enemy = {}
    enemies_list = {}
    enemies_list.enemies = {}
    
    function enemies_list:spawn(x, y)
        enemy = {}
        enemy.x = x
        enemy.y = y
        enemy.height = 40
        enemy.width = 85
        enemy.speed = 0.2
        table.insert(self.enemies, enemy)
    end

    --Enemy spawning patterns
    for i=0, 3 do
        for j=0,4 do
        enemies_list:spawn(j*120+120,i*50+15)
        end
    end

    function checkCollisiononEnemy(enemies, bullets)
        for i,v in ipairs(enemies) do
            for j,b in ipairs(bullets) do
                if b.y <= v.y + v.height and b.x > v.x and b.x < v.x + v.width then
                    table.remove(player.bullets, j)
                    table.remove(enemies, i)
                end
            end
        end
    end

    background_image = love.graphics.newImage('images/space_bg.png')
    -- Player resources load
    player.image = love.graphics.newImage('images/player.png')
	player.explose_shoot = love.audio.newSource('sounds/sounds_shoot.mp3','static')
    -- Enemy resources load
    enemy.image = love.graphics.newImage('images/invader.png')
    -- Sounds load
	music = love.audio.newSource('sounds/music.mp3','static')
	player_shoot_sound = love.audio.newSource('sounds/sounds_shoot.mp3','static')
	music:setLooping(true)
	love.audio.play(music)
end

function love.update(dt)
    --Player controls
    if love.keyboard.isDown("right") then
        if player.x > 750 then
			player.x = 750
		end
        player.x = player.x + player.speed
    elseif love.keyboard.isDown("left") then
        if player.x <0 then
            player.x = 0
        end
        player.x = player.x - player.speed

    end
    if love.keyboard.isDown("space") then
        player.fire()
        enemy.fire()
    end

    --Game won check
    if #enemies_list.enemies == 0 then
        game_won = true
    end

    --Enemies controls
    for _,v in pairs(enemies_list.enemies) do
        -- Enemy pass through player, then game over check
        if v.y >= 570 then
            game_over = true
        end 
        v.y = v.y + enemy.speed
    end

    --Player Bullets controller
    for i,v in ipairs(player.bullets) do
        if v.y < -1 then
            table.remove(player.bullets, i)
        end
        v.y = v.y - 10
    end
    
    --Bullet cooldown controller
    bullets_generation_tick = bullets_generation_tick - 1

    checkCollisiononEnemy(enemies_list.enemies, player.bullets)
end

function love.draw()
    love.graphics.draw(background_image)
    if game_won == true then 
        love.graphics.print("Congratulations! You won!")
        return
    end
    if game_over == true then
        love.graphics.print("Game Over!")
        return
    end
	love.graphics.draw(player.image, player.x, 560, 0, 0.5)
    --Bullet spawner
    love.graphics.setColor(255,255,255)
    for _,v in pairs(player.bullets) do
        love.graphics.rectangle("fill", v.x, v.y, 10,10)
    end
    --Enemy spawner
    for _,v in pairs(enemies_list.enemies) do
        love.graphics.draw(enemy.image, v.x, v.y, 0, 0.7)
    end

end