--@input float curTime = 0.0{"widget":"slider","min":0,"max":1}

local exports = exports or {}
local SeekModeScript = SeekModeScript or {}
SeekModeScript.__index = SeekModeScript
local isEditor = (Amaz.Macros and Amaz.Macros.EditorSDK) and true or false
---@class SeekModeScript: ScriptComponent
----@field ratio number
----@field decay number
----@field decayRange Vector2f
----@field density number
----@field weight number
----@field maxWeight number
----@field weightFix number
----@field noseScale number
----@field noseStartsmooth number
----@field eyeScale number
----@field eyeStartsmooth number
----@field EmitlightIntensity number
----@field lightDirection Vector3f
----@field forceLightDirection boolean
----@field maxBlur number
----@field minDownSample number
----@field firstDirFromto Vector4f
----@field secondDirFromto Vector4f
----@field thirdDirFromto Vector4f
----@field forthDirFromto Vector4f
----@field lightDirectionChangTime Vector3f
----@field lightSmoothRange Vector2f
----@field alphaBezier Vector4f
----@field duration number
----@field speed number
----@field autoPlay boolean
----@field playTime number

function SeekModeScript.new(construct, ...)
    local self = setmetatable({}, SeekModeScript)
    if construct and SeekModeScript.constructor then
        SeekModeScript.constructor(self, ...)
    end
    self.startTime = 0.0
    self.endTime = 3.0
    self.curTime = 0.0
    self.width = 0
    self.height = 0
    return self
end

---@param comp ScriptComponent
function SeekModeScript:onStart(comp)
    -- self.material = comp.entity:getComponent("MeshRenderer").material
    -- Amaz.LOGI('yyb',123)
    self.width = 0
    self.height = 0
    self.isFirst = true
    self.isSecond = false
    self.isDefaultPos = false
    self.renderTexture = {}
    self.material = {}

    self.lightMaterial = comp.entity.scene:findEntityBy("light"):getComponent("MeshRenderer").material
    self.edgeMaterial = comp.entity.scene:findEntityBy("edge"):getComponent("MeshRenderer").material

    self.lightMaterial["density"] = self.density
    self.edgeMaterial["u_noseStartsmooth"] = self.noseStartsmooth
    self.edgeMaterial["u_eyeStartsmooth"] = self.eyeStartsmooth
    self.edgeMaterial["u_intensity"] = self.EmitlightIntensity
    self.lightMaterial["decay"] = self.decay

    self.table = comp.entity:getComponent("TableComponent").table

    self.edgeMaterial["u_noseStartsmooth"] = self.noseStartsmooth
    self.edgeMaterial["u_eyeStartsmooth"] = self.eyeStartsmooth
    self.edgeMaterial["u_intensity"] = self.EmitlightIntensity
    local aeTools = includeRelativePath("AETools")
    local aeData = includeRelativePath("AEData")
    self.utilFunc = includeRelativePath("Util")
    self.aeAttr = aeTools.new(aeData)
    self.AEDemoSize = {x = 720, y = 1280}
    -- Amaz.LOGI('yyb', tostring(self.utilFunc))
    self.alphaBezierFunc =
        self.utilFunc.bezier({self.alphaBezier.x, self.alphaBezier.y, self.alphaBezier.z, self.alphaBezier.w})
    self.shiftIntensity = 1
    -- Amaz.LOGI('yyb', self.shiftIntensity)
end

function SeekModeScript:onUpdate(comp, detalTime)
    -- if Amaz.Macros and Amaz.Macros.EditorSDK then
    --     self:initData()
    -- -- self:start()
    -- else
    -- self.duration = self.endTime - self.startTime
    -- end
    if isEditor then
        if self.autoPlay then
            self.playTime = self.playTime + detalTime
        end
        self.curTime = self.playTime
    end
    self:seekToTime(comp, self.curTime - self.startTime)
end

local function getDistance(point1, point2)
    local x = point1.x - point2.x
    x = x * x
    local y = point1.y - point2.y
    y = y * y
    return math.sqrt(x + y)
end

local function getMidPoint(point1, point2)
    local x = point1.x + point2.x
    local y = point1.y + point2.y
    return Amaz.Vector2f(x / 2, y / 2)
end

-- function SeekModeScript:beforeEditorSave()
--     Amaz.Algorithm.setAlgorithmEnable("", "face_0", false)
--     Amaz.Algorithm.setAlgorithmEnable("", "skeleton_0", true)
--     self.entityLuas["face"].entity.visible = true
-- end
local function vec4MixToVec2(nowVec, mixAlpha)
    return Amaz.Vector2f((nowVec.w - nowVec.y) * mixAlpha + nowVec.y, (nowVec.z - nowVec.x) * mixAlpha + nowVec.x)
end

