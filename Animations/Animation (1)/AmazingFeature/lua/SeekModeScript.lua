local util = nil    ---@class Util

local exports = exports or {}
local SeekModeScript = SeekModeScript or {}
SeekModeScript.__index = SeekModeScript
---@class SeekModeScript : ScriptComponent
---@field _duration number
---@field progress number [UI(Range={0, 1}, Slider)]
---@field autoplay boolean



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

function util.test()
    Amaz.LOGI("lrc", "test123")
end

local ae_attribute = {
	["ADBE_Displacement_Map_0003_0_0"]={
		-- {{0.59444123, 0.038346636, 0.702173878, 0.849760499, }, {0, 30, }, {{-666, }, {-7.302783, }, }, {6417, }, {0, }, }, 
		-- {{0.198582245, 0.741699503, 0.688114094, 1, }, {30, 35, }, {{-7.302783, }, {0, }, }, {6417, }, {0, }, }, 
		-- {{0.166666667, 0, 0.688114094, 0, }, {35, 58, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.311885906, 0, 0.8050534, 0.5790522, }, {0, 4, }, {{0, }, {12, }, }, {6417, }, {0, }, }, 
		{{0.172249323, 0.068293066, 0.403455918, 0.954785836, }, {4, 27, }, {{12, }, {666, }, }, {6417, }, {0, }, }, 
		{{0.172249323, 0.068293066, 0.403455918, 0.954785836, }, {27, 28, }, {{666, }, {666, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_Displacement_Map_0005_0_1"]={
		-- {{0.602851609, 2.0557181, 0.776258886, 1.168660064, }, {0, 30, }, {{222, }, {-3.32304, }, }, {6417, }, {0, }, }, 
		-- {{0.143046302, 0.603350686, 0.61520003, 1, }, {30, 35, }, {{-3.32304, }, {0, }, }, {6417, }, {0, }, }, 
		-- {{0.166666667, 0, 0.61520003, 0, }, {35, 58, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.38479997, 0, 0.678370434, 0.215615656, }, {0, 4, }, {{0, }, {10, }, }, {6417, }, {0, }, }, 
		{{0.112277307, -0.074674562, 0.218522569, -1.48679911, }, {4, 27, }, {{10, }, {-222, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_Scale_1_2"]={
		-- {{0.001,0.001,0.001, 0,0,0.001, 0.8,0.8,0.8, 1,1,0.8, }, {0, 33, }, {{20, 80, 100, }, {100, 100, 100, }, }, {6414, }, {0, }, }, 
		-- {{0.257111153,0.257111153,0.257111153, 0.257111153,0.257111153,0.257111153, 0.596487732,0.596487732,0.596487732, 0.596487732,0.596487732,0.596487732, }, {33, 35, }, {{100, 100, 100, }, {100, 100, 100, }, }, {6414, }, {0, }, }, 
		-- {{0.250212435,0.250212435,0.250212435, 0.250212435,0.250212435,0.250212435, 0.808682671,0.808682671,0.808682671, 0.808682671,0.808682671,0.808682671, }, {35, 60, }, {{100, 100, 100, }, {100, 100, 100, }, }, {6414, }, {0, }, }, 
		{{0.2,0.2,0.2, 0,0,0.2, 0.999,0.999,0.999, 1,1,0.999, }, {2, 27, }, {{100, 100, 100, }, {20, 80, 100, }, }, {6414, }, {0, }, }, 
	}, 
    ["ADBE_Displacement_Map_0003_0_0_1"]={
		-- {{0.459012036, 0.010923745, 0.813447186, 0.640021984, }, {0, 21, }, {{-1000, }, {-426.071155, }, }, {6417, }, {0, }, }, 
		-- {{0.341257894, 0.474339598, 0.766356332, 0.941376113, }, {21, 32, }, {{-426.071155, }, {-6, }, }, {6417, }, {0, }, }, 
		-- {{0.001, 0, 0.999, 1, }, {32, 35, }, {{-6, }, {0, }, }, {6417, }, {0, }, }, 
		-- {{0.166666667, 0, 0.999, 0, }, {35, 58, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.001, 0, 0.75009458, 0.22813083, }, {0, 1, }, {{0, }, {8, }, }, {6417, }, {0, }, }, 
		{{0.235921888, 0.085211005, 0.690277081, 0.680460618, }, {1, 10, }, {{8, }, {455, }, }, {6417, }, {0, }, }, 
		{{0.179723423, 0.307802401, 0.540987964, 1.009312424, }, {10, 27, }, {{455, }, {1000, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_Displacement_Map_0005_0_1_1"]={
		-- {{0.357639083, 0, 0.975519397, 0.600340498, }, {0, 19, }, {{666, }, {345.036058, }, }, {6417, }, {0, }, }, 
		-- {{0.07790155, 0.777910276, 0.503649724, 1, }, {19, 27, }, {{345.036058, }, {-40.382537, }, }, {6417, }, {0, }, }, 
		-- {{0.536082503, 0, 0.797542208, 0.802907484, }, {27, 32, }, {{-40.382537, }, {-6, }, }, {6417, }, {0, }, }, 
		-- {{0.18482337, 0.642836715, 0.999, 1, }, {32, 35, }, {{-6, }, {0, }, }, {6417, }, {0, }, }, 
		-- {{0.166666667, 0, 0.999, 0, }, {35, 58, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.3, 0, 0.657291079, 0.404359586, }, {0, 1, }, {{0, }, {8, }, }, {6417, }, {0, }, }, 
		{{0.238971598, 0.231460695, 0.463917497, 1, }, {1, 5, }, {{8, }, {50, }, }, {6417, }, {0, }, }, 
		{{0.596135604, 0, 0.798736952, 0.128125574, }, {5, 12, }, {{50, }, {-370.024553, }, }, {6417, }, {0, }, }, 
		{{0.025243423, 0.322410895, 0.642360917, 1, }, {12, 27, }, {{-370.024553, }, {-666, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_IE_cfd060d81c820aaffc3cd7c_0001_1_2"]={
		-- {{0.33333333, 0, 0.66666667, 1, }, {0, 22, }, {{100, }, {100, }, }, {6417, }, {0, }, }, 
		-- {{0.33333333, 0, 0.66666667, 1, }, {22, 33, }, {{100, }, {0, }, }, {6417, }, {0, }, }, 
		-- {{0.33333333, 0, 0.66666667, 0, }, {33, 58, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.33333333, 0, 0.66666667, 1, }, {0, 8, }, {{0, }, {100, }, }, {6417, }, {0, }, }, 
	}, 
    ["ADBE_IE_cfd060d81c820aaffc3cd7c_0001_2_4"]={
		-- {{0.33333333, 0, 0.66666667, 1, }, {0, 22, }, {{-100, }, {-100, }, }, {6417, }, {0, }, }, 
		-- {{0.33333333, 0, 0.66666667, 1, }, {22, 33, }, {{-100, }, {0, }, }, {6417, }, {0, }, }, 
		-- {{0.33333333, 0, 0.66666667, 0, }, {33, 58, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
		{{0.33333333, 0, 0.66666667, 1, }, {0, 8, }, {{0, }, {-100, }, }, {6417, }, {0, }, }, 
	}, 
}

local ae_attribute_main = {
	["PEDG_0002_0_0"]={
		{{0.783984184, 0, 0.999, 1, }, {6, 16, }, {{0, }, {9, }, }, {6417, }, {0, }, }, 
		{{0.001, 0, 0.069412846, 0.849412526, }, {16, 27, }, {{9, }, {5, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_Opacity_1_1"]={
		{{0.667507849, 0.044561576, 0.84, 1, }, {11, 16, }, {{0, }, {10, }, }, {6417, }, {0, }, }, 
		{{0.166691794, 0, 0.308019562, 0.963209425, }, {16, 20, }, {{10, }, {0, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_IE_39e22d48461e50e26f1557a_0001_2_2"]={
		{{0.211076016, 0, 0.75, 0.582727273, }, {0, 17, }, {{0, }, {100, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_IE_39e22d48461e50e26f1557a_0002_2_3"]={
		{{0.22, 0.386138614, 0.79, 0.891089109, }, {17, 27, }, {{101, }, {0, }, }, {6417, }, {0, }, },  
		{{0.166666667, 0, 0.833333333, 0, }, {27, 28, }, {{0, }, {0, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_Rotate_Z_3_4"]={
		{{0.345650089, 0, 0.999, 1, }, {0, 27, }, {{0, }, {66, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_IE_2528058df9f12b8e1d3123e_0002_4_5"]={
		{{0.36, 0, 0.48, 1, }, {0, 16, }, {{50, }, {43, }, }, {6417, }, {0, }, }, 
		{{0.001, 0, 0.1, 1, }, {16, 26, }, {{43, }, {50, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_IE_2528058df9f12b8e1d3123e_0003_4_6"]={
		{{0.36, 0, 0.48, 1, }, {0, 16, }, {{50, }, {57, }, }, {6417, }, {0, }, }, 
		{{0.001, 0, 0.1, 1, }, {16, 26, }, {{57, }, {50, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_IE_e4f13d1013029536c197a80_0001_5_7"]={
		{{0.32, 0, 0.29, 0.7734375, }, {2, 27, }, {{0, }, {180, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_Position_0_6_9"]={
		{{0.54, 0, 0.75, 1, }, {0, 7, }, {{540, }, {510, }, }, {6417, }, {0, }, }, 
		{{0.33333333, 0, 0.66666667, 1, }, {7, 17, }, {{510, }, {540, }, }, {6417, }, {0, }, },
	}, 
	["ADBE_Position_1_6_10"]={
		{{0.54, 0, 0.75, 1, }, {0, 7, }, {{540, }, {580, }, }, {6417, }, {0, }, }, 
		{{0.33333333, 0, 0.66666667, 1, }, {7, 17, }, {{580, }, {540, }, }, {6417, }, {0, }, }, 
	}, 
	["ADBE_Scale_6_11"]={
		{{0.667875281,0.212792355,0.31626513, 0,0,0.31626513, 0.804765155,0.683739658,0.669273635, 0.735882027,0.458040875,0.669273635, }, {0, 8, }, {{100, 100, 100, }, {80.503027719, 90.846190189, 100, }, }, {6414, }, {0, }, }, 
		{{0.220477583,0.334790053,0.354507436, 0.348846443,0.30003089,0.354507436, 0.860769668,0.680876591,0.695050271, 0.789234541,0.684575618,0.695050271, }, {8, 13, }, {{80.503027719, 90.846190189, 100, }, {70.820383795, 79, 100, }, }, {6414, }, {0, }, }, 
		{{0.310683462,0.424551103,0.393466904, 0.252730021,0.316191904,0.393466904, 0.79554757,0.822581018,0.737554549, 0.602723639,0.657785417,0.737554549, }, {13, 17, }, {{70.820383795, 79, 100, }, {52.250412184, 62.503027719, 100, }, }, {6414, }, {0, }, }, 
		{{0.155977963,0.257677833,0.333333334, 0.310075694,0.378295481,0.333333334, 0.565321176,0.531706302,0.666666668, 0.713818625,0.719024579,0.666666668, }, {17, 27, }, {{52.250412184, 62.503027719, 100, }, {8, 8, 100, }, }, {6414, }, {0, }, }, 
	}, 
}



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

    self.wave_speed = 2

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
    self.attrs = AETools.new(ae_attribute)
    self.attrsMain = AETools.new(ae_attribute_main)
    self.matBaseDisplace = comp.entity.scene:findEntityBy("PassBaseDisplace"):getComponent("MeshRenderer").material
    self.matLightDisplace = comp.entity.scene:findEntityBy("PassLightDisplace"):getComponent("MeshRenderer").material
    self.matLight = comp.entity.scene:findEntityBy("PassLight"):getComponent("MeshRenderer").material
    self.matTwirl = comp.entity.scene:findEntityBy("PassTwirl"):getComponent("MeshRenderer").material
    self.matStrongSharpPass2 = comp.entity.scene:findEntityBy("StrongSharp"):searchEntity("Pass2"):getComponent("MeshRenderer").material
    self.matCCLens = comp.entity.scene:findEntityBy("CCLens"):getComponent("MeshRenderer").material
    self.matGlowBlend = comp.entity.scene:findEntityBy("Deep_Glow_Root"):searchEntity("Blend"):getComponent("MeshRenderer").material
    self.matGrain = comp.entity.scene:findEntityBy("NoisePass"):getComponent("MeshRenderer").material

    self.propTwirl = comp.entity.scene:findEntityBy("lumi_Twirl"):getComponent("ScriptComponent").properties
    self.propChroma = comp.entity.scene:findEntityBy("StrongSharp"):getComponent("ScriptComponent").properties
    self.propCCLens = comp.entity.scene:findEntityBy("CCLens_Root"):getComponent("ScriptComponent").properties
    self.propDeepGlow = comp.entity.scene:findEntityBy("Deep_Glow_Root"):getComponent("ScriptComponent").properties
    self.propGrain = comp.entity.scene:findEntityBy("lumi_grain"):getComponent("ScriptComponent").properties
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
    self:_adapt_seek(time)
    self:autoPlay(time)

    -- local progress = self.progress --math.min(self.progress,0.999)
    local w = Amaz.BuiltinObject:getInputTextureWidth()
    local h = Amaz.BuiltinObject:getInputTextureHeight()

    local offsetX = self.attrs:GetVal("ADBE_Displacement_Map_0003_0_0", self.progress)[1] / 1080.
    local offsetY = -self.attrs:GetVal("ADBE_Displacement_Map_0005_0_1", self.progress)[1] / 1080.
    local scaleX = self.attrs:GetVal("ADBE_Scale_1_2", self.progress)[1] / 100.
    local scaleY = self.attrs:GetVal("ADBE_Scale_1_2", self.progress)[2] / 100.
    self.matBaseDisplace:setVec2("offset", Amaz.Vector2f(offsetX, offsetY))
    -- Amaz.LOGI("ldrldr", self.progress..' '..scaleX..' '..scaleY)
    self.matBaseDisplace:setVec2("scale", Amaz.Vector2f(scaleX, scaleY))
    self.matLight:setVec2("scale", Amaz.Vector2f(scaleX, scaleY))

    local brightnessLight = self.attrs:GetVal("ADBE_IE_cfd060d81c820aaffc3cd7c_0001_2_4", self.progress)[1] / 100.
    local brightnessDark = self.attrs:GetVal("ADBE_IE_cfd060d81c820aaffc3cd7c_0001_1_2", self.progress)[1] / 100.
    local value = brightnessLight*0.5+0.5
    if value > 0.5 then
        if value < 0.85 then
            value = value * 0.3 + 0.35
        else
            value = value * 0.6333 + 0.0667
        end
    end 
    self.matLight:setFloat("lightLight", (value - .5) * 2.)

    value = brightnessDark*0.5+0.5
    if value > 0.5 then
        if value < 0.85 then
            value = value * 0.3 + 0.35
        else
            value = value * 0.6333 + 0.0667
        end
    end 
    self.matLight:setFloat("lightDark", (value - .5) * 2.)

    offsetX = self.attrs:GetVal("ADBE_Displacement_Map_0003_0_0_1", self.progress)[1] / 1080. * 1.2
    offsetY = -self.attrs:GetVal("ADBE_Displacement_Map_0005_0_1_1", self.progress)[1] / 1080. * 1.2
    self.matLightDisplace:setVec2("offset", Amaz.Vector2f(offsetX, offsetY))

    local angle = self.attrsMain:GetVal("ADBE_IE_e4f13d1013029536c197a80_0001_5_7", self.progress)[1]
    self.propTwirl:set("angle", angle)
    local scaleTwirlX = self.attrsMain:GetVal("ADBE_Scale_6_11", self.progress)[1] / 100.
    local scaleTwirlY = self.attrsMain:GetVal("ADBE_Scale_6_11", self.progress)[2] / 100.
    local scaleTwirl = Amaz.Vector2f(scaleTwirlX, scaleTwirlY)
    offsetX = (self.attrsMain:GetVal("ADBE_Position_0_6_9", self.progress)[1] - 540.) / 1080.
    offsetY = -(self.attrsMain:GetVal("ADBE_Position_1_6_10", self.progress)[1] - 540.) / 1080.
    self.matTwirl:setVec2("scale", scaleTwirl)
    self.matTwirl:setVec2("offset", Amaz.Vector2f(offsetX, offsetY))

    offsetX = self.attrsMain:GetVal("ADBE_IE_2528058df9f12b8e1d3123e_0002_4_5", self.progress)[1] / 100.
    offsetY = self.attrsMain:GetVal("ADBE_IE_2528058df9f12b8e1d3123e_0003_4_6", self.progress)[1] / 100.
    self.propChroma:set("offset_x", offsetX)
    self.propChroma:set("offset_y", offsetY)
    angle = self.attrsMain:GetVal("ADBE_Rotate_Z_3_4", self.progress)[1]
    self.matStrongSharpPass2:setVec2("scale", scaleTwirl)
    self.matStrongSharpPass2:setFloat("angle", angle)
    self.matStrongSharpPass2:setFloat("screenW", w)
    self.matStrongSharpPass2:setFloat("screenH", h)

    local convergence = self.attrsMain:GetVal("ADBE_IE_39e22d48461e50e26f1557a_0001_2_2", self.progress)[1]
    local radius = self.attrsMain:GetVal("ADBE_IE_39e22d48461e50e26f1557a_0002_2_3", self.progress)[1]
    self.propCCLens:set("convergence", convergence)
    self.propCCLens:set("radius", radius)
    local whiteOpacity = self.attrsMain:GetVal("ADBE_Opacity_1_1", self.progress)[1] / 100.
    -- Amaz.LOGI("ldrldr", whiteOpacity)
    self.matCCLens:setFloat("whiteOpacity", whiteOpacity)
    self.matCCLens:setFloat("screenW", w)
    self.matCCLens:setFloat("screenH", h)

    local exposure = self.attrsMain:GetVal("PEDG_0002_0_0", self.progress)[1] * .45
    self.propDeepGlow:set("glow_intensity", exposure)
    self.matGlowBlend:setFloat("satFactor", 1. + 0.5 * math.pow(exposure / 3., .5))
    self.matGrain:setFloat("screenW", w)
    self.matGrain:setFloat("screenH", h)

    self.matTwirl:setFloat("screenW", w)
    self.matTwirl:setFloat("screenH", h)

    if self.progress < .2 then
        self.propGrain:set("saturation", 2.)
    elseif self.progress < .25 then
        self.propGrain:set("saturation", 2. - (self.progress - .2) / .05)
    else
        self.propGrain:set("saturation", 1.)
    end
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
