local exports = exports or {}
local TurbulenceDisplacement = TurbulenceDisplacement or {}
TurbulenceDisplacement.__index = TurbulenceDisplacement
---@class TurbulenceDisplacement : ScriptComponent
---@field size number
---@field quantity number
---@field complexity number
---@field evolution number
---@field cycle number
---@field offset_x number
---@field offset_y number
---@field type number
---@field fix_type number
---@field picture_scale number
---@field motion_tile_type number
---@field InputTex Texture
---@field OutputTex Texture

function TurbulenceDisplacement.new(construct, ...)
    local self = setmetatable({}, TurbulenceDisplacement)
    if construct and TurbulenceDisplacement.constructor then
        TurbulenceDisplacement.constructor(self, ...)
    end

    self.InputTex = nil
    self.OutputTex = nil

    self.size = 0
    self.quantity = 2
    self.complexity = 1
    self.evolution = 0
    self.cycle = 100
    self.offset_x = 0
    self.offset_y = 0
    self.type = 0
    self.fix_type = 0
    self.motion_tile_type = 0
    self.picture_scale = 1

    return self
end

function TurbulenceDisplacement:constructor()
end

function TurbulenceDisplacement:onUpdate(comp, detalTime)
    if self.first == nil then
        self:start(comp)
    end
    self.camera.renderTexture = self.OutputTex
    self.size = self.prop:get("size")
    self.evolution = self.prop:get("evolution")
    self.material:setTex("inputImageTexture", self.InputTex)
    self.material:setFloat("u_Contrast", self.size);
    self.material:setVec2("u_Scale", Amaz.Vector2f(self.quantity, self.quantity));
    self.material:setFloat("u_Complexity", self.complexity);
    self.material:setFloat("u_Evolution", math.abs(self.evolution) / 120.0);
    self.material:setFloat("u_Cycle", math.max(2, math.floor(self.cycle*3.0 + 0.5)));
    self.material:setVec2("u_Offset", Amaz.Vector2f(self.offset_x, self.offset_y))
    self.material:setFloat("u_type", self.type);
    self.material:setFloat("u_fix_type", self.fix_type)
    self.material:setFloat("motion_tile_type", self.motion_tile_type)
    self.material:setFloat("picture_scale", self.picture_scale)

end

function TurbulenceDisplacement:onStart(comp)
    self:start(comp)
end

function TurbulenceDisplacement:start(comp)
    self.first = true
    self.camera = comp.entity:searchEntity("cam_Displacement"):getComponent("Camera")
    self.material = comp.entity:searchEntity("Displacement"):getComponent("MeshRenderer").material
    self.prop = comp.properties
end

exports.TurbulenceDisplacement = TurbulenceDisplacement
return exports
