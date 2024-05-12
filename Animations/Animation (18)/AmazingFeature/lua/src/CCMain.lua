local Utils = require("common/Utils")
local Helper = require("cc/Helper")

local CCMain = {}
CCMain.__index = CCMain
function CCMain.new (env, data)
    local self = setmetatable({}, CCMain)
    self.MIN_SPEED = 0.5
    self.MAX_SPEED = 2.0
    self.MIN_SCALE = 1.3
    self.MAX_SCALE = 4.0

    data.intensity = 0
    data.shift_x = 0.5
    data.shift_y = 0.5
    data.speed = 0.33333333
    return self
end

function CCMain:create (env, data, scene)
    Helper.initPipeline(scene, "@Pipeline")

    self.displace = scene:findEntityBy("displace"):getComponent("MeshRenderer").material
    self.displace:setFloat("u_intensity", 0.5)
    self.anim = scene:findEntityBy("displace"):getComponent("AnimSeqComponent")
end

function CCMain:layout (env, data, w, h)
    self.displace:setVec2("u_screen_size", Amaz.Vector2f(w, h))
    local maxEdge = math.max(w, h)
    self.displace:setVec2("u_size", Amaz.Vector2f(maxEdge, maxEdge))
    local dirX = math.cos(math.rad(120)) / maxEdge
    local dirY = -math.sin(math.rad(120)) / maxEdge
    self.displace:setVec2("u_step", Amaz.Vector2f(dirX * -1.5, dirY * -1.5))
end

function CCMain:update (node, data, elapsed, duration, progress)
    elapsed = elapsed * Utils.mix(self.MIN_SPEED, self.MAX_SPEED, data.speed)
    self.anim:seekToTime(elapsed)

    local intensity_x = Utils.mix(-1, 1, data.shift_x)
    self.displace:setVec4("u_intensity_x", Amaz.Vector4f(0, 0, 0, intensity_x))
    local intensity_y = Utils.mix(-1, 1, data.shift_y)
    self.displace:setVec4("u_intensity_y", Amaz.Vector4f(0, 0, 0, intensity_y))

    local scale = Utils.mix(self.MIN_SCALE, self.MAX_SCALE, data.intensity)
    self.displace:setFloat("u_scale", scale)
end


return CCMain