local isEditor = (Amaz.Macros and Amaz.Macros.EditorSDK) and true or false
local exports = exports or {}
local SeekModeScript = SeekModeScript or {}
SeekModeScript.__index = SeekModeScript
---@class SeekModeScript: ScriptComponent
----@field threshold number
----@field rotate number
----@field randomly number
----@field reverseSort number
----@field triggerType number
----@field sortType number
----@field affectType number
----@field outputType number
----@field featherStart number
----@field featherEnd number
----@field length number
----@field offset number
----@field offsetRandom number
----@field cycle number
----@field randomSeed number
----@field blockSize number
----@field blurSize number
----@field testTime number [UI(Range={0, 3}, Slider)]
function SeekModeScript.new(construct, ...)
    local self = setmetatable({}, SeekModeScript)
    if construct and SeekModeScript.constructor then
        SeekModeScript.constructor(self, ...)
    end
    self.startTime = 0.0
    self.endTime = 3.0
    self.curTime = 0.0
    return self
end

function SeekModeScript:constructor()
end

function SeekModeScript:onUpdate(comp, detalTime)
    self.curTime = self.curTime+detalTime

    self:seekToTime(comp, self.curTime - self.startTime)
    
end

function SeekModeScript:onStart(comp)
    self.w = Amaz.BuiltinObject.getInputTextureWidth()
    self.h = Amaz.BuiltinObject.getInputTextureHeight()
    self.material_mask = comp.entity:getComponent("MeshRenderer").material
    self.material_mask_refine = comp.entity.scene:findEntityBy("renderer_mask_refine"):getComponent("MeshRenderer").material
    self.material_info = comp.entity.scene:findEntityBy("renderer_info"):getComponent("MeshRenderer").material
    self.material_sort = comp.entity.scene:findEntityBy("renderer_sort"):getComponent("MeshRenderer").material
    self.material_rotate = comp.entity.scene:findEntityBy("renderer_rotate"):getComponent("MeshRenderer").material
    self.material_scale = comp.entity.scene:findEntityBy("renderer_scale"):getComponent("MeshRenderer").material

    self.putOriImgMat = comp.entity.scene:findEntityBy("putOriImg"):getComponent("MeshRenderer").material
    self.resultMat = comp.entity.scene:findEntityBy("result"):getComponent("MeshRenderer").material
    self.edgeBlurXMat = comp.entity.scene:findEntityBy("edgeBlurX"):getComponent("MeshRenderer").material
    self.edgeBlurYMat = comp.entity.scene:findEntityBy("edgeBlurY"):getComponent("MeshRenderer").material
    self.blurXMat = comp.entity.scene:findEntityBy("blurX"):getComponent("MeshRenderer").material
    self.blurYMat = comp.entity.scene:findEntityBy("blurY"):getComponent("MeshRenderer").material
    self.imgBlurXMat = comp.entity.scene:findEntityBy("imgBlurX"):getComponent("MeshRenderer").material
    self.imgBlurYMat = comp.entity.scene:findEntityBy("imgBlurY"):getComponent("MeshRenderer").material

    self.maskRT = comp.entity.scene:findEntityBy("edgeMaskCam"):getComponent("Camera").renderTexture
    self.rt0 = comp.entity.scene:findEntityBy("Camera_rotate"):getComponent("Camera").renderTexture
    self.rt1 = comp.entity.scene:findEntityBy("Camera_mask_refine"):getComponent("Camera").renderTexture
    self.rt2 = comp.entity.scene:findEntityBy("Camera_info"):getComponent("Camera").renderTexture
    self.rt3 = comp.entity.scene:findEntityBy("Camera_scale"):getComponent("Camera").renderTexture
    -- self.pass0Material = comp.entity.scene:findEntityBy("strong_sharp_strongSharp_Chro"):searchEntity("renderer_info"):getComponent("MeshRenderer").sharedMaterials:get(0)
    self.input = comp.entity.scene.assetMgr:SyncLoad("share://input.texture")
    -- Amaz.LOGI("asdasd",tostring(self.input))
    self:layout(self.w, self.h)
    self.animSeqComs = comp.entity.scene:findEntityBy("result"):getComponents("AnimSeqComponent")

    self.sortCam0 = comp.entity.scene:findEntityBy("Camera_rotate")
    self.sortCam1 = comp.entity.scene:findEntityBy("Camera_mask")
    self.sortCam2 = comp.entity.scene:findEntityBy("Camera_mask_refine")
    self.sortCam3 = comp.entity.scene:findEntityBy("Camera_info")
    self.sortCam4 = comp.entity.scene:findEntityBy("Camera_sort")
    self.sortCam5 = comp.entity.scene:findEntityBy("Camera_scale")

    self.edgeCam0 = comp.entity.scene:findEntityBy("blurXCam")
    self.edgeCam1 = comp.entity.scene:findEntityBy("blurYCam")
    self.edgeCam2 = comp.entity.scene:findEntityBy("edgeMaskCam")
    self.edgeCam3 = comp.entity.scene:findEntityBy("edgeBlurXCam")
    self.edgeCam4 = comp.entity.scene:findEntityBy("edgeBlurYCam")
