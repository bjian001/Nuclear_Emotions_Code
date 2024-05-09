--write by editor  EffectSDK:14.0.0 EngineVersion:14.0.0 EditorBuildTime:May_17_2023_10_47_46
--sliderVersion: 20210901  Lua generation date: Tue Jun 20 19:45:30 2023


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
    self.lightMaterial0 = sys.scene:findEntityBy("light"):getComponent("Renderer").material
end


function ImageBusinessSlider:onEvent(sys,event)
    if event.args:get(0) == "effects_adjust_color" then
        local intensity = event.args:get(1)
        self.lightMaterial0["u_color"] = remap(intensity,0,1)
    end
end


exports.ImageBusinessSlider = ImageBusinessSlider
return exports