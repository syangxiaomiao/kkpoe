require 'y3'
require 'res.script.event.player'

--怪物进攻倒计时
function enemyAttack()
    --data 属性 current_timer
    y3.config.game.attackTimer = y3.timer.run_looped_timer(1, true, function(data)
        --章节最大波数
        local level = y3.config.game.maxwave
        --当前章节
        local chapter = y3.config.game.chapter

        --获取波数
        local wave = y3.config.game.wave
        --获取最大波数
        local maxwave = y3.config.game.maxwave

        --是否最后一波
        local is_over = false

        --print(player[1]["enemy_count"])
        --倒计时未到期
        --设置计时UI
        local py_ui = y3.ui.get_ui(y3.player(1), "shop_panel.主线任务.背景.下一波计时.计时")
        py_ui:set_text(y3.config.game.countdown .. "s")

        --判断是否倒计时结束
        if y3.config.game.countdown == 0 then
            --倒计时到期处理
            y3.pause_timer(y3.timer.get_lua_timer_from_py(data.current_timer))
            --判断游戏是否结束
            if wave == maxwave then
                is_over = true
            end

            --设置计时UI
            --local py_ui = y3.ui.get_ui(y3.player(1), "shop_panel.主线任务.背景.下一波计时.计时")
            --py_ui:set_text("战斗中")

            --怪物进攻
            for i = 1, y3.config.enemy[wave].count do
                local unit_id = y3.config.enemy[wave].id
                --创建敌方单位
                y3.unit.create_unit(unit_id, y3.get_rectangle_area_by_scene_id(10001):random_point(),
                    y3.convert_float_to_angle(180), y3.player(31))
            end
            if y3.config.enemy[wave].type == const.UnitType['BOSS'] then
                y3.display_info_to_player(y3.player(1), "BOSS入侵", false)
            end
            --判断是否该下一章节
            if wave % level == 1 and wave ~= 1 then
                chapter = chapter + 1
                if chapter == 2 then
                    --章节UI更新
                    local py_ui = y3.ui.get_ui(y3.player(1), "shop_panel.主线任务.背景.标题")
                    py_ui:set_text("第二章")
                end
                if chapter == 3 then
                    --章节UI更新
                    local py_ui = y3.ui.get_ui(y3.player(1), "shop_panel.主线任务.背景.标题")
                    py_ui:set_text("第三章")
                end
                if chapter == 4 then
                    --章节UI更新
                    local py_ui = y3.ui.get_ui(y3.player(1), "shop_panel.主线任务.背景.标题")
                    py_ui:set_text("第四章")
                end
                if chapter == 5 then
                    --章节UI更新
                    local py_ui = y3.ui.get_ui(y3.player(1), "shop_panel.主线任务.背景.标题")
                    py_ui:set_text("第五章")
                end
            end

            --波数U1更新
            local py_ui = y3.ui.get_ui(y3.player(1), "shop_panel.主线任务.背景.当前波数.波数")
            py_ui:set_text(wave - level * (chapter - 1) .. "/6")

            --波数+1
            wave = wave + 1

            --更新全局变量
            y3.config.game.chapter = chapter
            y3.config.game.wave = wave

            if is_over then
                --这里是游戏最后一波结束逻辑c
                --预留
            else
                --恢复倒计时
                y3.config.game.countdown = y3.config.game.countdownmax
                y3.resume_timer(y3.timer.get_lua_timer_from_py(data.current_timer))
            end
            return
        end
        --倒计时-1
        y3.config.game.countdown = y3.config.game.countdown - 1
    end).base()
end

--注册事件，游戏初始化
y3.game:event(const.GlobalEventType['GAME_INIT'], function(_, data)
    y3.config:init()
    enemyAttack()
end)
---resource block start---
