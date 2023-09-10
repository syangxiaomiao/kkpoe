require 'res.script.config.game'
require 'res.script.config.enemy'

y3.config = {
    enemy = enemy,
    game = game
}

function y3.config:init()
    y3.config.game.countdown = y3.config.game.countdownmax
end