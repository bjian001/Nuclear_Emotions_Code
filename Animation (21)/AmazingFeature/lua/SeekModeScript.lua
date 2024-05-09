local isEditor = (Amaz.Macros and Amaz.Macros.EditorSDK) and true or false
local AETools = AETools or {}     ---@class AETools
AETools.__index = AETools

function AETools:new(attrs)
    local self = setmetatable({}, AETools)
    self.attrs = attrs

    local max_frame = 0
    for _,v in pairs(attrs) do
        for i = 1, #v do
            local content = v[i]
            local cur_frame = content[2][2]
            max_frame = math.max(cur_frame, max_frame)
        end
    end

    self:SetAllFrame(max_frame)

    return self
end

function AETools._remap01(a,b,x)
    if x < a then return 0 end
    if x > b then return 1 end
    return (x-a)/(b-a)
end

function AETools._cubicBezier(p1, p2, p3, p4, t)
    return {
        p1[1]*(1.-t)*(1.-t)*(1.-t) + 3*p2[1]*(1.-t)*(1.-t)*t + 3*p3[1]*(1.-t)*t*t + p4[1]*t*t*t,
        p1[2]*(1.-t)*(1.-t)*(1.-t) + 3*p2[2]*(1.-t)*(1.-t)*t + 3*p3[2]*(1.-t)*t*t + p4[2]*t*t*t,
    }
end

function AETools:_cubicBezier01(_bezier_val, p)
    local x = self:_getBezier01X(_bezier_val, p)
    return self._cubicBezier(
        {0,0},
        {_bezier_val[1], _bezier_val[2]},
        {_bezier_val[3], _bezier_val[4]},
        {1,1},
        x
    )[2]
end

function AETools:_getBezier01X(_bezier_val, x)
    local ts = 0
    local te = 1
    -- divide and conque
    repeat
        local tm = (ts+te)*0.5
        local value = self._cubicBezier(
            {0,0},
            {_bezier_val[1], _bezier_val[2]},
            {_bezier_val[3], _bezier_val[4]},
            {1,1},
            tm)
        if(value[1]>x) then
            te = tm
        else
            ts = tm
        end
    until(te-ts < 0.0001)

    return (te+ts)*0.5
end

function AETools._mix(a, b, x)
    return a * (1-x) + b * x
end

function AETools:SetAllFrame(val)
    self.all_frame = val
end

