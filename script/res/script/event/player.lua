player = {
    [1] = {}
}

--获取玩家区域敌人数量
function get_player_area_enemy_count()
    --获取区域
    local area = y3.get_rectangle_area_by_scene_id(10002)
    --获取区域敌人组
    local unit_group = area:get_unit_group_in_area(y3.player(31))

    count = 0
    --value 就是unit
    for key, value in pairs(unit_group:pick()) do
        --转换成unit对象
        unit = y3.unit.create_lua_unit_from_py(value.base())
        if unit:get_hp():float() > 0 then
            count = count + 1
        end
    end

    if unit_group == nil then
        player[1]["enemy_count"] = 0
    else
        --获取区域敌人数量
        player[1]["enemy_count"] = count
    end

    local py_ui = y3.ui.get_ui(y3.player(1), "shop_panel.主线任务.背景.剩余怪物.数量")
    py_ui:set_text(tostring(player[1]["enemy_count"]))
end

--检测玩家区域剩余敌人数量
y3.game:event({ const.GlobalEventType['GAME_ELAPSE_REPEAT'], 0, 5 }, function()
    get_player_area_enemy_count()
end)