end

function SeekModeScript:layout (w, h)
    local size = 256
    self.rt0.width = size
    self.rt0.height = h
    self.rt1.width = size
    self.rt1.height = h
    self.rt2.width = size
    self.rt2.height = h
    self.rt3.width = size
    self.rt3.height = h
end
local function remap(a,b,t1,t2,t)
    local tempT = (t-t1)/(t2-t1)
    return a+(b-a)*tempT
end
function SeekModeScript:seekToTime(comp, time)
    self.edgeCam0.visible = true
    self.edgeCam1.visible = true
    self.edgeCam2.visible = true
    self.edgeCam3.visible = true
    self.edgeCam4.visible = true
    self.blurXMat:setFloat("blurSize",51/16)
    self.blurYMat:setFloat("blurSize",51/16)
    self.edgeBlurXMat:setFloat("blurSize",19/16)
    self.edgeBlurYMat:setFloat("blurSize",19/16)
    self.edgeBlurXMat:setTex("inputImageTexture",self.maskRT)
    self.imgBlurXMat:setFloat("blurSize",0.625)
    self.imgBlurYMat:setFloat("blurSize",0.625)
    if isEditor then
        time = self.testTime
    end
    local adjust_speed = self.resultMat:getFloat("u_speed")
    local fps = time*adjust_speed*30
    fps = math.mod(fps,43)
    self.animSeqComs:get(0):seek(fps)
    Amaz.LOGI("fps",fps)
    local sortVisable = false
    local maskType = 0
    local offsetY =0.0
    if fps< 1 then--0
        sortVisable = true
        self.threshold = remap(1,0.4,0,1,fps)
        maskType = 0
        self.imgBlurXMat:setFloat("blurSize",0)
        self.imgBlurYMat:setFloat("blurSize",0)
        self.animSeqComs:get(1):seek(0)
        self.resultMat:setFloat("lineSucaiIns",1.0)
    elseif fps< 2 then--1
        sortVisable = true
        self.threshold = remap(0.4,0.26,1,2,fps)
        maskType = 0
        offsetY = 560-640
        self.imgBlurXMat:setFloat("blurSize",0)
        self.imgBlurYMat:setFloat("blurSize",0)
        self.animSeqComs:get(1):seek(1)
        self.resultMat:setFloat("lineSucaiIns",1.0)
    elseif fps< 3 then--2
        sortVisable = true
        self.threshold = remap(0.26,0.26,2,3,fps)
        maskType = 0
        offsetY = 675.7-640
        self.imgBlurXMat:setFloat("blurSize",0)
        self.imgBlurYMat:setFloat("blurSize",0)
        self.animSeqComs:get(1):seek(2)
        self.resultMat:setFloat("lineSucaiIns",1.0)
    elseif fps< 4 then--3
        self.imgBlurXMat:setFloat("blurSize",0)
        self.imgBlurYMat:setFloat("blurSize",0.8125)
        sortVisable = false
        self.threshold = 0
        maskType = 0
        offsetY = 623-640
        self.resultMat:setFloat("lineSucaiIns",0.0)
    elseif fps< 11 then-- 4->10
        sortVisable = false
        self.threshold = 0
        maskType = 1
    elseif fps< 13 then-- 11->12
        self.edgeBlurXMat:setFloat("blurSize",1.25)
        self.edgeBlurYMat:setFloat("blurSize",1.25)
        self.blurXMat:setFloat("blurSize",5.8)
        self.blurYMat:setFloat("blurSize",5.8)
        self.edgeBlurXMat:setTex("inputImageTexture",self.input)
        sortVisable = false
        self.threshold = 0
        maskType = 3
    
    elseif fps< 15 then-- 13->14
        self.edgeBlurXMat:setFloat("blurSize",1.25)
        self.edgeBlurYMat:setFloat("blurSize",1.25)
        self.blurXMat:setFloat("blurSize",5.8)
        self.blurYMat:setFloat("blurSize",5.8)
        self.edgeBlurXMat:setTex("inputImageTexture",self.input)
        sortVisable = true
        self.threshold = remap(0.54,0.35,13,15,fps)
        maskType = 3
    elseif fps< 17 then-- 15-16
        self.edgeBlurXMat:setFloat("blurSize",1.25)
        self.edgeBlurYMat:setFloat("blurSize",1.25)
        self.blurXMat:setFloat("blurSize",5.8)
        self.blurYMat:setFloat("blurSize",5.8)
        self.edgeBlurXMat:setTex("inputImageTexture",self.input)
        sortVisable = true
        self.threshold = remap(0.35,0.26,15,17,fps)
        maskType = 2
    elseif fps< 43 then-- 17-42
        self.edgeBlurXMat:setFloat("blurSize",1.25)
        self.edgeBlurYMat:setFloat("blurSize",1.25)
        self.blurXMat:setFloat("blurSize",5.8)
        self.blurYMat:setFloat("blurSize",5.8)
        self.edgeBlurXMat:setTex("inputImageTexture",self.input)
        sortVisable = false
        self.threshold = 0
        maskType = 2
        self.edgeCam0.visible = false
        self.edgeCam1.visible = false
        self.edgeCam2.visible = false
        self.edgeCam3.visible = false
        self.edgeCam4.visible = false
    

    end

    if sortVisable == true then
        self.putOriImgMat:setFloat("flag", 0.0);
        self.sortCam0.visible = true
        -- self.sortCam1.visible = true
        self.sortCam2.visible = true
        self.sortCam3.visible = true
        self.sortCam4.visible = true
        self.sortCam5.visible = true
    else
        self.putOriImgMat:setFloat("flag", 1.0);
        self.sortCam0.visible = false
        -- self.sortCam1.visible = false
        self.sortCam2.visible = false
        self.sortCam3.visible = false
        self.sortCam4.visible = false
        self.sortCam5.visible = false
    end
    
    self.resultMat:setFloat("offsetY", offsetY/1280)
    self.resultMat:setFloat("maskType", maskType)
    local w = Amaz.BuiltinObject.getInputTextureWidth()
    local h = Amaz.BuiltinObject.getInputTextureHeight()
    if w ~= self.w or h ~= self.h then
        self.w = w
        self.h = h
        self:layout(w, h)
    end

    self.material_rotate:setFloat("rotate", self.rotate);
    self.material_mask:setFloat("randomly", self.randomly);
    self.material_mask:setFloat("threshold", self.threshold);
    self.material_mask:setFloat("sortType", self.sortType);
    self.material_mask:setFloat("affectType", self.affectType);
    self.material_mask:setFloat("triggerType", self.triggerType);
    self.material_mask:setFloat("randomSeed", self.randomSeed);
    self.material_mask:setFloat("blockSize", self.blockSize);
    self.material_mask_refine:setFloat("offset", self.offset);
    self.material_mask_refine:setFloat("offsetRandom", self.offsetRandom);
    self.material_mask_refine:setFloat("randomSeed", self.randomSeed);
    self.material_mask_refine:setFloat("maxLength", self.length);
    self.material_sort:setFloat("reverseSort", self.reverseSort);
    self.material_sort:setFloat("cycle", self.cycle);
    self.material_scale:setFloat("rotate", self.rotate);
    self.material_scale:setFloat("featherStart", self.featherStart);
    self.material_scale:setFloat("featherEnd", self.featherEnd);
    self.material_scale:setFloat("blurSize", self.blurSize);
    self.material_scale:setFloat("outputType", self.outputType);
    self.material_scale:setFloat("reverseSort", self.reverseSort);
    self.material_scale:setFloat("cycle", self.cycle);
