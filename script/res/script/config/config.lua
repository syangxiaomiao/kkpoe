require 'res.script.config.game'
require 'res.script.config.enemy'

y3.config = {
    enemy = enemy,
    game = game
}

function y3.config:init()
    --初始化敌人配置
    self.enemy:init_enemy();
    --初始化游戏配置
    self.game:init_game();
end