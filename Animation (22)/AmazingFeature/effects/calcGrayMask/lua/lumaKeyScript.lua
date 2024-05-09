

local exports = exports or {}
local lumaKeyScript = lumaKeyScript or {}

---@class lumaKeyScript : ScriptComponent
---@field threshold number
---@field smoothEdge number
---@field lightCut Bool
lumaKeyScript.__index = lumaKeyScript

function lumaKeyScript.new()
    local self = {}
    setmetatable(self, lumaKeyScript)
    self.threshold = 0
    self.smoothEdge = 0
    return self
end

---@param comp Component
function lumaKeyScript:onStart(comp)
    local findEntityInScene = function(name)
        return comp.entity:searchEntity(name)
    end
    local getEntityMaterial = function(name)
        return findEntityInScene(name):getComponent("MeshRenderer").material
    end
    local getEntityScript = function(name)
        return findEntityInScene(name):getComponent("ScriptComponent")
    end

    self.calcGrayMaterial = getEntityMaterial("Calc_Gray")

    self.gaussianBlurScript = getEntityScript("Gaussian_Blur_Root")
    self.first = true
end
local getLuaObj = function(script_component)
    return Amaz.ScriptUtils.getLuaObj(script_component:getScript())
end
---@param comp Component
---@param deltaTime number
function lumaKeyScript:onUpdate(comp, deltaTime)
    -- Amaz.LOGE("lumaKeyScript", "onUpdate")
    local prop = comp.properties
    if self.first == true then
        self.propGaussianBlurScript = comp.entity:searchEntity("Gaussian_Blur_Root"):getComponent("ScriptComponent").properties
        self.first = false
    end
    -- self.gaussianBlurScript.intensity = self.smoothEdge * 0.5
    self.propGaussianBlurScript:set("intensity", self.smoothEdge * 1.)
    self.threshold = prop:get("threshold")
    self.calcGrayMaterial:setFloat("u_Threshold", self.threshold)
    self.lightCut = prop:get("lightCut")
    self.calcGrayMaterial:setFloat("lightCut", (self.lightCut and 1 or 0))
end

---@param comp Component
---@param event Event
function lumaKeyScript:onEvent(comp, event)
end

exports.lumaKeyScript = lumaKeyScript
return exports
