require 'y3'

--怪物进攻倒计时
function enemyAttack()
    y3.loop(1, function(data)
        print("123213")
    end)
end

--注册事件，游戏初始化
y3.game:event(const.GlobalEventType['GAME_INIT'], function(_, data)
    enemy_config = y3.config.enemy
    --游戏配置
    game_config  = y3.config.game
    enemyAttack()
end)
---resource block start---
