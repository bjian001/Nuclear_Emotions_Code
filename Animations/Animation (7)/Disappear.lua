local exports = exports or {}
local Disappear = Disappear or {}
Disappear.__index = Disappear
function Disappear.new(construct, ...)
    local self = setmetatable({}, Disappear)
    self.tween = nil
    self.text = nil
    self.ease = Amaz.Ease.linearIn
    if construct and Disappear.constructor then Disappear.constructor(self, ...) end
    return self
end

function Disappear:constructor()

end

function Disappear:onStart(comp)
    local sprite = comp.entity:getComponent("Sprite2DRenderer")
    self.text = comp.entity:getComponent("SDFText")

    if sprite ~= nil then
        local material = sprite.material
        textureH = sprite:getTextureSize().y
        self.tween = comp.entity.scene.tween:fromTo(material, {["_alpha"] = 1.0}, {["_alpha"] = 0.0}, 0.1, Amaz.Ease.quadOut, nil, 0.0, nil, false)
    end

    if self.text ~= nil then
        textureH = self.text.rect.height
        self.tween = comp.entity.scene.tween:fromTo(self.text, {["alpha"] = 1.0}, {["alpha"] = 0.0}, 0.1, Amaz.Ease.quadOut, nil, 0.0, nil, false)
    end
end

function Disappear:seek(time)
    self.tween:set(time)
end

function Disappear:setDuration(duration)
    self.tween.duration = duration
end

function Disappear:clear()
    if self.tween then
        self.tween:set(0)
        self.tween:clear()
        self.tween = nil
    end
end
exports.Disappear = Disappear
return exports
