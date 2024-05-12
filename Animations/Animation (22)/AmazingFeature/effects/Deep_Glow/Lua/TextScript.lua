
local exports = exports or {}
local TextScript = TextScript or {}

---@class TextScript : ScriptComponent
---@field glow_intensity number
---@field radius number
TextScript.__index = TextScript

function TextScript.new()
    local self = {}
    setmetatable(self, TextScript)
    self.transform = {}
    self.glow_intensity = 0
    self.radius = 256
    self.first = true
    return self
end

---@param comp Component
function TextScript:onStart(comp)
    self.blendMat = comp.entity:searchEntity("Blend"):getComponent("MeshRenderer").material
    self.first = true
    self.prop = comp.properties
end

---@param comp Component
---@param deltaTime number
function TextScript:onUpdate(comp, deltaTime)
    if self.first == true then
        local GlowBlurRoot1Lua = comp.entity:searchEntity("GlowBlur_1"):getComponent("ScriptComponent")
        self.LuaObj1 = Amaz.ScriptUtils.getLuaObj(GlowBlurRoot1Lua:getScript())
        local GlowBlurRoot2Lua = comp.entity:searchEntity("GlowBlur_2"):getComponent("ScriptComponent")
        self.LuaObj2 = Amaz.ScriptUtils.getLuaObj(GlowBlurRoot2Lua:getScript())
        local GlowBlurRoot3Lua = comp.entity:searchEntity("GlowBlur_3"):getComponent("ScriptComponent")
        self.LuaObj3 = Amaz.ScriptUtils.getLuaObj(GlowBlurRoot3Lua:getScript())
        local GlowBlurRoot4Lua = comp.entity:searchEntity("GlowBlur_4"):getComponent("ScriptComponent")
        self.LuaObj4 = Amaz.ScriptUtils.getLuaObj(GlowBlurRoot4Lua:getScript())
        local GlowBlurRoot5Lua = comp.entity:searchEntity("GlowBlur_5"):getComponent("ScriptComponent")
        self.LuaObj5 = Amaz.ScriptUtils.getLuaObj(GlowBlurRoot5Lua:getScript())
        local GlowBlurRoot6Lua = comp.entity:searchEntity("GlowBlur_6"):getComponent("ScriptComponent")
        self.LuaObj6 = Amaz.ScriptUtils.getLuaObj(GlowBlurRoot6Lua:getScript())
        local GlowBlurRoot7Lua = comp.entity:searchEntity("GlowBlur_7"):getComponent("ScriptComponent")
        self.LuaObj7 = Amaz.ScriptUtils.getLuaObj(GlowBlurRoot7Lua:getScript())
        local GlowBlurRoot8Lua = comp.entity:searchEntity("GlowBlur_8"):getComponent("ScriptComponent")
        self.LuaObj8 = Amaz.ScriptUtils.getLuaObj(GlowBlurRoot8Lua:getScript())
        self.first = false
    end
    self.glow_intensity = self.prop:get("glow_intensity")
    self.blendMat:setFloat("u_GlowIntensity", self.glow_intensity)
    local downSample = 1
    local downSample1 = 1
    local downSample2 = 1
    local downSample3 = math.max(math.min(self.radius / 128, 2.0), 1.0)
    local downSample4 = math.max(math.min(self.radius / 64, 4.0), 1.0)
    local downSample5 = math.max(self.radius / 32, 1.0)
    local downSample6 = math.max(self.radius / 16, 1.0)
    local downSample7 = math.max(self.radius / 8, 1.0)
    local downSample8 = math.max(self.radius / 4, 1.0)
    self.LuaObj1.Intensity = self.radius / 16 * 0.125
    self.LuaObj2.Intensity = self.radius / 16 * 0.25
    self.LuaObj3.Intensity = self.radius / 16 / downSample3 * 0.5
    self.LuaObj4.Intensity = self.radius / 16 / downSample4
    self.LuaObj5.Intensity = self.radius / downSample5 * 0.125
    self.LuaObj6.Intensity = self.radius / downSample6 * 0.25
    self.LuaObj7.Intensity = self.radius / downSample7 * 0.5
    self.LuaObj8.Intensity = self.radius / downSample8

    self.LuaObj1.DownSample = downSample1
    self.LuaObj2.DownSample = downSample2
    self.LuaObj3.DownSample = downSample3
    self.LuaObj4.DownSample = downSample4
    self.LuaObj5.DownSample = downSample5
    self.LuaObj6.DownSample = downSample6
    self.LuaObj7.DownSample = downSample7
    self.LuaObj8.DownSample = downSample8
end

---@param comp Component
---@param event Event
function TextScript:onEvent(comp, event)
end

exports.TextScript = TextScript
return exports
