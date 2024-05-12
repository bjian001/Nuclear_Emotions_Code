local exports = exports or {}
local Grain = Grain or {}
Grain.__index = Grain
---@class Grain: ScriptComponent
---@field center Vector2f [UI(Drag)]
---@field size Vector2f [UI(Drag)]
---@field borderWidth double [UI(Range={0, 50}, Drag)]
---@field curTime double
---@field borderColor Color [UI(NoAlpha)]
---@field combine string [UI(Option={"Screen", "Add", "Mult", "Overlay", "Film", "Difference"})]
---@field brightness double [UI(Range={-1, 1}, Drag)]
---@field contrast double [UI(Range={-1, 1}, Drag)]
---@field saturation double [UI(Range={0, 10}, Drag)]
---@field intensity double [UI(Range={0, 10}, Drag)]
---@field intensityR double [UI(Range={0, 10}, Drag)]
---@field intensityG double [UI(Range={0, 10}, Drag)]
---@field intensityB double [UI(Range={0, 10}, Drag)]
---@field scale double [UI(Range={0.22, 1}, Drag)]
---@field scaleR double [UI(Range={0.2, 1}, Drag)]
---@field scaleG double [UI(Range={0.2, 1}, Drag)]
---@field scaleB double [UI(Range={0.2, 1}, Drag)]
---@field monochrome Bool
---@field InputTex Texture
---@field OutputTex Texture

local Combine = {
    Screen = 0, Add = 1, Mult = 2, Overlay = 3, Film = 4, Difference = 5
}

local function rangeMapper(value, srcMin, srcMax, dstMin, dstMax)
    return  (value - srcMin) * (dstMax - dstMin) / (srcMax - srcMin) + dstMin
end

function Grain.new(construct, ...)
    local self = setmetatable({}, Grain)

    if construct and Grain.constructor then Grain.constructor(self, ...) end

    self.InputTex = nil
    self.OutputTex = nil

    self.center = Amaz.Vector2f(0.5, 0.5)
    self.size = Amaz.Vector2f(0.5, 0.5)
    self.borderWidth = 5.0 -- pixel
    self.borderColor = Amaz.Color(1., 1., 1.)
    self.combine = 'Film'
    self.intensity = 1.0
    self.intensityR = 1.0
    self.intensityG = 1.0
    self.intensityB = 1.0
    self.scale = 0.3
    self.scaleR = 1
    self.scaleG = 1
    self.scaleB = 1
    self.monochrome = false
    self.curTime = 0.0

    return self
end

function Grain:constructor()
end

function Grain:onStart(comp)
    self.noiseMat = comp.entity:searchEntity('NoisePass'):getComponent('MeshRenderer').material
    self.noiseCam = comp.entity:searchEntity('NoiseCamera'):getComponent('Camera')
end

local function clamp(val, min, max)
    return math.max(math.min(val, max), min)
end

function Grain:setEffectAttr(key, value, comp)
    local function _setEffectAttr(_key, _value)
        if self[_key] ~= nil then
            self[_key] = _value
            if comp and comp.properties ~= nil then
                comp.properties:set(_key, _value)
            end
        end
    end

    if key == "combine" then
        local combine = "Screen"
        if     value == 1 then combine = "Add"
        elseif value == 2 then combine = "Mult"
        elseif value == 3 then combine = "Overlay"
        elseif value == 4 then combine = "Film"
        end
        _setEffectAttr(key, combine)
    elseif key == "center" or key == "size" then
        local pt2 = self[key]
        if pt2 then
            pt2.x = clamp(value:get(0), 0.0, 1.0)
            pt2.y = clamp(value:get(1), 0.0, 1.0)
            _setEffectAttr(key, pt2)
        end
    else
        _setEffectAttr(key, value)
    end
end

function Grain:onUpdate(comp, deltaTime)
    local props = comp.properties
    self.curTime = props:get("curTime")
    local curTime = self.curTime * 1000
    local seed = curTime % 100
    self.noiseMat:setFloat('u_seed', seed)

    self.noiseMat:setTex("u_InputTexture", self.InputTex)
    self.noiseCam.renderTexture = self.OutputTex

    local w = Amaz.BuiltinObject:getInputTextureWidth()
    local h = Amaz.BuiltinObject:getInputTextureHeight()

    self.noiseMat:setFloat("width", w)
    self.noiseMat:setFloat("height", h)

    self.noiseMat:setFloat('u_intensity', self.intensity / 10)
    self.noiseMat:setFloat('u_intensityR', self.intensityR / 10)
    self.noiseMat:setFloat('u_intensityG', self.intensityG / 10)
    self.noiseMat:setFloat('u_intensityB', self.intensityB / 10)
    self.noiseMat:setFloat('u_scale', self.scale)
    self.noiseMat:setFloat('u_scaleR', self.scaleR)
    self.noiseMat:setFloat('u_scaleG', self.scaleG)
    self.noiseMat:setFloat('u_scaleB', self.scaleB)
    self.noiseMat:setInt('u_monochrome', (self.monochrome and {1} or {0})[1])
    self.noiseMat:setFloat('u_Brightness', self.brightness)
    self.noiseMat:setFloat('u_Contrast', self.contrast)
    self.noiseMat:setFloat('u_Saturation', self.saturation)
    
    self.noiseMat:setVec2('u_center', self.center)
    self.noiseMat:setVec2('u_size', self.size)
    self.noiseMat:setFloat('u_borderWidth', self.borderWidth)
    self.noiseMat:setVec3('u_borderColor', Amaz.Vector3f(self.borderColor.r, self.borderColor.g, self.borderColor.b))
    self.noiseMat:setInt('u_combine', Combine[self.combine])
end

exports.Grain = Grain
return exports