function AETools:GetVal(_name, _progress)
    local content = self.attrs[_name]
    if content == nil then
        return nil
    end

    local cur_frame = _progress * self.all_frame

    for i = 1, #content do
        local info = content[i]
        local start_frame = info[2][1]
        local end_frame = info[2][2]
        if cur_frame >= start_frame and cur_frame < end_frame then
            local cur_progress = self._remap01(start_frame, end_frame, cur_frame)
            local bezier = info[1]
            local value_range = info[3]

            if #bezier > 4 then
                -- currently scale attrs contains more than 4 bezier values
                local res = {}
                for k = 1, 3 do
                    local cur_bezier = {bezier[k], bezier[k+3], bezier[k+3*2], bezier[k+3*3]}
                    local p = self:_cubicBezier01(cur_bezier, cur_progress)
                    res[k] = self._mix(value_range[1][k], value_range[2][k], p)
                end
                return res

            else
                local p = self:_cubicBezier01(bezier, cur_progress)

                if type(value_range[1]) == "table" then
                    local res = {}
                    for j = 1, #value_range[1] do
                        res[j] = self._mix(value_range[1][j], value_range[2][j], p)
                    end
                    return res
                end
                return self._mix(value_range[1], value_range[2], p)
            end

        end
    end

    local first_info = content[1]
    local start_frame = first_info[2][1]
    if cur_frame<start_frame then
        return first_info[3][1]
    end

    local last_info = content[#content]
    local end_frame = last_info[2][2]
    if cur_frame>=end_frame then
        return last_info[3][2]
    end

    return nil
end

function AETools:test()
    Amaz.LOGI("lrc "..tostring(self.key_frame_info), tostring(#self.key_frame_info))
end
--@input float curTime = 0.0{"widget":"slider","min":0,"max":1}
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
    self.GlowRange = 100
    
    return self
end
local ae_attribute = {
	["ADBE_Gaussian_Blur_2_0001_0_0"]={
		{{0.001, 0, 0, 0.894610989, }, {0, 12, }, {{350, }, {0, }, }, {6417, }, {0, }, }, 
	}, 
    ["ADBE_Gaussian_Blur_2_0001_0_1"]={
		{{0.166666667, 0.166666667, 0.833333333, 0.880490245, }, {0, 1, }, {{14, }, {8.810026, }, }, {6417, }, {0, }, }, 
		{{0.166666667, 0.275293848, 0.833333333, 0.858579777, }, {1, 2, }, {{8.810026, }, {6.556969, }, }, {6417, }, {0, }, }, 
		{{0.166666667, 0.202886033, 0.833333333, 0.853539316, }, {2, 3, }, {{6.556969, }, {4.986493, }, }, {6417, }, {0, }, }, 
		{{0.166666667, 0.193340237, 0.833333333, 0.851250296, }, {3, 4, }, {{4.986493, }, {3.796812, }, }, {6417, }, {0, }, }, 
		{{0.166666667, 0.189490926, 0.833333333, 0.850170894, }, {4, 5, }, {{3.796812, }, {2.862918, }, }, {6417, }, {0, }, }, 
		{{0.166666667, 0.187767708, 0.833333333, 0.849819194, }, {5, 6, }, {{2.862918, }, {2.117717, }, }, {6417, }, {0, }, }, 
		{{0.166666667, 0.187218255, 0.833333333, 0.850027873, }, {6, 7, }, {{2.117717, }, {1.51994, }, }, {6417, }, {0, }, }, 
		{{0.166666667, 0.18754357, 0.833333333, 0.85077801, }, {7, 8, }, {{1.51994, }, {1.041918, }, }, {6417, }, {0, }, }, 
		{{0.166666667, 0.188729994, 0.833333333, 0.852168994, }, {8, 9, }, {{1.041918, }, {0.663963, }, }, {6417, }, {0, }, }, 
		{{0.166666667, 0.191003024, 0.833333333, 0.854462456, }, {9, 10, }, {{0.663963, }, {0.371437, }, }, {6417, }, {0, }, }, 
		{{0.166666667, 0.194972792, 0.833333333, 0.858245298, }, {10, 11, }, {{0.371437, }, {0.15308, }, }, {6417, }, {0, }, }, 
		{{0.166666667, 0.20220156, 0.833333333, 0.833333333, }, {11, 12, }, {{0.15308, }, {0, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_IE_bd05021dc9663a44921852b-0001_0_1"]={
		{{0.33, 0.212121212, 0.5, 1, }, {0, 12, }, {{33, }, {0, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_IE_adc0d88f4eea75689279588-0001_0_2"]={
		{{0.001, 0, 0.66, 1, }, {0, 12, }, {{40, }, {0, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_IE_5a1ff1b7caffac514aaba44-0001_0_3"]={
		{{0.6, 0.221538462, 0.66, 1, }, {0, 12, }, {{1, }, {0, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_Scale_0_4"]={
		{{0.001,0.001,0.001, 0,0.001,0.001, 0.4,0.4,0.4, 1,0.4,0.4, }, {0, 12, }, {{110, 100, 100, }, {100, 100, 100, }, }, {6414, }, {0, }, }, 
	}, 
}

function SeekModeScript:constructor()

end

local function getBezierValue(controls, t)
    local ret = {}
    local xc1 = controls[1]
    local yc1 = controls[2]
    local xc2 = controls[3]
    local yc2 = controls[4]
    ret[1] = 3*xc1*(1-t)*(1-t)*t+3*xc2*(1-t)*t*t+t*t*t
    ret[2] = 3*yc1*(1-t)*(1-t)*t+3*yc2*(1-t)*t*t+t*t*t
    return ret
end

local function getBezierDerivative(controls, t)
    local ret = {}
    local xc1 = controls[1]
    local yc1 = controls[2]
    local xc2 = controls[3]
    local yc2 = controls[4]
    ret[1] = 3*xc1*(1-t)*(1-3*t)+3*xc2*(2-3*t)*t+3*t*t
    ret[2] = 3*yc1*(1-t)*(1-3*t)+3*yc2*(2-3*t)*t+3*t*t
    return ret
end

local function getBezierTfromX(controls, x)
    local ts = 0
    local te = 1
    -- divide and conque
    repeat
        local tm = (ts+te)/2
        local value = getBezierValue(controls, tm)
        if(value[1]>x) then
            te = tm
        else
            ts = tm
        end
    until(te-ts < 0.0001)

    return (te+ts)/2
end
local function mix(a,b,x)
	return a+(b-a)*x
end
local function clamp(x,a,b)
    if x<a then
        x=a
    elseif x>b then
        x=b
    end
    return x
end
if Amaz.Macros and Amaz.Macros.EditorSDK then
    function SeekModeScript:onUpdate(comp, detalTime)
        --ceshiyong
        local props = comp.entity:getComponent("ScriptComponent").properties
        
        -- shijiyong
        self.curTime=self.curTime + detalTime
        if props:has("curTime") and isEditor then
            self.curTime= props:get("curTime")
        end
        self:seek(self.curTime - self.startTime)
    end
end

function SeekModeScript:_adapt_onStart(comp)
    self.curTime = 0
    self.duration = 1.0
    self.values = {}
    self.params = {}
    self.anims = {}
    self.animDirty = true
    self.entity = comp.entity
    self.scaleCorrect = 1.0
    self.videoMat = self.entity.scene:findEntityBy("video"):getComponent("MeshRenderer").material
    self.modelMat = self.entity.scene:findEntityBy("quad"):getComponent("MeshRenderer").material
    self.fxaaMat = self.entity.scene:findEntityBy("fxaa"):getComponent("MeshRenderer").material
    self.blendMat = self.entity.scene:findEntityBy("blend"):getComponent("MeshRenderer").material
    self.transform = self.entity.scene:findEntityBy("quad"):getComponent("Transform")
    self.userPosition = Amaz.Vector3f(0, 0, 0)
    self.userEulerAngle = Amaz.Vector3f(0, 0, 0)
    self.userScale = Amaz.Vector3f(1, 1, 1)

    self.size = 0
    self.quantity = 2
    self.complexity = 1
    self.evolution = 0
    self.cycle = 100
    self.offset_x = 0
    self.offset_y = 0
    self.type = 0
    self.fix_type = 0
    self.motion_tile_type = 0
    self.picture_scale = 1
end

function SeekModeScript:onStart(comp)
    self:_adapt_onStart(comp)
    -- self.animSeqCom = comp.entity.scene:findEntityBy("imgMovePass"):getComponent("AnimSeqComponent")
    -- self.resultMaterial = comp.entity.scene:findEntityBy("result"):getComponent("MeshRenderer").material
    self.HorizontalBlurMat = comp.entity.scene:findEntityBy("Horizontal_Blur"):getComponent("MeshRenderer").material
    self.VerticalBlurMat = comp.entity.scene:findEntityBy("Vertical_Blur"):getComponent("MeshRenderer").material
    self.SomePassMat = comp.entity.scene:findEntityBy("somePass"):getComponent("MeshRenderer").material
    self.ExposureMat = comp.entity.scene:findEntityBy("Exposure"):getComponent("MeshRenderer").material
    --self.bhmaterial = comp.entity:searchEntity("FliterEntity-2FFE6ABD"):getComponent("MeshRenderer").material
    self.bhmaterial = comp.entity.scene:findEntityBy("FliterEntity-2FFE6ABD"):getComponent("MeshRenderer").material
    self.satmaterial = comp.entity.scene:findEntityBy("Sat"):getComponent("MeshRenderer").material
    --self.material = comp.entity:searchEntity("Sat"):getComponent("MeshRenderer").material
    --self.stascript = comp.entity.scene:findEntityBy("lumi_saturation_40-effect4"):getComponent("ScriptComponent").properties

    
    self.attrs = AETools:new(ae_attribute)
end


function SeekModeScript:_adapt_seek(time)
    local inputW = Amaz.BuiltinObject:getInputTextureWidth()
    local inputH = Amaz.BuiltinObject:getInputTextureHeight()
    local inputRatio = inputW / inputH
    local outputW = Amaz.BuiltinObject:getOutputTextureWidth()
    local outputH = Amaz.BuiltinObject:getOutputTextureHeight()
    local outputRatio = outputW / outputH
    local fitScale = Amaz.Vector3f(1, 1, 1)
    local extraScale = 1
    if inputRatio < outputRatio then
        fitScale.x = inputRatio
        extraScale = inputH / outputH
    else
        fitScale.x = outputRatio
        fitScale.y = outputRatio / inputRatio
        extraScale = inputW / outputW
    end

    local uvScale = Amaz.Vector2f(1, 1)
    local xRatio = inputRatio / outputRatio
    local yRatio = outputRatio / inputRatio
    if outputRatio > 1. then
        if outputRatio > inputRatio then
            uvScale.x = xRatio
        else
            uvScale.y = yRatio
        end
    elseif math.abs(outputRatio - 1.) < .1 then
        if inputRatio < 1. then
            uvScale.x = xRatio
        else
            uvScale.y = yRatio
        end
    elseif outputRatio < 1. then
        if math.abs(inputRatio - 1.) < .1 or outputRatio < inputRatio then
            uvScale.y = yRatio
        else
            uvScale.x = xRatio
        end
    end

    self.modelMat:setFloat("u_OutputWidth", outputW)
    self.modelMat:setFloat("u_OutputHeight", outputH)

    local userMat = Amaz.Matrix4x4f()
    userMat:setTRS(
        Amaz.Vector3f(self.userPosition.x * outputRatio, self.userPosition.y, self.userPosition.z),
        Amaz.Quaternionf.EulerToQuaternion(-self.userEulerAngle / 180 * math.pi),
        Amaz.Vector3f(1, 1, 1) * self.userScale.x * extraScale
    )
    userMat:invert_Full()

    local fitMat = Amaz.Matrix4x4f()
    fitMat:setTRS(Amaz.Vector3f(0, 0, 0), Amaz.Quaternionf.identity(), Amaz.Vector3f(uvScale.x, uvScale.y, 1))
    fitMat:invert_Full()

    self.modelMat:setMat4("userMat", userMat)
    self.modelMat:setMat4("fitMat", fitMat)
end

function SeekModeScript:seek(time)
    self:_adapt_seek(time)

    local w = Amaz.BuiltinObject:getInputTextureWidth()
    local h = Amaz.BuiltinObject:getInputTextureHeight()
    if w ~= self.width or h ~= self.height then
        self.width = w
        self.height = h
 
    end


    local t = math.mod(time,self.duration+0.0001)/(self.duration+0.0001)
    
    -- self.resultMaterial:setFloat("iTime",t)
    





    local AEprogress = t * 12/ 12
    local fps = AEprogress * 12
    -- Amaz.LOGI("AEprogress",AEprogress)
    --Amaz.LOGI("fps", fps)
    local horValue = self.attrs:GetVal("ADBE_Gaussian_Blur_2_0001_0_0", AEprogress)[1]
    local verValue = self.attrs:GetVal("ADBE_Gaussian_Blur_2_0001_0_1", AEprogress)[1]

    self.HorizontalBlurMat:setFloat("u_Strength", horValue)
    self.VerticalBlurMat:setFloat("u_Strength", verValue)
    local scaleIns = self.attrs:GetVal("ADBE_Scale_0_4", AEprogress)[1] / 100

    self.SomePassMat:setFloat("scaleIns", scaleIns)

    local exposureIns = self.attrs:GetVal("ADBE_IE_5a1ff1b7caffac514aaba44-0001_0_3", AEprogress)[1]
    self.ExposureMat:setFloat("u_Intensity", exposureIns)

    local function remap(dmin, dmax, value)
        return value * (dmax - dmin) + dmin
    end
    local intensityq = self.attrs:GetVal("ADBE_IE_adc0d88f4eea75689279588-0001_0_2", AEprogress)[1]/100
    --Amaz.LOGI("scaleIns",scaleIns)
    local intensity = intensityq * 0.5 + 0.5;
    if intensity >= 0.5 then
        self.bhmaterial:setFloat("saturation", remap(1.0, 1.48, (intensity - 0.5) / 0.5))
        self.bhmaterial:setFloat("center", 0.5 + 0.001)
        self.bhmaterial:setFloat("sParamR", 0.24)
        self.bhmaterial:setFloat("sParamG", 0.14)
        self.bhmaterial:setFloat("sParamB", 0.17)
    else
        self.bhmaterial:setFloat("saturation", remap(0.65, 1.0, intensity / 0.5))
        self.bhmaterial:setFloat("center", 0.44 + 0.001)
        self.bhmaterial:setFloat("sParamR", 0)
        self.bhmaterial:setFloat("sParamG", 0)
        self.bhmaterial:setFloat("sParamB", 0)
    end

    local intensitys = self.attrs:GetVal("ADBE_IE_bd05021dc9663a44921852b-0001_0_1", AEprogress)[1]/100
    local intensitysta = (intensitys * 0.5 + 0.5) * 100
    self.satmaterial:setFloat("sat", intensitysta)





--     local propsq = comp.entity:getComponent("ScriptComponent").properties
--     if propsq:has("intensity") then
--         self.intensity = propsq:get("intensity")
--     end

--   self.stascript:set("intensity",intensity)

    

end



function SeekModeScript:setParams(name, value)
    if name == "u_size" then
        -- local bgAspect = value.x / value.y
        -- local videoAspect = value.z / value.w
        -- if bgAspect > videoAspect then
        --     self.scaleCorrect = value.w / value.y
        -- else
        --     self.scaleCorrect = value.z / value.x
        -- end
        -- self.videoMat:setVec4("u_size", value)
        -- self.modelMat:setVec4("u_size", value)
        local FBS = Amaz.Vector2f(value.x, value.y)
        self.fxaaMat:setVec2("FBS", FBS)
        self.blendMat:setVec4("u_size", value)
    elseif name == "u_pos" then
        -- self.videoMat:setVec2("u_pos", value)
        -- self.blendMat:setVec2("u_pos", value)
        self.userPosition:set(value.x, value.y, 0)
    elseif name == "u_angle" then
        -- self.videoMat:setFloat("u_angle", value)
        -- self.blendMat:setFloat("u_angle", value)
        self.userEulerAngle:set(0, 0, value / math.pi * 180)
    elseif name == "u_scale" then
        -- self.videoMat:setFloat("u_scale", value)
        -- self.blendMat:setFloat("u_scale", value * self.scaleCorrect)
        self.userScale:set(value, value, 1)
    elseif name == "u_flipX" then
        self.videoMat:setFloat("u_flipX", value)
    elseif name == "u_flipY" then
        self.videoMat:setFloat("u_flipY", value)
    elseif name == "_alpha" then
        self.blendMat:setFloat("_alpha", value)
    end
end

function SeekModeScript:setDuration(duration)
    self.duration = duration
end

exports.SeekModeScript = SeekModeScript
return exports
