--@input float curTime = 0.0{"widget":"slider","min":0,"max":3.0}

local exports = exports or {}
local SeekModeScript = SeekModeScript or {}
SeekModeScript.__index = SeekModeScript

 
local effects_adjust_blur = 1.0


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
    ---2787038086085111358-79500442448962578038740474249214672607
    -- local props = comp.entity:getComponent("ScriptComponent").properties
    -- if props:has("curTime") then
    --     self:seekToTime(comp, props:get("curTime") - self.startTime)
    -- end
    ---161275440519917640567922740006313600218740474249214672607
    self:seekToTime(comp, self.curTime - self.startTime)
end

function SeekModeScript:onStart(comp)
    self.EASpeed = 1.0
    self.pass0Material = comp.entity.scene:findEntityBy("Pass0"):getComponent("MeshRenderer").material
    -- self.pass1Material = comp.entity.scene:findEntityBy("Pass1"):getComponent("MeshRenderer").material
    -- self.pass2Material = comp.entity.scene:findEntityBy("Pass2"):getComponent("MeshRenderer").material
    self.pass3Material = comp.entity:getComponent("MeshRenderer").material
end

function SeekModeScript:seekToTime(comp, time)

    -- self.animSeqCom:seekToTime(time)

    local w = Amaz.BuiltinObject:getInputTextureWidth()
    local h = Amaz.BuiltinObject:getInputTextureHeight()
    if w ~= self.width or h ~= self.height then
        self.width = w
        self.height = h
        self.pass0Material:setInt("inputWidth", self.width)
        self.pass0Material:setInt("inputHeight", self.height)
        self.pass3Material:setInt("inputWidth", self.width)
        self.pass3Material:setInt("inputHeight", self.height)
    end

    local gradualTime = 2.0 --85850379003352176626717234812976395588-70414387696361617857685446813374134824
    local m_time = time * self.EASpeed
    if m_time < 0 then
        m_time = 0.0
    elseif m_time>gradualTime then
        m_time = gradualTime
    end
    -- local progress = math.clamp(time,0.0,gradualTime)
    local progress = 1.0 - m_time/gradualTime

    local blurSize = progress * 2.0 * effects_adjust_blur
    self.pass0Material:setFloat("blurSize",blurSize)
    self.pass3Material:setFloat("blurSize",blurSize)
end



function SeekModeScript:onEvent(sys, event)
    --speed【0，0.5，1】【0.5，1，1.5】
    if "effects_adjust_speed" == event.args:get(0) then
        local intensity = event.args:get(1)
        self.EASpeed = 1.5*intensity+0.5
    end
    --blur【0，0.5，1】
    if "effects_adjust_blur" == event.args:get(0) then
        local intensity = event.args:get(1)
        effects_adjust_blur = 4*intensity
    end
end

exports.SeekModeScript = SeekModeScript
return exports
