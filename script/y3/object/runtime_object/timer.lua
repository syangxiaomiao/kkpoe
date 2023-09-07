---@alias Timer.OnTimer fun(timer: Timer,...)

---@class Timer
---@field handle py.Timer
---@field private on_timer Timer.OnTimer
---@field private include_name? string
---@overload fun(py_timer: py.Timer, on_timer: Timer.OnTimer): self
local M = Class 'Timer'

M.type = 'timer'

---@private
M.id_counter = y3.util.counter()

---@private
M.all_timers = setmetatable({}, y3.util.MODE_V)

---@param py_timer py.Timer
---@param on_timer Timer.OnTimer
---@return self
function M:__init(py_timer, on_timer)
    self.handle = py_timer
    self.on_timer = on_timer
    self.id = self.id_counter()
    self.include_name = y3.reload.getCurrentIncludeName()
    M.all_timers[self.id] = self
    return self
end

function M:__del()
    GameAPI.delete_timer(self.handle)
    M.all_timers[self.id] = nil
end

---@param py_timer py.Timer
---@param on_timer Timer.OnTimer
---@return Timer
function M.get_by_handle(py_timer, on_timer)
    local timer = New 'Timer' (py_timer, on_timer)
    return timer
end


y3.py_converter.register_py_to_lua('py.Timer', M.get_by_handle)
y3.py_converter.register_lua_to_py('py.Timer', function (lua_value)
    return lua_value.handle
end)

---@param frame integer
---@param count integer
---@param callback fun()
---@return py.Timer
local function run_timer_by_frame(frame, count, callback)
    local timer_node = {
        on_timer_callback = callback,
        _rt = {
            call_with_frame = function (f)
                f()
            end
        }
    }
    ---@diagnostic disable-next-line: undefined-field
    return GameAPI.run_timer_by_frame(frame, count, false, timer_node, {})
end

-- 等待时间后执行
---@param timeout number
---@param on_timer fun(timer: Timer)
---@return Timer
function M.wait(timeout, on_timer)
    ---@type Timer
    local timer
    local py_timer = GameAPI.run_lua_timer(Fix32(timeout), 0, false, function()
        timer:execute()
        timer:remove()
    end, {})
    timer = New 'Timer' (py_timer, on_timer)
    return timer
end

-- 等待一定帧数后执行
---@param frame integer
---@param on_timer fun(timer: Timer)
---@return Timer
function M.wait_frame(frame, on_timer)
    ---@type Timer
    local timer
    local py_timer = run_timer_by_frame(frame, 0, function()
        timer:execute()
        timer:remove()
    end)
    timer = New 'Timer' (py_timer, on_timer)
    return timer
end

-- 循环执行
---@param timeout number
---@param on_timer fun(timer: Timer, count: integer)
---@return Timer
function M.loop(timeout, on_timer)
    local timer
    local count = 0
    local py_timer = GameAPI.run_lua_timer(Fix32(timeout), -1, false, function()
        count = count + 1
        timer:execute(count)
    end, {})
    timer = New 'Timer' (py_timer, on_timer)
    return timer
end

-- 循环一定帧数后执行
---@param frame integer
---@param on_timer fun(timer: Timer, count: integer)
---@return Timer
function M.loop_frame(frame, on_timer)
    ---@type Timer
    local timer
    local count = 0
    local py_timer = run_timer_by_frame(frame, -1, function()
        count = count + 1
        timer:execute(count)
    end)
    timer = New 'Timer' (py_timer, on_timer)
    return timer
end

-- 循环指定次数
---@param timeout number
---@param times integer
---@param on_timer fun(timer: Timer, count: integer)
---@return Timer
function M.count_loop(timeout, times, on_timer)
    local timer
    local count = 0
    local py_timer = GameAPI.run_lua_timer(Fix32(timeout), times, false, function()
        count = count + 1
        timer:execute(count)
    end, {})
    timer = New 'Timer' (py_timer, on_timer)
    return timer
end

-- 循环一定帧数指定次数
---@param frame integer
---@param times integer
---@param on_timer fun(timer: Timer, count: integer)
---@return Timer
function M.count_loop_frame(frame, times, on_timer)
    local timer
    local count = 0
    local py_timer = run_timer_by_frame(frame, times, function()
        count = count + 1
        timer:execute(count)
    end)
    timer = New 'Timer' (py_timer, on_timer)
    return timer
end

-- 立即执行
function M:execute(...)
    xpcall(self.on_timer, log.error, self, ...)
end

-- 移除计时器
function M:remove()
    Delete(self)
end

-- 暂停计时器
function M:pause()
    GameAPI.pause_timer(self.handle)
end

-- 继续计时器
function M:resume()
    GameAPI.resume_timer(self.handle)
end

-- 是否在运行
function M:is_running()
    return GameAPI.is_timer_valid(self.handle)
end

---获取计时器经过的时间
---@return number time 计时器经过的时间
function M:get_elapsed_time()
    return GameAPI.get_timer_elapsed_time(self.handle)
end

---获取计时器初始计数
---@return integer count 初始计数
function M:get_init_count()
    return GameAPI.get_timer_init_count(self.handle)
end

---获取计时器剩余时间
---@return number time 计时器剩余时间
function M:get_remaining_time()
    return GameAPI.get_timer_remaining_time(self.handle)
end

---获取计时器剩余计数
---@return integer count 剩余计数
function M:get_remaining_count()
    return GameAPI.get_timer_remaining_count(self.handle)
end

---获取计时器设置的时间
---@return number time 设置的时间
function M:get_time_out_time()
    return GameAPI.get_timer_time_out_time(self.handle)
end

---@return string?
function M:get_include_name()
    return self.include_name
end

-- 遍历所有的计时器，仅用于调试（可能会遍历到已经失效的）
---@return fun():Timer?
function M.pairs()
    local timers = {}
    for _, timer in y3.util.sortPairs(M.all_timers) do
        timers[#timers+1] = timer
    end
    local i = 0
    return function ()
        i = i + 1
        return timers[i]
    end
end

return M
