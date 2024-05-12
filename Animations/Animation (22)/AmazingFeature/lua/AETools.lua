local AETools = AETools or {}     ---@class AETools
AETools.__index = AETools

function AETools:new(frameRate)
    local self = setmetatable({}, AETools)
    self.key_frame_info = {}
    self.frameRate = frameRate == nil and 25 or frameRate
    return self
end

function AETools:addKeyFrameInfo(in_val, out_val, frame, val)
    local key_frame_count = #self.key_frame_info
    if key_frame_count == 0 and frame > 0 then
        self.key_frame_info[key_frame_count + 1] = {
            ["v_in"] = in_val,
            ["v_out"] = out_val,
            ["cur_frame"] = 0,
            ["value"] = val
        }
    end

    key_frame_count = #self.key_frame_info
    self.key_frame_info[key_frame_count + 1] = {
        ["v_in"] = in_val,
        ["v_out"] = out_val,
        ["cur_frame"] = frame,
        ["value"] = val
    }
    self:_updateKeyFrameInfo()
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

function AETools:_updateKeyFrameInfo()
    if self.key_frame_info and #self.key_frame_info > 0 then
        self.finish_frame_time = self.key_frame_info[#self.key_frame_info]["cur_frame"]
    end
end

function AETools._getDiff(val1, val2)
    local res = nil
    if type(val1) == "table" then
        local tmp_sum = 0
        -- for i = 1, #val1 do
        --     local tmp_v = math.abs(val1[i]-val2[i])
        --     tmp_sum = tmp_sum + tmp_v * tmp_v
        -- end
        -- res = math.sqrt(tmp_sum)
        for i = 1, #val1 do
            local tmp_v = math.abs(val1[i]-val2[i])
            tmp_sum = tmp_sum + tmp_v
        end
        res = tmp_sum/#val1
    else
        res = math.abs(val1-val2)
    end
    return res
end

function AETools._getAverage(val1, val2, duration)
    local res = nil
    if type(val1) == "table" then
        local tmp_sum = 0
        for i = 1, #val1 do
            local tmp_v = math.abs(val1[i]-val2[i])
            tmp_v = tmp_v/duration
            tmp_sum = tmp_sum + tmp_v * tmp_v
        end
        res = math.sqrt(tmp_sum)
    else
        res = math.abs(val1-val2)
        res = res/duration
    end
    return res + 0.000001
end


function AETools:getCurPartVal(_progress, hard_cut)
    
    local part_id, part_progress = self:_getCurPart(_progress)

    local frame1 = self.key_frame_info[part_id-1]
    local frame2 = self.key_frame_info[part_id]

    if hard_cut == true then
        return frame1["value"]
    end

    local info1 = frame1["v_out"]
    local info2 = frame2["v_in"]

    info1[2] = info1[2] < 0.011 and 0 or info1[2]
    info2[2] = info2[2] < 0.011 and 0 or info2[2]

    local duration = (frame2["cur_frame"]-frame1["cur_frame"])/self.frameRate
    local diff = self._getDiff(frame1["value"], frame2["value"])
    -- Amaz.LOGI("lrc duration", duration)

    local average = diff/duration + 0.0001
    -- Amaz.LOGI("lrc average1", average)
    -- average = self._getAverage(frame1["value"], frame2["value"], duration)
    -- Amaz.LOGI("lrc average2", average)

    local x1 = info1[2]/100
    local y1 = x1*info1[1]/average
    local x2 = 1-info2[2]/100
    local y2 = 1-(1-x2)*info2[1]/average

    -- Amaz.LOGI("lrc x1", x1)
    -- Amaz.LOGI("lrc y1", y1)
    -- Amaz.LOGI("lrc x2", x2)
    -- Amaz.LOGI("lrc y2", y2)
    -- Amaz.LOGI("lrc average", x1*info1[1])

    -- Amaz.LOGI("lrc info1[1]", info1[1])
    -- Amaz.LOGI("lrc info1[2]", info1[2])
    -- Amaz.LOGI("lrc info2[1]", info2[1])
    -- Amaz.LOGI("lrc info2[2]", info2[2])

    local res = nil
    if type(frame1["value"]) == "number" then
        if frame1["value"] > frame2["value"] then
            x1 = info1[2]/100
            y1 = -x1*info1[1]/average
            x2 = info2[2]/100
            y2 = 1+x2*info2[1]/average
            x2 = 1-x2
            if(x1 < 0.0002)then y1 = 0 end
            if(y2 < 0.0002)then y2 = 0 end
        end
        local bezier_val = {x1, y1, x2, y2}
        local progress = self:_cubicBezier01(bezier_val, part_progress)

        res = self._mix(frame1["value"], frame2["value"], progress)
    else
        res = {}
        local bezier_val = {x1, y1, x2, y2}
        for i = 1, #frame1["value"] do
            if frame1["value"][i] > frame2["value"][i] then
                x1 = info1[2]/100
                y1 = -x1*info1[1]/average
                x2 = info2[2]/100
                y2 = 1+x2*info2[1]/average
                x2 = 1-x2
            end
            bezier_val = {x1, y1, x2, y2}
            local progress = self:_cubicBezier01(bezier_val, part_progress)

            res[i] = self._mix(frame1["value"][i], frame2["value"][i], progress)
        end

        -- Amaz.LOGI("lrc 1", bezier_val[1])
        -- Amaz.LOGI("lrc 2", bezier_val[2])
        -- Amaz.LOGI("lrc 3", bezier_val[3])
        -- Amaz.LOGI("lrc 4", bezier_val[4])
    end
    return res

end

function AETools:_getCurPart(progress)
    if progress > 0.999 then
        return #self.key_frame_info, 1
    end

    for i = 1, #self.key_frame_info do
        local info = self.key_frame_info[i]
        if progress < info["cur_frame"]/self.finish_frame_time then
            return i, self._remap01(
                self.key_frame_info[i-1]["cur_frame"]/self.finish_frame_time,
                self.key_frame_info[i]["cur_frame"]/self.finish_frame_time,
                progress
            )
        end
    end
end

function AETools:clear()
    self.key_frame_info = {}
    self:_updateKeyFrameInfo()
end

function AETools:test()
    Amaz.LOGI("lrc "..tostring(self.key_frame_info), tostring(#self.key_frame_info))
end

return AETools