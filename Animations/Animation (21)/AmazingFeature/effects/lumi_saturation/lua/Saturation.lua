local exports = exports or {}
local Saturation = Saturation or {}
Saturation.__index = Saturation
---@class Saturation : ScriptComponent
---@field intensity double
---@field InputTex Texture
---@field OutputTex Texture

function Saturation.new(construct, ...)
    local self = setmetatable({}, Saturation)
    if construct and Saturation.constructor then
        Saturation.constructor(self, ...)
    end

    self.InputTex = nil
    self.OutputTex = nil
    self.intensity = 0

    return self
end

function Saturation:constructor()
end

function Saturation:onStart(comp)
    self.camera = comp.entity:searchEntity("Camera_entity"):getComponent("Camera")
    self.material = comp.entity:searchEntity("Sat"):getComponent("MeshRenderer").material
end

function Saturation:onUpdate(comp, detalTime)
    self.camera.renderTexture = self.OutputTex
    self.material:setTex("u_albedo", self.InputTex)

    local intensity = (self.intensity * 0.5 + 0.5) * 100
    --self.material:setFloat("sat", intensity)
end

exports.Saturation = Saturation
return exports
