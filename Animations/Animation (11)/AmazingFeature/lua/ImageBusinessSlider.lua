--write by editor  EffectSDK:10.5.0 EngineVersion:10.66.0 EditorBuildTime:Dec__7_2021_12_06_29
--sliderVersion: 20210901  Lua generation date: Fri Dec 31 14:14:56 2021


local exports = exports or {}
local ImageBusinessSlider = ImageBusinessSlider or {}
ImageBusinessSlider.__index = ImageBusinessSlider


function ImageBusinessSlider.new(construct, ...)
    local self = setmetatable({}, ImageBusinessSlider)
    if construct and ImageBusinessSlider.constructor then
        ImageBusinessSlider.constructor(self, ...)
    end
    return self
end


local function remap(x, a, b)
    return x * (b - a) + a
end


function ImageBusinessSlider:onStart(sys)
    self.Pass0Material0 = sys.scene:findEntityBy("Pass0"):getComponent("Renderer").material
end


function ImageBusinessSlider:onEvent(sys,event)
    if event.args:get(0) == "effects_adjust_luminance" then
        local intensity = event.args:get(1)
        self.Pass0Material0["lightIns"] = remap(intensity,1,2)
    end
    if event.args:get(0) == "effects_adjust_intensity" then
        local intensity = event.args:get(1)
        self.Pass0Material0["scale"] = remap(intensity,1,0.75)
    end
    if event.args:get(0) == "effects_adjust_filter" then
        local intensity = event.args:get(1)
        self.Pass0Material0["filterHow"] = remap(intensity,0,1)
    end
    if event.args:get(0) == "effects_adjust_range" then
        local intensity = event.args:get(1)
        self.Pass0Material0["shakeMask"] = remap(intensity,0.1,0.5)
    end
end


exports.ImageBusinessSlider = ImageBusinessSlider
return exports