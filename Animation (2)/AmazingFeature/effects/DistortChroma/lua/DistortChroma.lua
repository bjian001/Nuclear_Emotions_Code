      
local isEditor = (Amaz.Macros and Amaz.Macros.EditorSDK) and true or false
local exports = exports or {}
local DistortChroma = DistortChroma or {}
DistortChroma.__index = DistortChroma
---@class DistortChroma : ScriptComponent
---@field InputTex Texture
---@field OutputTex Texture
---@field amount double [UI(Range={-2, 2}, Slider)]
---@field angle double [UI(Range={-180, 180}, Slider)]

function DistortChroma.new(construct, ...)
    local self = setmetatable({}, DistortChroma)

    if construct and DistortChroma.constructor then DistortChroma.constructor(self, ...) end

    self.InputTex = nil
    self.OutputTex = nil
    self.amount = 1.
    self.curTime = 0.
    self.startTime = 0.
    self.__lumi_type = "lumi_effect"
    self.first = true
    return self
end

function DistortChroma:constructor()
end

function DistortChroma:onStart(comp)
    self.camera = comp.entity:searchEntity("CameraDistortChroma"):getComponent("Camera")
    self.matDistortChroma = comp.entity:searchEntity("PassDistortChroma"):getComponent("MeshRenderer").material
    self.matGradient = comp.entity:searchEntity("PassGradient"):getComponent("MeshRenderer").material
    self.prop = comp.properties
end

function DistortChroma:onUpdate(comp, deltaTime)
    local w = Amaz.BuiltinObject.getInputTextureWidth()
    local h = Amaz.BuiltinObject.getInputTextureHeight()
    if self.first == true then
        local scriptGaussianBlur = comp.entity:searchEntity("Gaussian_Blur_Root_Distort_Chroma"):getComponent("ScriptComponent")
        self.scriptGaussianBlur = Amaz.ScriptUtils.getLuaObj(scriptGaussianBlur:getScript())
        self.first = false
    end
    if self.OutputTex then
        self.camera.renderTexture = self.OutputTex
    end
    self.matDistortChroma:setTex("u_albedo", self.InputTex)
    self.matGradient:setTex("u_albedo", self.InputTex)
    self.matDistortChroma:setFloat("sizeIntensity", self.prop:get("amount") * 100.)
    self.matDistortChroma:setFloat("u_angle", self.prop:get("angle"))
    self.matDistortChroma:setFloat("width", w)
    self.matDistortChroma:setFloat("height", h)
    -- if math.abs(self.amount * 100.) < .001 then
    --     self.scriptGaussianBlur.Intensity = 0.
    -- else
        self.scriptGaussianBlur.Intensity = 20.
    -- end
end

function DistortChroma:setEffectAttr(key, value, comp)
    local function _setEffectAttr(_key, _value)
        if self[_key] ~= nil then
            self[_key] = _value
            if comp and comp.properties ~= nil then
                comp.properties:set(_key, _value)
            end
        end
    end

    if key == "Amount" then
        _setEffectAttr("amount", value)
    else
        _setEffectAttr(key, value)
    end

end

exports.DistortChroma = DistortChroma
return exports
