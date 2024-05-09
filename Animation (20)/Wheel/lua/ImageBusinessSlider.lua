--write by editor  EffectSDK:13.6.0 EngineVersion:13.6.0 EditorBuildTime:Mar_23_2023_00_42_43
--sliderVersion: 20210901  Lua generation date: Fri Aug 11 15:03:38 2023


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
    self.resultMaterial0 = sys.scene:findEntityBy("result"):getComponent("Renderer").material
end


function ImageBusinessSlider:onEvent(sys,event)
    if event.args:get(0) == "effects_adjust_speed" then
        local intensity = event.args:get(1)
        self.resultMaterial0["u_speed"] = remap(intensity,0.5,2)
    end
    if event.args:get(0) == "effects_adjust_intensity" then
        local intensity = event.args:get(1)
        self.resultMaterial0["u_intensity"] = remap(intensity,0,1)
    end
    if event.args:get(0) == "effects_adjust_color" then
        local intensity = event.args:get(1)
        self.resultMaterial0["u_hueChange"] = remap(intensity,0,1)
    end
end


exports.ImageBusinessSlider = ImageBusinessSlider
return exports