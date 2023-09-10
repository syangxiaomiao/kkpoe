local setmetatable = setmetatable

---@class  hero
local hero = {}
hero.__index = hero
y3.hero = hero

---@param data table
function hero:init(data)
    --绑定单位
    hero["unit"] = data.unit
    --初始化天赋
    hero["talent"]={}
    --初始化伤害加成
    for key, value in pairs(const.DamgeType) do
        hero["damage_bonus"][value] = 0.0
    end
end