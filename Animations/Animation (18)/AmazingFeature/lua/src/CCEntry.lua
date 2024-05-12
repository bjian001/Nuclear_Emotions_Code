local CCMain = require("CCMain")


local CCHandlers = {
    effects_adjust_speed = "speed",
    effects_adjust_filter = "filter",
    effects_adjust_texture = "texture",
    effects_adjust_noise = "noise",
    effects_adjust_sharpen = "sharp",
    effects_adjust_soft = "soft",
    effects_adjust_luminance = "light",
    effects_adjust_blur = "blur",
    effects_adjust_distortion = "shape",
    effects_adjust_range = "range",
    effects_adjust_horizontal_chromatic = "color_x",
    effects_adjust_vertical_chromatic = "color_y",
    effects_adjust_horizontal_shift = "shift_x",
    effects_adjust_vertical_shift = "shift_y",
    effects_adjust_number = "count",
    effects_adjust_size = "scale",
    effects_adjust_size = "intensity",
    effects_adjust_rotate = "angle",
    effects_adjust_color = "color",
    effects_adjust_background_animation = "animate",
    sticker = "alpha"
}

local exports = exports or {}
local SeekModeScript = SeekModeScript or {}
SeekModeScript.__index = SeekModeScript

function SeekModeScript.new (construct, ...)
    local self = setmetatable({}, SeekModeScript)
    self.w = 0
    self.h = 0
    self.startTime = 0.0
    self.endTime = 3.0
    self.curTime = 0.0
    self.data = {}
    self.main = CCMain.new(self, self.data)
    return self
end

function SeekModeScript:onStart (comp)
    self.w = Amaz.BuiltinObject.getInputTextureWidth()
    self.h = Amaz.BuiltinObject.getInputTextureHeight()
    self.main:create(self, self.data, comp.entity.scene)
    self.main:layout(self, self.data, self.w, self.h)
    self.main:update(self, self.data, 0, self.endTime, 0)
end

function SeekModeScript:onUpdate (comp, dt)
    local w = Amaz.BuiltinObject.getInputTextureWidth()
    local h = Amaz.BuiltinObject.getInputTextureHeight()
    if w ~= self.w or h ~= self.h then
        self.w = w
        self.h = h
        self.main:layout(self, self.data, w, h)
    end
    local T = self.endTime - self.startTime
    local t = self.curTime - self.startTime
    ---#ifndef DEV
    self.main:update(self, self.data, t, T, t / T)
    ---#else
--//    if self.dev_seek then
--//        self.main:update(self, self.data, self.dev_seek * T, T, self.dev_seek)
--//    else
--//        self.main:update(self, self.data, t, T, t / T)
--//    end
--//    if Editor then
--//        self.curTime = self.curTime + dt
--//    end
    ---#endif
end

function SeekModeScript:onEvent (comp, event)
    local key = event.args:get(0)
    if type(key) == "string" then
        local data = self.data
        local name = CCHandlers[key]
        if name then
            data[name] = event.args:get(1)
            return
        end
    end
    ---#ifdef DEV
--//    if event.type == Amaz.EventType.TOUCH then
--//        if key.type == Amaz.TouchType.TOUCH_BEGAN then
--//            self.dev_seek = key.x
--//        elseif key.type == Amaz.TouchType.TOUCH_MOVED then
--//            self.dev_seek = key.x
--//        elseif key.type == Amaz.TouchType.TOUCH_ENDED or key.type == Amaz.TouchType.TOUCH_CANCELLED then
--//            if key.y > 0.9 then
--//                self.curTime = self.startTime + (self.endTime - self.startTime) * self.dev_seek
--//                self.dev_seek = nil
--//            end
--//        end
--//    end
    ---#endif
end

exports.SeekModeScript = SeekModeScript
return exports
