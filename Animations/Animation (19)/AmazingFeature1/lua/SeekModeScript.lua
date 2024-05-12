--@input float curTime = 0.0{"widget":"slider","min":0,"max":3.0}
--@input float threshold1 = 0.7{"widget":"slider","min":0,"max":1.0}
--@input float threshold2 = 1.0{"widget":"slider","min":0,"max":1.0}
--@input float intensity = 0.0{"widget":"slider","min":0,"max":1.0}
--@input float angle = 5.0{"widget":"slider","min":0.1,"max":10.0}

local exports = exports or {}
local SeekModeScript = SeekModeScript or {}
SeekModeScript.__index = SeekModeScript
function SeekModeScript.new(construct, ...)
    local self = setmetatable({}, SeekModeScript)
    if construct and SeekModeScript.constructor then SeekModeScript.constructor(self, ...) end
    self.startTime = 0.0
    self.endTime = 3.0
    self.curTime = 0.0
    self.width = 0
    self.height = 0
    self.intensity = 1
    self.filterIntensity = 1
    self.rotateIntensity = 4
    return self
end

function SeekModeScript:constructor()

end

function SeekModeScript:onUpdate(comp, detalTime)
    -- test
    -- local props = comp.entity:getComponent("ScriptComponent").properties
    -- if props:has("curTime") then
    --     self:seekToTime(comp, props:get("curTime") - self.startTime)
    -- end
    -- real
    self:seekToTime(comp, self.curTime - self.startTime)
end

function SeekModeScript:start(comp)
    self.props = comp.properties
    self.GaussX_1Material = comp.entity.scene:findEntityBy("GaussX_1"):getComponent("MeshRenderer").material
    self.GaussY_1Material = comp.entity.scene:findEntityBy("GaussY_1"):getComponent("MeshRenderer").material
    self.GaussX_2Material = comp.entity.scene:findEntityBy("GaussX_2"):getComponent("MeshRenderer").material
    self.GaussY_2Material = comp.entity.scene:findEntityBy("GaussY_2"):getComponent("MeshRenderer").material
    self.kiraXMaterial = comp.entity.scene:findEntityBy("SeekModeScript"):getComponent("MeshRenderer").material
    self.kiraX_2Material = comp.entity.scene:findEntityBy("kiraX_2"):getComponent("MeshRenderer").material
    self.highlightMaterial = comp.entity.scene:findEntityBy("Highlight"):getComponent("MeshRenderer").material
    self.finalMaterial = comp.entity.scene:findEntityBy("final"):getComponent("MeshRenderer").material
    self.filterMaterial = comp.entity.scene:findEntityBy("filter"):getComponent("MeshRenderer").material
    self.kiraX_1Camera = comp.entity.scene:findEntityBy("Camera_kiraX_1"):getComponent("Camera")
    self.combCamera = comp.entity.scene:findEntityBy("Camera_comb"):getComponent("Camera")
    self.GaussX_1Camera = comp.entity.scene:findEntityBy("Camera_GaussX_1"):getComponent("Camera")
    self.GaussY_1Camera = comp.entity.scene:findEntityBy("Camera_GaussY_1"):getComponent("Camera")
    self.GaussX_2Camera = comp.entity.scene:findEntityBy("Camera_GaussX_2"):getComponent("Camera")
    self.GaussY_2Camera = comp.entity.scene:findEntityBy("Camera_GaussY_2"):getComponent("Camera")
    self.kiraXMaterial:setFloat("angleVal", self.props:find("angle"))
    self.kiraX_2Material:setFloat("angleVal", self.props:find("angle"))
    self.highlightMaterial:setFloat("threshold1", self.props:find("threshold1"))
    self.highlightMaterial:setFloat("threshold2", self.props:find("threshold2"))
    self.GaussY_2Material:setFloat("intensity", self.props:find("intensity"))
end

function SeekModeScript:seekToTime(comp, time)
    if self.first == nil then
        self.first = true
        self:start(comp)
    end
    -- Amaz.LOGI("time", time)
    local w = Amaz.BuiltinObject:getInputTextureWidth()
    local h = Amaz.BuiltinObject:getInputTextureHeight()
    if w ~= self.width or h ~= self.height then
        self.width = w
        self.height = h
        self.GaussX_1Material["inputWidth"] = self.width
        self.GaussX_1Material["inputHeight"] = self.height
        self.GaussY_1Material["inputWidth"] = self.width
        self.GaussY_1Material["inputHeight"] = self.height
        self.GaussX_2Material["inputWidth"] = self.width
        self.GaussX_2Material["inputHeight"] = self.height
        self.GaussY_2Material["inputWidth"] = self.width
        self.GaussY_2Material["inputHeight"] = self.height
        self.kiraXMaterial["inputWidth"] = self.width
        self.kiraXMaterial["inputHeight"] = self.height
        self.kiraX_2Material["inputWidth"] = self.width
        self.kiraX_2Material["inputHeight"] = self.height
        self.kiraX_1Camera.renderTexture.width = self.width * 0.5
        self.kiraX_1Camera.renderTexture.height = self.height * 0.5
        self.combCamera.renderTexture.width = self.width * 0.5
        self.combCamera.renderTexture.height = self.height * 0.5
        self.GaussX_1Camera.renderTexture.width = self.width * 0.25
        self.GaussX_1Camera.renderTexture.height = self.height * 0.25
        self.GaussY_1Camera.renderTexture.width = self.width * 0.25
        self.GaussY_1Camera.renderTexture.height = self.height * 0.25
        self.GaussX_2Camera.renderTexture.width = self.width * 0.25
        self.GaussX_2Camera.renderTexture.height = self.height * 0.25
        self.GaussY_2Camera.renderTexture.width = self.width * 0.25
        self.GaussY_2Camera.renderTexture.height = self.height * 0.25
    end
    -- self.kiraXMaterial:setFloat("angleVal", self.props:find("angle"))
    if self.rotateIntensity == 4 then
        self.rotateIntensity = 4.419
    elseif self.rotateIntensity == 0 then
        self.rotateIntensity = 0.1
    end
    self.kiraXMaterial:setFloat("angleVal", self.rotateIntensity)
    self.highlightMaterial:setFloat("threshold1", self.props:find("threshold1"))
    self.highlightMaterial:setFloat("threshold2", self.props:find("threshold2"))
    self.GaussY_2Material:setFloat("intensity", self.props:find("intensity"))
    self.finalMaterial:setFloat("intensity", self.intensity)
    self.filterMaterial:setFloat("uniAlpha", self.filterIntensity)
    -- Amaz.LOGI("angle", self.props:find("angle"))
end

function SeekModeScript:onEvent(sys, event)
    if "effects_adjust_intensity" == event.args:get(0) then
        local intensity = event.args:get(1)
        self.intensity = intensity * 0.3
    end
end

exports.SeekModeScript = SeekModeScript
return exports