function SeekModeScript:seekToTime(comp, time)
    if self.isFirst then
        self.blurLua =
            Amaz.ScriptUtils.getLuaObj(
            comp.entity.scene:findEntityBy("Gaussian_Blur_Root"):getComponent("ScriptComponent"):getScript()
        )
        self.glowLua =
            Amaz.ScriptUtils.getLuaObj(
            comp.entity.scene:findEntityBy("AdjustGlow"):getComponent("ScriptComponent"):getScript()
        )
        self.isFirst = false
    end
    if (Amaz.Macros and Amaz.Macros.EditorSDK) then
        -- self.lightMaterial["weight"] = self.weight
        self.lightMaterial["density"] = self.density
        self.edgeMaterial["u_noseStartsmooth"] = self.noseStartsmooth
        self.edgeMaterial["u_eyeStartsmooth"] = self.eyeStartsmooth
        self.edgeMaterial["u_intensity"] = self.EmitlightIntensity
        self.lightMaterial["decay"] = self.decay
    end
    local nowDuration = self.duration * (1. - math.min(self.speed, 0.999))
    local nowTime = math.mod(time, nowDuration) / nowDuration

    local w = Amaz.BuiltinObject.getInputTextureWidth()
    local h = Amaz.BuiltinObject.getInputTextureHeight()

    local algorithm = Amaz.Algorithm.getAEAlgorithmResult()
    local faceCount = algorithm:getFaceCount()
    if faceCount > 0 then
        local faceinfo = algorithm:getFaceBaseInfo(0)
        -- Amaz.LOGI('yyb', math.sin(faceinfo.yaw).." "..math.sin(faceinfo.pitch))
        -- self.lightMaterial["u_pos"] = faceinfo.points_array:get(46)

        self.edgeMaterial["u_NosePos"] = faceinfo.points_array:get(46)
        self.edgeMaterial["u_eyepos1"] = faceinfo.points_array:get(104)
        self.edgeMaterial["u_eyepos2"] = faceinfo.points_array:get(105)

        self.edgeMaterial["u_NoseDistance"] =
            getDistance(faceinfo.points_array:get(49), faceinfo.points_array:get(44)) * self.noseScale
        self.edgeMaterial["u_eyeDistance1"] =
            getDistance(faceinfo.points_array:get(52), faceinfo.points_array:get(55)) * self.eyeScale
        self.edgeMaterial["u_eyeDistance2"] =
            getDistance(faceinfo.points_array:get(58), faceinfo.points_array:get(61)) * self.eyeScale
        self.edgeMaterial["u_protectFace"] = 1.0
    else
        self.edgeMaterial["u_protectFace"] = 0.0
    end
    local nowBlur = self.aeAttr:GetVal("ADBE_Gaussian_Blur_2_0001_0_0", nowTime)[1]

    local nowRatio = (1 - self.minDownSample) * (1. - nowBlur / self.maxBlur) + self.minDownSample
    self.table:get("blurTex1").pecentX = nowRatio
    self.table:get("blurTex1").pecentY = nowRatio
    self.table:get("blurTex2").pecentX = nowRatio
    self.table:get("blurTex2").pecentY = nowRatio

    self.blurLua.Intensity = nowBlur * 0.5 * self.shiftIntensity
    self.glowLua.intensity = self.aeAttr:GetVal("ADBE_Glo2_0004_0_1", nowTime)[1] * self.shiftIntensity

    if not (isEditor and self.forceLightDirection) then
        if nowTime < self.lightDirectionChangTime.x then
            -- self.lightMaterial["decay"] = (self.decayRange.y - self.decayRange.x) * (1 - nowMix) + self.decayRange.x
            -- Amaz.LOGI("yyb1  " .. nowMix, nowBlur)
            local nowMix = self.alphaBezierFunc(nowTime / self.lightDirectionChangTime.x, 0, 1, 1)
            -- local nowlight = vec4MixToVec2(self.firstDirFromto, nowMix)
            -- self.lightDirection = Amaz.Vector3f(nowlight.x, nowlight.y, 0)
            self.lightMaterial["weight"] = self.maxWeight * (1 - nowMix * self.weightFix)
            local nowCenter = self.aeAttr:GetVal("CC_Radial_Fast_Blur_0001_0_0", nowTime)
            self.lightMaterial["u_pos"] =
                Amaz.Vector2f(nowCenter[1] / self.AEDemoSize.x, nowCenter[2] / self.AEDemoSize.y)
        elseif nowTime < self.lightDirectionChangTime.y then
            -- self.lightMaterial["decay"] = (self.decayRange.y - self.decayRange.x) * (1 - nowMix) + self.decayRange.x
            -- Amaz.LOGI("yyb2  " .. nowMix, nowBlur)
            local nowMix =
                self.alphaBezierFunc(
                (nowTime - self.lightDirectionChangTime.x) /
                    (self.lightDirectionChangTime.y - self.lightDirectionChangTime.x),
                0,
                1,
                1
            )
            -- local nowlight = vec4MixToVec2(self.secondDirFromto, nowMix)
            -- self.lightDirection = Amaz.Vector3f(nowlight.x, nowlight.y, 0)
            self.lightMaterial["weight"] = self.maxWeight * (1 - nowMix * self.weightFix)
            local nowCenter = self.aeAttr:GetVal("CC_Radial_Fast_Blur_0001_1_3", nowTime)
            self.lightMaterial["u_pos"] =
                Amaz.Vector2f(nowCenter[1] / self.AEDemoSize.x, nowCenter[2] / self.AEDemoSize.y)
        elseif nowTime < self.lightDirectionChangTime.z then
            -- self.lightMaterial["decay"] = (self.decayRange.y - self.decayRange.x) * (1 - nowMix) + self.decayRange.x
            -- Amaz.LOGI("yyb3  " .. nowMix, nowBlur)
            local nowMix =
                self.alphaBezierFunc(
                (nowTime - self.lightDirectionChangTime.y) /
                    (self.lightDirectionChangTime.z - self.lightDirectionChangTime.y),
                0,
                1,
                1
            )
            -- local nowlight = vec4MixToVec2(self.thirdDirFromto, nowMix)
            -- self.lightDirection = Amaz.Vector3f(nowlight.x, nowlight.y, 0)
            self.lightMaterial["weight"] = self.maxWeight * (1 - nowMix * self.weightFix)
            local nowCenter = self.aeAttr:GetVal("CC_Radial_Fast_Blur_0001_2_6", nowTime)
            self.lightMaterial["u_pos"] =
                Amaz.Vector2f(nowCenter[1] / self.AEDemoSize.x, nowCenter[2] / self.AEDemoSize.y)
        else
            local nowMix =
                self.alphaBezierFunc(
                (nowTime - self.lightDirectionChangTime.z) / (1. - self.lightDirectionChangTime.z),
                0,
                1,
                1
            )
            -- local nowlight = vec4MixToVec2(self.forthDirFromto, nowMix)
            -- self.lightDirection = Amaz.Vector3f(nowlight.x, nowlight.y, 0)
            self.lightMaterial["weight"] = self.maxWeight * (1 - nowMix * self.weightFix)
            local nowCenter = self.aeAttr:GetVal("CC_Radial_Fast_Blur_0001_3_9", nowTime)
            self.lightMaterial["u_pos"] =
                Amaz.Vector2f(nowCenter[1] / self.AEDemoSize.x, nowCenter[2] / self.AEDemoSize.y)
        end
    end
    Amaz.LOGI('yyb',tostring(self.lightMaterial:getVec2('u_pos')))
    -- local tranTemp = Amaz.Transform()
    -- tranTemp.localOrientation = Amaz.Quaternionf.eulerToQuaternion(self.lightDirection)
    -- self.lightMaterial:setMat4("u_OrientationMat", tranTemp.localMatrix)
    local nowpos = self.aeAttr:GetVal("ADBE_Position_1_3", nowTime)
    -- Amaz.LOGI('yyb', nowTime)

    -- Amaz.LOGI('yyb', tostring(Amaz.Vector2f(nowpos[1]/self.AEDemoSize.x-0.5, nowpos[2]/self.AEDemoSize.y-0.5)))
    self.lightMaterial:setVec2(
        "u_offset",
        Amaz.Vector2f(
            (nowpos[1] / self.AEDemoSize.x - 0.5) * self.shiftIntensity,
            (nowpos[2] / self.AEDemoSize.y - 0.5) * self.shiftIntensity
        )
    )
    -- self.edgeMaterial:setVec2("u_lightSmooth", self.lightSmoothRange)
    local algo_result = Amaz.Algorithm.getAEAlgorithmResult()
    local mattingInfo1 = algo_result:getBgInfo()
    if mattingInfo1 then
        local rect = mattingInfo1.resultRect
        if math.abs(rect.width) > 0.001 and math.abs(rect.height) > 0.001 then
            self.edgeMaterial:setFloat("u_useMatting", 1)
        else
            self.edgeMaterial:setFloat("u_useMatting", 0)
        end
    end
end

local function remap(x, a, b)
    return x * (b - a) + a
end

function SeekModeScript:onEvent(sys, event)
    if event.args:get(0) == "effects_adjust_luminance" then
        local intensity = event.args:get(1)
        self.maxWeight = intensity * 1.7
    end
    if event.args:get(0) == "effects_adjust_blur" then
        local intensity = event.args:get(1)
        self.lightMaterial["density"] = intensity * 0.8 + 0.4
    end
    if event.args:get(0) == "effects_adjust_speed" then
        local intensity = event.args:get(1)
        self.duration = remap(intensity, 3.0, 1.0)
    end
    if event.args:get(0) == "effects_adjust_vertical_shift" then
        local intensity = event.args:get(1)
        self.shiftIntensity = intensity
    end
    if event.args:get(0) == "effects_adjust_range" then
        local intensity = event.args:get(1)
        self.edgeMaterial:setVec2("u_lightSmooth", Amaz.Vector2f((1.-intensity)*0.8, 1))
    end
end

exports.SeekModeScript = SeekModeScript
return exports
