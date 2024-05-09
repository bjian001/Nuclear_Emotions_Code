local exports = exports or {}
local GaussianBlurLayerScript = GaussianBlurLayerScript or {}

---@class GaussianBlurLayerScript : ScriptComponent
---@field intensity number
---@field steps number
---@field Blurred_Direction string[UI(Option={"Horizontal and Vertical", "Horizontal", "Vertical"})]
---@field MidTex Texture
---@field InputTex Texture
---@field OutputTex Texture
GaussianBlurLayerScript.__index = GaussianBlurLayerScript

function GaussianBlurLayerScript.new()
    local self = {}
    setmetatable(self, GaussianBlurLayerScript)
    self.intensity = 0.0
    self.steps = 1
    self.Blurred_Direction = "Horizontal and Vertical"
    self.transform = {}
    self.MidTex = nil
    self.InputTex = nil
    self.OutputTex = nil
    return self
end

---@param comp Component
function GaussianBlurLayerScript:onStart(comp)
    self.HorizontalBlurMat = comp.entity:searchEntity("Horizontal_Blur"):getComponent("MeshRenderer").material
    self.VerticalBlurMat = comp.entity:searchEntity("Vertical_Blur"):getComponent("MeshRenderer").material

    self.hori_cam = comp.entity:searchEntity("Camera_Horizontal_Blur"):getComponent("Camera")
    self.vert_cam = comp.entity:searchEntity("Camera_Vertical_Blur"):getComponent("Camera")
    self.prop = comp.properties
end

---@param comp Component
---@param deltaTime number
function GaussianBlurLayerScript:onUpdate(comp, deltaTime)
    local w = Amaz.BuiltinObject:getInputTextureWidth()
    local h = Amaz.BuiltinObject:getInputTextureHeight()
    self.HorizontalBlurMat:setFloat("width", w)
    self.HorizontalBlurMat:setFloat("height", h)
    self.VerticalBlurMat:setFloat("width", w)
    self.VerticalBlurMat:setFloat("height", h)
    self.intensity = self.prop:get("intensity")
    local intensity = math.max(self.intensity, 0.0)
    self.HorizontalBlurMat:setFloat("u_Sample", math.floor(intensity))
    self.VerticalBlurMat:setFloat("u_Sample", math.floor(intensity))
    self.HorizontalBlurMat:setFloat("u_Steps", self.steps)
    self.VerticalBlurMat:setFloat("u_Steps", self.steps)
    
    if self.Blurred_Direction == "Horizontal" then
        -- self.VerticalBlurMat:enableMacro("GLOWSAMPLE", 0)
        self.vert_cam.entity.visible = false
        self.hori_cam.entity.visible = true

        self.HorizontalBlurMat:setTex("u_InputTex", self.InputTex)
        self.hori_cam.renderTexture = self.OutputTex
    elseif self.Blurred_Direction == "Vertical" then
        -- self.HorizontalBlurMat:enableMacro("GLOWSAMPLE", 0)
        self.vert_cam.entity.visible = true
        self.hori_cam.entity.visible = false

        self.VerticalBlurMat:setTex("u_InputTex", self.InputTex)
        self.vert_cam.renderTexture = self.OutputTex
    
    else
        self.vert_cam.entity.visible = true
        self.hori_cam.entity.visible = true

        self.HorizontalBlurMat:setTex("u_InputTex", self.InputTex)
        self.hori_cam.renderTexture = self.MidTex
        self.VerticalBlurMat:setTex("u_InputTex", self.MidTex)
        self.vert_cam.renderTexture = self.OutputTex

    end
    self.hori_cam.renderTexture.pecentX = 1. - intensity / 50.
    self.hori_cam.renderTexture.pecentY = 1. - intensity / 50.
    self.vert_cam.renderTexture.pecentX = 1. - intensity / 50.
    self.vert_cam.renderTexture.pecentY = 1. - intensity / 50.
end

exports.GaussianBlurLayerScript = GaussianBlurLayerScript
return exports
