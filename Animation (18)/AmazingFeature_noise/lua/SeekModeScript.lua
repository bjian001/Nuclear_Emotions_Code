--@input float curTime = 0.0{"widget":"slider","min":0,"max":10}

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
    return self
end

function SeekModeScript:constructor()

end

function SeekModeScript:onUpdate(comp, detalTime)
    --ceshiyong
    -- local props = comp.entity:getComponent("ScriptComponent").properties
    -- if props:has("curTime") then
    --     self:seekToTime(comp, props:get("curTime"))
    -- end
    --shijiyong
    self:seekToTime(comp, self.curTime - self.startTime)
end

function SeekModeScript:onStart(comp)
    --self.pass0Material = comp.entity.scene:findEntityBy("Pass0"):getComponent("MeshRenderer").material
    self.pass3Material = comp.entity:getComponent("MeshRenderer").material
    self.pass3Material:setFloat("sizeFactor", 1.0) 
end

function SeekModeScript:seekToTime(comp, time)

    -- self.animSeqCom:seekToTime(time)

    local w = Amaz.BuiltinObject:getInputTextureWidth()
    local h = Amaz.BuiltinObject:getInputTextureHeight()
    local a = w / h
    self.pass3Material:setFloat("u_dst_aspect", a)
    self.pass3Material:setFloat("u_src_aspect", 1)
    self.pass3Material:setFloat("uTime",time)
end

function SeekModeScript:onEvent(sys, event)
    if "effects_adjust_texture" == event.args:get(0) then
        local intensity = event.args:get(1)
        self.pass3Material:setFloat("alphaFactor", intensity) 
    end
    --if "effects_adjust_size" == event.args:get(0) then
    --    local intensity = event.args:get(1)
    --    self.pass3Material:setFloat("sizeFactor", 1.0-0.5*intensity)
    --end
    --if "effects_adjust_filter" == event.args:get(0) then
    --    local intensity = event.args:get(1)
    --    self.pass0Material:setFloat("uniAlpha", intensity)
    --end
end
exports.SeekModeScript = SeekModeScript
return exports
