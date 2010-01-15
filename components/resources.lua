local graphics = require 'dokidoki.graphics'

background = graphics.sprite_from_image('sprites/background.png', nil, {0, 0})

fighter_sprite = graphics.sprite_from_image('sprites/fighter.png', nil, 'center')
bomber_sprite = graphics.sprite_from_image('sprites/bomber.png', nil, 'center')
frigate_sprite = graphics.sprite_from_image('sprites/frigate.png', nil, 'center')
factory_sprite = graphics.sprite_from_image('sprites/factory.png', nil, 'center')
needle_sprite = graphics.sprite_from_image('sprites/needle.png', nil, 'center')

bubble_sprite = graphics.sprite_from_image('sprites/bubble.png', nil, 'center')
bomb_sprite = graphics.sprite_from_image('sprites/bomb.png', nil, 'center')
missile_sprite = graphics.sprite_from_image('sprites/missile.png', nil, 'center')