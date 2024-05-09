
local exports = exports or {}
local exposure_script = exposure_script or {}

---@class exposure_script : ScriptComponent
---@field exposure number
---@field offset number
---@field grayscale_correct number
---@field no_use_linear_light boolean
exposure_script.__index = exposure_script

function exposure_script.new()
    local self = {}
    setmetatable(self, exposure_script)
    self.exposure = 0
    self.offset = 0
    self.grayscale_correct = 1
    self.first = nil
    self.no_use_linear_light = false
    return self
end

---@param comp Component
function exposure_script:onStart(comp)
end

function exposure_script:start(comp)
    self.exposure_mat = comp.entity:searchEntity("Exposure"):getComponent("MeshRenderer").material
end

---@param comp Component
---@param deltaTime number
function exposure_script:onUpdate(comp, deltaTime)
    if self.first == nil then
        self.first = true
        self:start(comp)
    end
    self.exposure_mat:setFloat("u_Intensity", self.exposure)
    self.exposure_mat:setFloat("u_Offset", self.offset)
    self.exposure_mat:setFloat("u_GrayscaleCorrect", self.grayscale_correct)
    if self.no_use_linear_light then
        self.exposure_mat:setFloat("use_linear_light", 1.0)
    else
        self.exposure_mat:setFloat("use_linear_light", 0.0)
    end
end

---@param comp Component
---@param event Event
function exposure_script:onEvent(comp, event)
    if self.first == nil then
        self.first = true
        self:start(comp)
    end
    
    if event.type == Amaz.AppEventType.SetEffectIntensity then
        local intensity = event.args:get(1)
        if ("exposure" == event.args:get(0)) then
            self.exposure = intensity
        elseif ("offset" == event.args:get(0)) then
            self.offset = intensity
        elseif ("grayscale_correct" == event.args:get(0)) then
            self.grayscale_correct = intensity
        elseif ("no_use_linear_light" == event.args:get(0)) then
            if intensity == 0 then
                self.no_use_linear_light = false
            else
                self.no_use_linear_light = true
            end

        end
    end
end

exports.exposure_script = exposure_script
return exports
