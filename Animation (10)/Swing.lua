local exports = exports or {}
local Swing = Swing or {}
Swing.__index = Swing
function Swing.new(construct, ...)
    local self = setmetatable({}, Swing)
    self.text = nil
    self.tween = nil
    self.tween1 = nil
    self.tween2 = nil
    self.comp = nil
    self.duration = 0
    self.animTransMat = nil
    if construct and Swing.constructor then Swing.constructor(self, ...) end
    return self
end

function Swing:constructor()

end

local function updateHandle(comp, height)
    if comp == nil then 
        return 
    end

    local animTrans = comp.entity:getComponent("Transform")
    local parentTrans = animTrans.parent
    
    local userS = parentTrans.localScale
    local userR = parentTrans.localOrientation
    local userT = parentTrans.localPosition

    local animS = animTrans.localScale
    local animR = animTrans.localOrientation
    local animT = animTrans.localPosition

    local mat = Amaz.Matrix4x4f()
    mat:Copy(parentTrans.localMatrix)
    
    -- move to (0,0)
    mat:AddTranslate(Amaz.Vector3f(-userT.x, -userT.y, -userT.z))

    -- move to pivot
    mat:AddTranslate(Amaz.Vector3f(0, -height / 2 * userS.y, 0))

    --anim rotate scale
    local rot = Amaz.Matrix4x4f()
    rot:SetIdentity()
    rot:SetTR(Amaz.Vector3f(0,0,0), animR)
    mat = rot * mat

    -- move back 
    mat:AddTranslate(Amaz.Vector3f(0, height / 2 * userS.y, 0))
    mat:AddTranslate(userT)

    -- set anim local matrix
    local animLocal = parentTrans.localMatrix:Invert_Full() * mat
    animTrans.localMatrix = animLocal
end

function Swing:onStart(comp)
    local screenH = Amaz.BuiltinObject:getOutputTextureHeight()
    local textureH 
    local sprite = comp.entity:getComponent("Sprite2DRenderer")
    self.text = comp.entity:getComponent("SDFText")

    if sprite ~= nil then
        textureH = sprite:getTextureSize().y
    end

    if self.text ~= nil then
        if self.text.chars:size() >= 1 then
            textureH = self.text.rect.height + self.text.chars:get(0).height * 2
        else
            textureH = self.text.rect.height
        end
    end
    
    self.height = textureH / screenH
    self.comp = comp
    local transform = comp.entity:getComponent("Transform")
    self.animTransMat = transform.localMatrix:Copy()
    self.tween = comp.entity.scene.tween:fromTo(transform, 
                                                {["localEulerAngle"] = Amaz.Vector3f(0.0, 0.0, 0.0)},
                                                {["localEulerAngle"] = Amaz.Vector3f(0.0, 0.0, -20.0)}, 
                                                0.1, 
                                                Amaz.Ease.quadOut, 
                                                nil, 
                                                0.0, 
                                                nil, 
                                                false)
    self.tween1 = comp.entity.scene.tween:fromTo(transform, 
                                                {["localEulerAngle"] = Amaz.Vector3f(0.0, 0.0, -20.0)},
                                                {["localEulerAngle"] = Amaz.Vector3f(0.0, 0.0, 20.0)}, 
                                                0.1, 
                                                Amaz.Ease.quadInOut, 
                                                nil, 
                                                0.0, 
                                                nil, 
                                                false)
    self.tween2 = comp.entity.scene.tween:fromTo(transform, 
                                                {["localEulerAngle"] = Amaz.Vector3f(0.0, 0.0, 20.0)}, 
                                                {["localEulerAngle"] = Amaz.Vector3f(0.0, 0.0, 0.0)}, 
                                                0.1, 
                                                Amaz.Ease.quadIn, 
                                                nil, 
                                                0.0, 
                                                nil, 
                                                false)
end

function Swing:seek(time)
    time  = time % self.duration
    if(time <= self.tween.duration) then
        self.tween:set(time)
    elseif(time <= self.tween.duration + self.tween1.duration) then
        self.tween1:set(time - self.tween.duration)
    else
        self.tween2:set(time - self.tween.duration - self.tween1.duration)
    end
    updateHandle(self.comp, self.height)
end

function Swing:setDuration(duration)
    self.duration = duration
    self.tween1.duration = duration / 2.0
    self.tween.duration = (duration - self.tween1.duration) / 2.0
    self.tween2.duration = duration - self.tween1.duration - self.tween.duration
end

function Swing:clear()
    if self.tween then
        -- self.tween:set(0)
        self.tween:clear()
        self.tween = nil
    end
    if self.tween1 then
        self.tween1:clear()
        self.tween1 = nil
    end
    if self.tween2 then
        self.tween2:clear()
        self.tween2 = nil
    end

    local trans = self.comp.entity:getComponent("Transform")
    local mat = Amaz.Matrix4x4f()
    mat:SetIdentity()
    trans.localMatrix = mat
end

exports.Swing = Swing
return exports