end

local function clamp(val, min, max)
    return math.max(math.min(val, max), min)
end

function SeekModeScript:onEvent(sys, event)
    -- if self.first == nil then
    --     self.first = true
    --     self:start(sys)
    -- end
    if event.type == Amaz.AppEventType.SetEffectIntensity then
        local intensity = event.args:get(1)
        if ("threshold" == event.args:get(0)) then
            self.threshold = intensity;
        elseif ("rotate" == event.args:get(0)) then
            self.rotate = 90-intensity;
        elseif ("randomly" == event.args:get(0)) then
            self.randomly = intensity;
        elseif ("reverseSort" == event.args:get(0)) then
            self.reverseSort = intensity;
        elseif ("sortType" == event.args:get(0)) then
            self.sortType = intensity;
        elseif ("triggerType" == event.args:get(0)) then
            self.triggerType = intensity;
        elseif ("affectType" == event.args:get(0)) then
            self.affectType = intensity;
        elseif ("outputType" == event.args:get(0)) then
            self.outputType = intensity;
        elseif ("featherStart" == event.args:get(0)) then
            self.featherStart = intensity;
        elseif ("featherEnd" == event.args:get(0)) then
            self.featherEnd = intensity;
        elseif ("blockSize" == event.args:get(0)) then
            self.blockSize = intensity * 50;
        elseif ("length" == event.args:get(0)) then
            self.length = intensity;
        elseif ("offset" == event.args:get(0)) then
            self.offset = intensity;
        elseif ("offsetRandom" == event.args:get(0)) then
            self.offsetRandom = intensity;
        elseif ("blurSize" == event.args:get(0)) then
            self.blurSize = intensity * 20;
        elseif ("randomSeed" == event.args:get(0)) then
            self.randomSeed = intensity;
        elseif ("cycle" == event.args:get(0)) then
            self.cycle = intensity;
        elseif ("effects_adjust_intensity" == event.args:get(0)) then
            self.threshold = intensity;
        elseif ("effects_adjust_rotate" == event.args:get(0)) then
            self.rotate = intensity * 360;
        elseif ("effects_adjust_range" == event.args:get(0)) then
            self.randomly = intensity;
        elseif ("effects_adjust_filter" == event.args:get(0)) then
            self.featherStart = intensity;
        elseif ("effects_adjust_blur" == event.args:get(0)) then
            self.featherEnd = intensity;
        end
    end
end

exports.SeekModeScript = SeekModeScript
return exports
