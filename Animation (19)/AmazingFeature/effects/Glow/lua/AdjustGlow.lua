---@class AdjustGlow: ScriptComponent
----@field threshold double [UI(Range={0, 1}, Slider)]
----@field radius double [UI(Range={0, 100}, Slider)]
----@field intensity double [UI(Range={0, 4}, Slider)]
----@field ColorA Vector3f [UI(Drag=1)]
----@field ColorB Vector3f [UI(Drag=1)]
----@field GlowColor string [UI(Option={"Original","A&B"})]
----@field ColorLoopMode string [UI(Option={"AB","ABA"})]

local exports = exports or {}
local AdjustGlow = AdjustGlow or {}
AdjustGlow.__index = AdjustGlow

function AdjustGlow.new(construct, ...)
    local self = setmetatable({}, AdjustGlow)

    if construct and AdjustGlow.constructor then AdjustGlow.constructor(self, ...) end
    self.threshold = .6
    self.radius = 10.
    self.intensity = 1.
    self.ColorA = Amaz.Vector3f(255., 255., 255.)
    self.ColorA = Amaz.Vector3f(0., 0., 0.)
    self.GlowColor = "Original"
    self.ColorLoopMode = "AB"
    return self
end

function AdjustGlow:constructor()
end

function AdjustGlow:onStart(comp)
    self.matHighlight = comp.entity.scene:findEntityBy("PassHighlight"):getComponent("MeshRenderer").material
    self.matHorzBlur = comp.entity.scene:findEntityBy("PassHorzBlur1"):getComponent("MeshRenderer").material
    self.matVertBlur = comp.entity.scene:findEntityBy("PassVertBlur1"):getComponent("MeshRenderer").material
    self.matOutput = comp.entity.scene:findEntityBy("PassOutput"):getComponent("MeshRenderer").material
    self.camHorzBlur = comp.entity.scene:findEntityBy("CameraHorzBlur"):getComponent("Camera")
    self.camVertBlur = comp.entity.scene:findEntityBy("CameraVertBlur"):getComponent("Camera")
end

function AdjustGlow:onUpdate(comp, deltaTime)
    local props = comp.entity:getComponent("ScriptComponent").properties
    if props:has("threshold") then
        self.threshold = props:get("threshold")
    end
    if props:has("radius") then
        self.radius = props:get("radius")
    end
    if props:has("intensity") then
        self.intensity = props:get("intensity")
    end
    if props:has("ColorA") then
        self.ColorA = props:get("ColorA")
    end
    if props:has("ColorB") then
        self.ColorB = props:get("ColorB")
    end
    if props:has("GlowColor") then
        self.GlowColor = props:get("GlowColor")
    end
    if props:has("ColorLoopMode") then
        self.ColorLoopMode = props:get("ColorLoopMode")
    end
    self.matHighlight:setFloat("threshold", self.threshold)
    
    local blurDegree = self.radius / 100    -- 100: the max blur radius
    local w = Amaz.BuiltinObject:getInputTextureWidth()
    local h = Amaz.BuiltinObject:getInputTextureHeight()
    self.camHorzBlur.renderTexture.width = w * (1. - blurDegree * 0.9)
    self.camHorzBlur.renderTexture.height = h * (1. - blurDegree * 0.9)
    self.camVertBlur.renderTexture.width = w * (1. - blurDegree * 0.9)
    self.camVertBlur.renderTexture.height = h * (1. - blurDegree * 0.9)
    self.matHorzBlur:setFloat("horzR", self.radius * (1. - blurDegree * 0.9))
    self.matVertBlur:setFloat("vertR", self.radius * (1. - blurDegree * 0.9))
    -- self.matVertBlur:setFloat("intensity", self.intensity)
    -- self.matVertBlur:setVec3("ColorA", self.ColorA / 255.)
    -- self.matVertBlur:setVec3("ColorB", self.ColorB / 255.)
    self.matOutput:setFloat("intensity", self.intensity)
    self.matOutput:setVec3("ColorA", self.ColorA / 255.)
    self.matOutput:setVec3("ColorB", self.ColorB / 255.)
    local flagGlowColor = 0
    if self.GlowColor == "Original" then
        flagGlowColor = 0
    elseif self.ColorLoopMode == "AB" then
        flagGlowColor = 1
    else
        flagGlowColor = 2
        -- Amaz.LOGI("ldrldr========>value", flagGlowColor)
    end
    self.matHighlight:setFloat("flagGlowColor", flagGlowColor)
    -- self.matVertBlur:setFloat("flagGlowColor", flagGlowColor)
    self.matOutput:setFloat("flagGlowColor", flagGlowColor)
end

exports.AdjustGlow = AdjustGlow
return exports
