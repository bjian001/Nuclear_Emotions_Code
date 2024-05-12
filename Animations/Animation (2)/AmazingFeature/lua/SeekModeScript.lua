local util = nil    ---@class Util

local exports = exports or {}
local SeekModeScript = SeekModeScript or {}
SeekModeScript.__index = SeekModeScript
---@class SeekModeScript : ScriptComponent
---@field _duration number
---@field progress number [UI(Range={0, 1}, Slider)]
---@field autoplay boolean

local ae_attribute = {
	["ADBE_IE_f27e10b94d011bf31c57ec1_0002_0_0"]={
		{{0.33, 0, 0.57, 1, }, {0, 19, }, {{0, }, {33, }, }, {6417, }, {0, }, }, 
	}, 
	["S_DistortChroma_0050_0_1"]={
		{{0.771465302, 0, 0.83299779, 1, }, {0, 19, }, {{0, }, {-0.4, }, }, {6417, }, {0, }, }, 
	}, 
	["S_DistortChroma_0052_0_2"]={
		{{0.166666667, 0.166666667, 0.833333333, 0.833333333, }, {0, 23, }, {{-33, }, {33, }, }, {6417, }, {1, }, }, 
	}, 
	["ADBE_IE_92959d1fb849aa97f8ff858_0001_0_3"]={
		{{0.630364351, 0, 0.886520794, 1, }, {0, 22, }, {{0, }, {10, }, }, {6417, }, {0, }, }, 
		{{0.166666667, 0, 0.833333333, 0, }, {22, 23, }, {{10, }, {10, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_IE_92959d1fb849aa97f8ff858_0004_0_4"]={
		{{0.542112361, 0, 0.999, 1, }, {0, 22, }, {{720, }, {1320, }, }, {6417, }, {0, }, }, 
		{{0.166666667, 0, 0.833333333, 1, }, {22, 23, }, {{1320, }, {1380, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_WRPMESH_0003_0_5"]={
		{{0.431429525, 0, 0.792673518, 1, }, {0, 7, }, {{0, }, {-5, }, }, {6417, }, {0, }, }, 
		{{0.36, 0, 0.73, 1, }, {7, 15, }, {{-5, }, {22, }, }, {6417, }, {0, }, }, 
		{{0.383248256, 0, 0.85815665, 0.640685086, }, {15, 22, }, {{22, }, {-29.352174, }, }, {6417, }, {0, }, }, 
		{{0.001, 0, 0.4, 1, }, {22, 23, }, {{-29.352174, }, {-33.352174, }, }, {6417, }, {0, }, }, 
	}, 
	["PEDG_0002_0_6"]={
		{{0.466975552, 0, 0.846636251, 1, }, {4, 20, }, {{0, }, {0.2, }, }, {6417, }, {0, }, }, 
		{{0.316323201, 0, 0.820092161, 0.504965577, }, {20, 22, }, {{0.2, }, {0.15, }, }, {6417, }, {0, }, }, 
		{{0.001, 0, 0.52, 1, }, {22, 23, }, {{0.15, }, {0.13, }, }, {6417, }, {0, }, }, 
	}, 
}

local AETools = AETools or {}
AETools.__index = AETools

local function deepcopy(orig)
    local copy
    if type(orig) == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        -- setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function AETools.new(attrs)
    local self = setmetatable({}, AETools)
    self.attrs = attrs

    local max_frame = 0
    local min_frame = 100000
    for _,v in pairs(attrs) do
        for i = 1, #v do
            local content = v[i]
            local cur_frame_min = content[2][1]
            local cur_frame_max = content[2][2]
            max_frame = math.max(cur_frame_max, max_frame)
            min_frame = math.min(cur_frame_min, min_frame)

            if content[4] ~= nil and content[5] ~= nil and (content[4][1] == 6413 or content[4][1] == 6415) and content[5][1] == 0 then
                local p0 = content[3][1]
                local totalLen = 0
                local lenInfo = {}
                lenInfo[0] = 0
                for test=1,200,1 do
                    local coord = self._cubicBezier3D(content[3][1], content[3][3], content[3][4], content[3][2], test/200)
                    local length = math.sqrt((coord[1]-p0[1])*(coord[1]-p0[1])+(coord[2]-p0[2])*(coord[2]-p0[2]))
                    p0 = coord
                    totalLen = totalLen + length
                    lenInfo[test] = totalLen
                    -- print(test/200 .. " coord: "..coord[1].." - "..coord[2])
                end
                for test=1,200,1 do
                    lenInfo[test] = lenInfo[test]/(lenInfo[200]+0.000001)
                    -- print(test/200 .. "  "..lenInfo[test])
                end
                content['lenInfo'] = lenInfo
            end
        end
    end

    self.all_frame = max_frame - min_frame
    self.min_frame = min_frame

    return self
end

function AETools:CurFrame(_p)
    local frame = math.floor(_p*self.all_frame)
    return frame + self.min_frame
end

function AETools:AllFrame(_p)
    return self.all_frame
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

function AETools._cubicBezier3D(p1, p2, p3, p4, t)
    if #p1 >= 3 then
        return {
            p1[1]*(1.-t)*(1.-t)*(1.-t) + 3*p2[1]*(1.-t)*(1.-t)*t + 3*p3[1]*(1.-t)*t*t + p4[1]*t*t*t,
            p1[2]*(1.-t)*(1.-t)*(1.-t) + 3*p2[2]*(1.-t)*(1.-t)*t + 3*p3[2]*(1.-t)*t*t + p4[2]*t*t*t,
            p1[3]*(1.-t)*(1.-t)*(1.-t) + 3*p2[3]*(1.-t)*(1.-t)*t + 3*p3[3]*(1.-t)*t*t + p4[3]*t*t*t,
        }
    else
        return {
            p1[1]*(1.-t)*(1.-t)*(1.-t) + 3*p2[1]*(1.-t)*(1.-t)*t + 3*p3[1]*(1.-t)*t*t + p4[1]*t*t*t,
            p1[2]*(1.-t)*(1.-t)*(1.-t) + 3*p2[2]*(1.-t)*(1.-t)*t + 3*p3[2]*(1.-t)*t*t + p4[2]*t*t*t,
            0,
        }
    end
end

function AETools:_cubicBezierSpatial(lenInfo, p1, p2, p3, p4, t)
    local p = 0
    if t <= 0 then
        p = 0
    elseif t >= 1 then
        p = 1
    else
        local ts = 0
        local te = 200
        for i=1,200,1 do
            if lenInfo[i] >= t then
                te = i
                ts = i-1
                break
            end
        end
        p = ts/200. + 0.005*(t-lenInfo[ts])/(lenInfo[te]-lenInfo[ts]+0.000001)
    end
    return self._cubicBezier3D(p1, p2, p3, p4, p)
end

function AETools:_cubicBezier01(_bezier_val, p, y_len)
    local x = self:_getBezier01X(_bezier_val, p, y_len)
    return self._cubicBezier(
        {0,0},
        {_bezier_val[1], _bezier_val[2]},
        {_bezier_val[3], _bezier_val[4]},
        {1, y_len},
        x
    )[2]
end

function AETools:_getBezier01X(_bezier_val, x, y_len)
    local ts = 0
    local te = 1
    -- divide and conque
    local times = 1
    repeat
        local tm = (ts+te)*0.5
        local value = self._cubicBezier(
            {0,0},
            {_bezier_val[1], _bezier_val[2]},
            {_bezier_val[3], _bezier_val[4]},
            {1, y_len},
            tm)
        if(value[1]>x) then
            te = tm
        else
            ts = tm
        end
        times = times +1
    until(te-ts < 0.001 and times < 50)

    return (te+ts)*0.5
end

function AETools._mix(a, b, x, type)
    if type == 1 then
        return a * (1-x) + b * x
    else
        return a + x
    end
end

function AETools:GetVal(_name, _progress)
    local content = self.attrs[_name]
    if content == nil then
        return nil
    end

    local cur_frame = _progress * self.all_frame + self.min_frame

    for i = 1, #content do
        local info = content[i]
        local start_frame = info[2][1]
        local end_frame = info[2][2]
        if cur_frame >= start_frame and cur_frame < end_frame then
            local cur_progress = self._remap01(start_frame, end_frame, cur_frame)
            local bezier = info[1]
            local value_range = info[3]
            local y_len = 1
            if (value_range[2][1] == value_range[1][1] and info[5] and info[5][1]==0 and #(value_range[1])==1) then
                y_len = 0
            end

            if #bezier > 4 then
                -- currently scale attrs contains more than 4 bezier values
                local res = {}
                for k = 1, 3 do
                    local cur_bezier = {bezier[k], bezier[k+3], bezier[k+3*2], bezier[k+3*3]}
                    local p = self:_cubicBezier01(cur_bezier, cur_progress, y_len)
                    res[k] = self._mix(value_range[1][k], value_range[2][k], p, y_len)
                end
                return res

            else
                local p = self:_cubicBezier01(bezier, cur_progress, y_len)
                if info[4] ~= nil and info[5] ~= nil and (info[4][1] == 6413 or info[4][1] == 6415) and info[5] and info[5][1] == 0 then
                    local coord = self:_cubicBezierSpatial(info['lenInfo'],
                                                            value_range[1], 
                                                            value_range[3], 
                                                            value_range[4], 
                                                            value_range[2], 
                                                            p)
                    return coord
                end

                if type(value_range[1]) == "table" then
                    local res = {}
                    for j = 1, #value_range[1] do
                        res[j] = self._mix(value_range[1][j], value_range[2][j], p, y_len)
                    end
                    return res
                end
                return self._mix(value_range[1], value_range[2], p, y_len)
            end
        end
    end

    local first_info = content[1]
    local start_frame = first_info[2][1]
    if cur_frame<start_frame then
        return deepcopy(first_info[3][1])
    end

    local last_info = content[#content]
    local end_frame = last_info[2][2]
    if cur_frame>=end_frame then
        return deepcopy(last_info[3][2])
    end

    return nil
end

local function remap(smin, smax, dmin, dmax, value)
	return (value - smin) / (smax - smin) * (dmax - dmin) + dmin
end

local function anchor(pivot, anchor, halfWidth, halfHeight, translate, rotate, scale)
	local anchor = Amaz.Vector4f(
		remap(-.5, .5, 1, -1, pivot[1]) * halfWidth + remap(-.5, .5, -(1 - scale.x), 1 - scale.x, anchor[1]) * halfWidth,
		remap(-.5, .5, 1, -1, pivot[2]) * halfHeight + remap(-.5, .5, -(1 - scale.y), 1 - scale.y, anchor[2]) * halfHeight,
		0,
		1
	)
	local mat = Amaz.Matrix4x4f()
	mat:setTRS(
		Amaz.Vector3f(
			remap(-.5, .5, -1, 1, pivot[1]) * halfWidth,
			remap(-.5, .5, -1, 1, pivot[2]) * halfHeight,
			0
		),
		Amaz.Quaternionf.eulerToQuaternion(Amaz.Vector3f(rotate.x / 180 * math.pi, rotate.y / 180 * math.pi, rotate.z / 180 * math.pi)),
		Amaz.Vector3f(1, 1, 1)
	)
	anchor = mat:multiplyVector4(anchor)
	return Amaz.Vector3f(anchor.x, anchor.y, anchor.z) + translate, rotate, scale
end

local util = {}     ---@class Util
local json = cjson.new()
local rootDir = nil
local record_t = {}

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

local function changeVec2ToTable(val)
    return {val.x, val.y}
end

local function changeVec3ToTable(val)
    return {val.x, val.y, val.z}
end

local function changeVec4ToTable(val)
    return {val.x, val.y, val.z, val.w}
end

local function changeCol3ToTable(val)
    return {val.r, val.g, val.b}
end

local function changeCol4ToTable(val)
    return {val.r, val.g, val.b, val.a}
end

local function changeTable2Vec4(t)
    return Amaz.Vector4f(t[1], t[2], t[3], t[4])
end

local function changeTable2Vec3(t)
    return Amaz.Vector3f(t[1], t[2], t[3])
end

local function changeTable2Vec2(t)
    return Amaz.Vector2f(t[1], t[2])
end

local function changeTable2Col3(t)
    return Amaz.Color(t[1], t[2], t[3])
end

local function changeTable2Col4(t)
    return Amaz.Color(t[1], t[2], t[3], t[4])
end

local _typeSwitch = {
    ["vec4"] = function(v)
        return changeVec4ToTable(v)
    end,
    ["vec3"] = function(v)
        return changeVec3ToTable(v)
    end,
    ["vec2"] = function(v)
        return changeVec2ToTable(v)
    end,
    ["float"] = function(v)
        return tonumber(v)
    end,
    ["string"] = function(v)
        return tostring(v)
    end,
    ["col3"] = function(v)
        return changeCol3ToTable(v)
    end,
    ["col4"] = function(v)
        return changeCol4ToTable(v)
    end,

    -- change table to userdata
    ["_vec4"] = function(v)
        return changeTable2Vec4(v)
    end,
    ["_vec3"] = function(v)
        return changeTable2Vec3(v)
    end,
    ["_vec2"] = function(v)
        return changeTable2Vec2(v)
    end,
    ["_float"] = function(v)
        return tonumber(v)
    end,
    ["_string"] = function(v)
        return tostring(v)
    end,
    ["_col3"] = function(v)
        return changeTable2Col3(v)
    end,
    ["_col4"] = function(v)
        return changeTable2Col4(v)
    end,
}

local function typeSwitch()
    return _typeSwitch
end

local function createTableContent()
    -- Amaz.LOGI("lrc", "createTableContent")
    local t = {}
    for k,v in pairs(record_t) do
        t[k] = {}
        t[k]["type"] = v["type"]
        t[k]["val"] = v["func"](v["val"])
    end
    return t
end

function util.registerParams(_name, _data, _type)
    record_t[_name] = {
        ["type"] = _type,
        ["val"] = _data,
        ["func"] = _typeSwitch[_type]
    }
end

function util.getRegistedParams()
    return record_t
end

function util.setRegistedVal(_name, _data)
    record_t[_name]["val"] = _data
end

function util.getRootDir()
    if rootDir == nil then
        local str = debug.getinfo(2, "S").source
        rootDir = str:match("@?(.*/)")
    end
    Amaz.LOGI("lrc getRootDir 123", tostring(rootDir))
    return rootDir
end

function util.registerRootDir(path)
    rootDir = path
end

function util.bezier(controls)
    local control = controls
    if type(control) ~= "table" then
        control = changeVec4ToTable(controls)
    end
    return function (t, b, c, d)
        t = t/d
        local tvalue = getBezierTfromX(control, t)
        local value =  getBezierValue(control, tvalue)
        return b + c * value[2]
    end
end

function util.remap01(a,b,x)
    if x < a then return 0 end
    if x > b then return 1 end
    return (x-a)/(b-a)
end

function util.mix(a, b, x)
    return a * (1-x) + b * x
end

function util.CreateJsonFile(file_path)
    local t = createTableContent()
    local content = json.encode(t)
    local file = io.open(util.getRootDir()..file_path, "w+b")
    if file then
      file:write(tostring(content))
      io.close(file)
    end
end

function util.ReadFromJson(file_path)
    local file = io.input(util.getRootDir()..file_path)
    local json_data = json.decode(io.read("*a"))
    local res = {}
    for k, v in pairs(json_data) do
        local func = _typeSwitch["_"..tostring(v["type"])]
        res[k] = func(v["val"])
    end
    return res
end

function util.bezierWithParams(input_val_4, min_val, max_val, in_val, reverse)
    if type(input_val_4) == "tabke" then
        if reverse == nil then
            return util.bezier(input_val_4)(util.remap01(min_val, max_val, in_val), 0, 1, 1)
        else
            return util.bezier(input_val_4)(1-util.remap01(min_val, max_val, in_val), 0, 1, 1)
        end
    else
        if reverse == nil then
            return util.bezier(util.changeVec4ToTable(input_val_4))(util.remap01(min_val, max_val, in_val), 0, 1, 1)
        else
            return util.bezier(util.changeVec4ToTable(input_val_4))(1-util.remap01(min_val, max_val, in_val), 0, 1, 1)
        end
    end
end

function SeekModeScript.new(construct, ...)
    local self = setmetatable({}, SeekModeScript)

    if construct and SeekModeScript.constructor then SeekModeScript.constructor(self, ...) end

    self.progress = 0
    self.curTime = 0
    self.startTime = 0
    self._duration = 3
    self.autoplay = true

    self.playDuration = 2

    self.ins = 0

	self.cur_frame = 0
    self.first = true

    return self
end

function SeekModeScript:constructor()
end

function SeekModeScript:_adapt_onStart(comp)
    self.curTime = 0
    self.duration = 2.0
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
end

function SeekModeScript:onStart(comp)
    self:_adapt_onStart(comp)
    if Amaz.Macros and Amaz.Macros.EditorSDK then
    else
    end
    self.attrs = AETools.new(ae_attribute)
    self.propBlur = comp.entity.scene:findEntityBy("Gaussian_Blur_Root"):getComponent("ScriptComponent").properties
    self.propChroma = comp.entity.scene:findEntityBy("DistortChroma"):getComponent("ScriptComponent").properties
    self.propDisplacement = comp.entity.scene:findEntityBy("TurbulenceDisplacement"):getComponent("ScriptComponent").properties
    self.propDeform = comp.entity.scene:findEntityBy("Deform_Root"):getComponent("ScriptComponent").properties
    self.propGlow = comp.entity.scene:findEntityBy("Deep_Glow_Root"):getComponent("ScriptComponent").properties
end

function SeekModeScript:autoPlay(time)
    if Amaz.Macros and Amaz.Macros.EditorSDK then
        if self.autoplay then
            self.progress = time % self._duration / self._duration
        end
    else
        -- self.duration = self.endTime - self.startTime
        -- self.progress = time % self.duration / self.duration
        self.progress = math.mod(time/(self.duration+0.0001), 1)
    end
end

if Amaz.Macros and Amaz.Macros.EditorSDK then
    function SeekModeScript:onUpdate(comp, detalTime)
        self.blendMat:enableMacro("AMAZING_EDITOR_DEV", 1)
        self.modelMat:enableMacro("AMAZING_EDITOR_DEV", 1)

        self.lastTime = self.curTime
        self.curTime = self.curTime + detalTime
        self:autoPlay(self.curTime)
        self:seek(self.curTime - self.startTime)
    end
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
    -- if self.first then
    --     self.first = false
    --     self.scriptBlur = Amaz.ScriptUtils.getLuaObj(self.scriptCompBlur:getScript())
    --     self.scriptChroma = Amaz.ScriptUtils.getLuaObj(self.scriptCompChroma:getScript())
    --     self.scriptDisplacement = Amaz.ScriptUtils.getLuaObj(self.scriptCompDisplacement:getScript())
    --     self.scriptDeform = Amaz.ScriptUtils.getLuaObj(self.scriptCompDeform:getScript())
    --     self.scriptGlow = Amaz.ScriptUtils.getLuaObj(self.scriptCompGlow:getScript())
    -- end    
    
    self:_adapt_seek(time)
    self:autoPlay(time)

    local w = Amaz.BuiltinObject.getInputTextureWidth()
    local h = Amaz.BuiltinObject.getInputTextureHeight()
    local intensityBlur = self.attrs:GetVal("ADBE_IE_f27e10b94d011bf31c57ec1_0002_0_0", self.progress)[1]
    local amountChroma = self.attrs:GetVal("S_DistortChroma_0050_0_1", self.progress)[1] / (-.4) * (-.22)
    local angleChroma = self.attrs:GetVal("S_DistortChroma_0052_0_2", self.progress)[1]
    local intensityDisplacement = self.attrs:GetVal("ADBE_IE_92959d1fb849aa97f8ff858_0001_0_3", self.progress)[1] / 100.
    local evolutionDisplacement = self.attrs:GetVal("ADBE_IE_92959d1fb849aa97f8ff858_0004_0_4", self.progress)[1]
    local twistDeform = self.attrs:GetVal("ADBE_WRPMESH_0003_0_5", self.progress)[1]
    local exposureGlow = self.attrs:GetVal("PEDG_0002_0_6", self.progress)[1] / .2 * .3
    self.propBlur:set("intensity", intensityBlur)
    self.propChroma:set("amount", amountChroma)
    self.propChroma:set("angle", angleChroma)
    self.propDisplacement:set("size", intensityDisplacement)
    self.propDisplacement:set("evolution", evolutionDisplacement)
    self.propDeform:set("twist", twistDeform)
    self.propGlow:set("glow_intensity", exposureGlow)
    -- if self.scriptBlur == nil then
    --     self.scriptBlur = Amaz.ScriptUtils.getLuaObj(self.scriptCompBlur:getScript())
    -- else
    --     self.scriptBlur.intensity = intensityBlur
    -- end
    -- if self.scriptChroma == nil then
    --     self.scriptChroma = Amaz.ScriptUtils.getLuaObj(self.scriptCompChroma:getScript())
    -- else
    --     self.scriptChroma.amount = amountChroma
    --     self.scriptChroma.angle = angleChroma
    -- end
    -- if self.scriptDisplacement == nil then
    --     self.scriptDisplacement = Amaz.ScriptUtils.getLuaObj(self.scriptCompDisplacement:getScript())
    -- else
    --     self.scriptDisplacement.size = intensityDisplacement
    --     self.scriptDisplacement.evolution = evolutionDisplacement
    -- end
    -- if self.scriptDeform == nil then
    --     self.scriptDeform = Amaz.ScriptUtils.getLuaObj(self.scriptCompDeform:getScript())
    -- else
    --     self.scriptDeform.twist = twistDeform
    -- end
    -- if self.scriptGlow == nil then
    --     self.scriptGlow = Amaz.ScriptUtils.getLuaObj(self.scriptCompGlow:getScript())
    -- else
    --     self.scriptGlow.glow_intensity = exposureGlow
    -- end
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
