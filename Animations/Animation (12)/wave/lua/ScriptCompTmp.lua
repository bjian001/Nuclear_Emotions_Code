local exports = exports or {}
local ScriptCompTmp = ScriptCompTmp or {}
ScriptCompTmp.__index = ScriptCompTmp

function ScriptCompTmp.new(construct, ...)
    local self = setmetatable({}, ScriptCompTmp)

    if construct and ScriptCompTmp.constructor then ScriptCompTmp.constructor(self, ...) end
    self.time = 0
    self.startTime = 0.0
    -- self.speed= 1.0
    return self
end

function ScriptCompTmp:constructor()
end

function ScriptCompTmp:onStart(comp)
    self.pass2material = comp.entity.scene:findEntityBy("Untitled"):getComponent("MeshRenderer").sharedMaterials:get(0)
end

function ScriptCompTmp:onUpdate(comp, deltaTime)
    self.time = 0.02 + self.time
    self:seekToTime(comp, self.time - self.startTime)

end
function ScriptCompTmp:seekToTime(comp, time)
    -- self.speed=self.pass2material:getFloat("speed")
    self.mytime = (time-1.0)*self.pass2material:getFloat("speed")+1.0
    self.pass2material:setFloat("iTime",self.mytime)
end

function ScriptCompTmp:onEvent(sys,event)
    if event.args:get(0) == "effects_adjust_speed" then
        local intensity = event.args:get(1)

        self.pass2material:setFloat("speed",intensity*13+5.0)
    end
    if event.args:get(0) == "effects_adjust_intensity" then
        local intensity = event.args:get(1)
        self.pass2material:setFloat("scope",intensity*0.075+0.015)
    end

    if event.args:get(0) == "effects_adjust_size" then
        local intensity = event.args:get(1)
        self.pass2material:setFloat("rate",intensity*1.8+0.7)
    end
end




exports.ScriptCompTmp = ScriptCompTmp
return exports
