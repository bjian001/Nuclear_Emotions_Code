local exports = exports or {}
local GaussianBlurLayerScript = GaussianBlurLayerScript or {}

---@class GaussianBlurLayerScript : ScriptComponent
---@field Intensity number
---@field Blurred_Direction string[UI(Option={"Horizontal and Vertical", "Horizontal", "Vertical"})]
GaussianBlurLayerScript.__index = GaussianBlurLayerScript

function GaussianBlurLayerScript.new()
    local self = {}
    setmetatable(self, GaussianBlurLayerScript)
    self.Intensity = 0.0
    self.Blurred_Direction = "Horizontal and Vertical"
    self.transform = {}
    return self
end

---@param comp Component
function GaussianBlurLayerScript:onStart(comp)
    self.HorizontalBlurMat = comp.entity.scene:findEntityBy("Horizontal_Blur"):getComponent("MeshRenderer").material
    self.VerticalBlurMat = comp.entity.scene:findEntityBy("Vertical_Blur"):getComponent("MeshRenderer").material
end

---@param comp Component
---@param deltaTime number
function GaussianBlurLayerScript:onUpdate(comp, deltaTime)
    self.HorizontalBlurMat:setFloat("u_Strength", self.Intensity)
    self.VerticalBlurMat:setFloat("u_Strength", self.Intensity)
    if self.Blurred_Direction == "Horizontal" then
        self.VerticalBlurMat:setFloat("u_Strength", 0.0)
    end
    if self.Blurred_Direction == "Vertical" then
        self.HorizontalBlurMat:setFloat("u_Strength", 0.0)
    end
end

---@param comp Component
---@param event Event
function GaussianBlurLayerScript:onEvent(comp, event)
end

exports.GaussianBlurLayerScript = GaussianBlurLayerScript
return exports
