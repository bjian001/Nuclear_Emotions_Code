local exports = exports or {}
local Contrast = Contrast or {}
Contrast.__index = Contrast
---@class Contrast : ScriptComponent
---@field intensity double [UI(Range={-1, 1}, Drag)]
---@field InputTex Texture
---@field OutputTex Texture

function Contrast.new(construct, ...)
    local self = setmetatable({}, Contrast)
    if construct and Contrast.constructor then
        Contrast.constructor(self, ...)
    end
    self.startTime = 0.0
    self.endTime = 3.0
    self.curTime = 0.0
    return self
end

function Contrast:constructor()
end

function Contrast:onUpdate(comp, detalTime)
    self:seekToTime(comp, self.curTime - self.startTime)
end

function Contrast:start(comp)
    self.first = true
    self.camera = comp.entity:searchEntity("Camera_entity"):getComponent("Camera")
    self.material = comp.entity:searchEntity("FliterEntity-2FFE6ABD"):getComponent("MeshRenderer").material
end

function Contrast:onStart(comp)
    self:start(comp)
end

local function remap(dmin, dmax, value)
    return value * (dmax - dmin) + dmin
end

function Contrast:seekToTime(comp, time)
    if self.first == nil then
        self:start(comp)
    end

    self.camera.renderTexture = self.OutputTex
    self.material:setTex("inputImageTexture", self.InputTex)

    local intensity = self.intensity * 0.5 + 0.5;
    -- if intensity >= 0.5 then
    --     self.material:setFloat("saturation", remap(1.0, 1.48, (intensity - 0.5) / 0.5))
    --     self.material:setFloat("center", 0.5 + 0.001)
    --     self.material:setFloat("sParamR", 0.24)
    --     self.material:setFloat("sParamG", 0.14)
    --     self.material:setFloat("sParamB", 0.17)
    -- else
    --     self.material:setFloat("saturation", remap(0.65, 1.0, intensity / 0.5))
    --     self.material:setFloat("center", 0.44 + 0.001)
    --     self.material:setFloat("sParamR", 0)
    --     self.material:setFloat("sParamG", 0)
    --     self.material:setFloat("sParamB", 0)
    -- end
end

exports.Contrast = Contrast
return exports
