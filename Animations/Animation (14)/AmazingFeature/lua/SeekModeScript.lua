local exports = exports or {}
local SeekModeScript = SeekModeScript or {}
SeekModeScript.__index = SeekModeScript

---@class SeekModeScript : ScriptComponent
----@field blurR number [UI(Range={0.0, 30}, Slider)]
----@field blurSigma number [UI(Range={0.0, 200.0}, Slider)]
----@field offsetStrength number [UI(Range={0.0, 2.0}, Slider)]
----@field faceOffsetStrength number [UI(Range={0.0, 1.0}, Slider)]
----@field chromatismStrength number [UI(Range={0.0, 1.0}, Slider)]
----@field minFlowStrength number [UI(Range={1.0, 30.0}, Slider)]
----@field flowSpeed number [UI(Range={0.0, 2.0}, Slider)]
----@field flowSizeDecrease number [UI(Range={0.0, 1.0}, Slider)]
----@field emmiterRateRatio number [UI(Range={0.0, 1.0}, Slider)]
----@field maxParticleSize number [UI(Range={20.0, 90.0}, Slider)]

local Utils = require("Utils").Utils
local print = Utils.print

TEXTURE_FORMAT = {RGBA32F = "0", RGBA16F = "1", RGBA8U = "2", R16F = "3", R8U = "4", RG16F = "5", RGB8U = "6"}
TEXTURE_FILTER_MODE = {LINEAR = "0", NEAREST = "2"}
PARTICLE_EMITTER_TYPE = {POINT = "0", LINE = "1"}

PLATFORM = {MAC = "0", EXCEPT_MAC = "1"}
DEVICE_LEVEL = {MIDDLE_LOW = "0", OTHERS = "1"}
FLOW_TYPE = {SMALL = "0", LARGE = "1"}

local platform = PLATFORM.EXCEPT_MAC
local deviceLevel = DEVICE_LEVEL.OTHERS
local type = FLOW_TYPE.LARGE


function SeekModeScript.new(construct, ...)
    local self = setmetatable({}, SeekModeScript)

    if construct and SeekModeScript.constructor then SeekModeScript.constructor(self, ...) end

    self.startTime = 0.0
    self.endTime = 3.0
    self.curTime = 0.0

    self.frame_count = 0
    self.flowScale = 2.8
    return self
end

function SeekModeScript:constructor()
    self.name = "scriptComp"
end

function SeekModeScript:createTexture()
    local tex1 = Amaz.Texture2D()
    tex1.filterMin = Amaz.FilterMode.LINEAR
    tex1.filterMag = Amaz.FilterMode.LINEAR

    return tex1
end

---@function [UI(Button="pause/play")]
---@return void
function SeekModeScript:EnableUpdate()
    self.enableUpdate = not self.enableUpdate
    print("enableUpdate="..tostring(self.enableUpdate))
end

function SeekModeScript:calcParticleRatio()
    local minSize = math.min(self.width, self.height)
    local ratio = minSize / 720.0
    return ratio
end

function SeekModeScript:onStart(comp)
    Amaz.LOGE("INFO: ", "SeekModeScript:onStart(comp)")

    self.width = Amaz.BuiltinObject.getInputTextureWidth()
    self.height = Amaz.BuiltinObject.getInputTextureHeight()
    

    local scanEntity = comp.entity
    self.scene = comp.entity.scene
    
    local tableComp = nil
    tableComp = scanEntity:getComponent("TableComponent").table

    self.opticalFlowText = self:createTexture()
    self.mattingText = self:createTexture()

    self.particleAttrTex1 = Utils.createRT(200, 100, TEXTURE_FORMAT.RG16F, TEXTURE_FILTER_MODE.NEAREST)
    self.particleAttrTex2 = Utils.createRT(200, 100, TEXTURE_FORMAT.RG16F, TEXTURE_FILTER_MODE.NEAREST)
    self.particleAttrTex3 = Utils.createRT(200, 100, TEXTURE_FORMAT.RGB8U, TEXTURE_FILTER_MODE.NEAREST)
    self.particleAttrTex4 = Utils.createRT(200, 100, TEXTURE_FORMAT.RGB8U, TEXTURE_FILTER_MODE.NEAREST)

    -- RT
    self.inputTexture = tableComp:get("input_texture")
    self.outputRT = Utils.loadAmazingFile(self.scene, "rt/outputTex.rt")
    self.tmpPostProcessRT = Utils.loadAmazingFile(self.scene, "rt/tmpParticleBlur1.rt")
    self.tmpPostProcessRT2 = Utils.loadAmazingFile(self.scene, "rt/tmpParticleBlur2.rt")
    if deviceLevel ~= DEVICE_LEVEL.MIDDLE_LOW then
        self.tmpFace1 = Utils.loadAmazingFile(self.scene, "rt/tmpFace1.rt")
        self.tmpFace2 = Utils.loadAmazingFile(self.scene, "rt/tmpFace2.rt")
    end

    -- material
    self.render_particle_material = Utils.loadAmazingFile(self.scene, "material/render_particle.material")
    self.filter_particle_uv_material = Utils.loadAmazingFile(self.scene, "material/filter_particle_uv.material")
    self.dilate_face_h_material = Utils.loadAmazingFile(self.scene, "material/dilate_face_h.material")
    self.dilate_face_v_material = Utils.loadAmazingFile(self.scene, "material/dilate_face_v.material")
    self.face_blur_h_material = Utils.loadAmazingFile(self.scene, "material/face_blur_h.material")
    self.face_blur_v_material = Utils.loadAmazingFile(self.scene, "material/face_blur_v.material")
    self.postprocess_h_material = Utils.loadAmazingFile(self.scene, "material/particle_blur_h.material")
    self.postprocess_v_material = Utils.loadAmazingFile(self.scene, "material/particle_blur_v.material")
    self.postprocess_h2_material = Utils.loadAmazingFile(self.scene, "material/particle_blur_h2.material")
    self.postprocess_v2_material = Utils.loadAmazingFile(self.scene, "material/particle_blur_v2.material")
    self.render_by_offset_material = Utils.loadAmazingFile(self.scene, "material/render_by_offset.material")
    self.add_new_particle_material = Utils.loadAmazingFile(self.scene, "material/add_new_particle.material")
    self.update_particle_material = Utils.loadAmazingFile(self.scene, "material/update_particle.material")
    self.add_new_particle2_material = Utils.loadAmazingFile(self.scene, "material/add_new_partitcle2.material")
    self.update_particle2_material = Utils.loadAmazingFile(self.scene, "material/update_particle2.material")

    self.quadMesh = Utils.loadAmazingFile(self.scene, "mesh/Quad.mesh")
    self.useMesh = Utils.loadAmazingFile(self.scene, "mesh/Quad200x100.mesh")

    if platform == PLATFORM.MAC then
        self.quadMultiMesh = Utils.loadAmazingFile(self.scene, "mesh/Quad4.mesh")
    end


    -- reset mesh indices to remove dumplicated vertex
    
    if deviceLevel == DEVICE_LEVEL.MIDDLE_LOW then
        local tmp = self.useMesh.submeshes:get(0)
        tmp.indices16:clear()
        local indicesSize = 3000 -- for middle level android phone
        for i = 0, indicesSize - 1 do
            tmp.indices16:pushBack(i)
        end
        tmp.indicesCount = indicesSize
        print("reset indices16 count to "..tostring(indicesSize))
    end


    self:initCommandBuffer()

    -- self.maxLife = 2.5
    if type == FLOW_TYPE.SMALL then
        self.maxLife = 4.0
    elseif type == FLOW_TYPE.LARGE then
        self.maxLife = 3.0
    else
        print(string.format("invalid type name %s", type))
    end

    self.FPS = 30.0
    self.enableUpdate = true

    -- setting
    self.blurR = 0
    self.blurSigma = 150.0
    self.offsetStrength = 1.4 -- 1.0
    self.faceOffsetStrength = 0.0
    self.chromatismStrength = 0.0
    self.minFlowStrength = 10.0
    self.flowSpeed = 1.0
    self.emmiterRateRatio = 1.0
    

    if type == FLOW_TYPE.SMALL then
        self.flowSizeDecrease = 0.6
        self.maxParticleSize = 70
    elseif type == FLOW_TYPE.LARGE then
        self.flowSizeDecrease = 1.0
    else
        print(string.format("invalid type name %s", type))
    end
    
    print("init seekmode"..tostring(type))
end

function SeekModeScript:initCommandBuffer()
    self.commandBufStatic = Amaz.CommandBuffer()
    self.commandBufDynamic = Amaz.CommandBuffer()
    self.commandBufDynamic1 = Amaz.CommandBuffer()
    self.identityMatrix = Amaz.Matrix4x4f():SetIdentity()
    self.clearColor = Amaz.Color(0, 0, 0, 1.0)

    self.commandBufStatic:clearAll()
    self.commandBufStatic:setRenderTexture(self.particleAttrTex1)
    self.commandBufStatic:clearRenderTexture(true, true, Amaz.Color(0, 0, 0, 1.0))
    self.commandBufStatic:setRenderTexture(self.particleAttrTex2)
    self.commandBufStatic:clearRenderTexture(true, true, Amaz.Color(0, 0, 0, 1.0))
    self.commandBufStatic:setRenderTexture(self.particleAttrTex3)
    self.commandBufStatic:clearRenderTexture(true, true, Amaz.Color(0, 0, 0, 1.0))
    self.commandBufStatic:setRenderTexture(self.particleAttrTex4)
    self.commandBufStatic:clearRenderTexture(true, true, Amaz.Color(0, 0, 0, 1.0))
    self.scene:commitCommandBuffer(self.commandBufStatic)
    self.commandBufStatic:clearAll()

    if deviceLevel ~= DEVICE_LEVEL.MIDDLE_LOW then
        -- face dilate
        self.dilate_face_h_material:setTex("inputTexture1", self.mattingText)
        self:initPass(self.commandBufStatic, self.tmpFace2, self.quadMesh, self.dilate_face_h_material)
        self.dilate_face_v_material:setTex("inputTexture1", self.tmpFace2)
        self:initPass(self.commandBufStatic, self.tmpFace1, self.quadMesh, self.dilate_face_v_material)

        -- blur face mask
        self.face_blur_h_material:setTex("u_InputTex", self.tmpFace1)
        self:initPass(self.commandBufStatic, self.tmpFace2, self.quadMesh, self.face_blur_h_material)
        self.face_blur_v_material:setTex("u_InputTex", self.tmpFace2)
        self:initPass(self.commandBufStatic, self.tmpFace1, self.quadMesh, self.face_blur_v_material)
    end
   
    -- add new particle
    self.add_new_particle_material:setTex("u_flowTex", self.opticalFlowText)
    self.add_new_particle_material:setFloat("u_flowScale", self.flowScale)
    self.add_new_particle_material:setTex("u_particleAttrTex1", self.particleAttrTex1)
    self.add_new_particle_material:setTex("u_particleAttrTex2", self.particleAttrTex3)
    self.add_new_particle_material:setTex("u_particleTex", self.tmpPostProcessRT)

    self.add_new_particle2_material:setTex("u_flowTex", self.opticalFlowText)
    self.add_new_particle2_material:setFloat("u_flowScale", self.flowScale)
    self.add_new_particle2_material:setTex("u_particleAttrTex1", self.particleAttrTex1)
    self.add_new_particle2_material:setTex("u_particleAttrTex2", self.particleAttrTex3)
    self:initPass(self.commandBufStatic, self.particleAttrTex2, self.useMesh, self.add_new_particle_material)
    self:initPass(self.commandBufStatic, self.particleAttrTex4, self.useMesh, self.add_new_particle2_material)
    

    -- draw particle
    local is_middle_low_device = 1
    if deviceLevel ~= DEVICE_LEVEL.MIDDLE_LOW then
        is_middle_low_device = 0
    end
    self.render_particle_material:setFloat("u_isMiddleLowDevice", is_middle_low_device)
    self.render_particle_material:setTex("u_particleAttrTex1", self.particleAttrTex2)
    self.render_particle_material:setTex("u_particleAttrTex2", self.particleAttrTex4)
    if platform == PLATFORM.MAC then
        self:initPass(self.commandBufStatic, self.tmpPostProcessRT, self.quadMultiMesh, self.render_particle_material)
    else
        self:initPass(self.commandBufStatic, self.tmpPostProcessRT, self.useMesh, self.render_particle_material)
    end


    -- filter offset uv
    self.filter_particle_uv_material:setTex("inputTexture1", self.tmpPostProcessRT)
    self:initPass(self.commandBufStatic, self.tmpPostProcessRT2, self.quadMesh, self.filter_particle_uv_material)

    -- update particle state
    self.update_particle_material:setTex("inputTexture1", self.particleAttrTex2)
    self.update_particle_material:setTex("inputTexture2", self.particleAttrTex4)
    -- self.update_particle_material:setTex("u_flowTex", self.opticalFlowText)
    -- self.update_particle_material:setFloat("u_flowScale", self.flowScale)
    self:initPass(self.commandBufStatic, self.particleAttrTex1, self.useMesh, self.update_particle_material)
    self.update_particle2_material:setTex("inputTexture1", self.particleAttrTex1)
    self.update_particle2_material:setTex("inputTexture2", self.particleAttrTex4)
    self.update_particle2_material:setTex("u_flowTex", self.opticalFlowText)
    self.update_particle2_material:setFloat("u_flowScale", self.flowScale)
    self:initPass(self.commandBufStatic, self.particleAttrTex3, self.useMesh, self.update_particle2_material)

    -- blur offset uv (two pass)
    self.postprocess_h_material:setTex("u_InputTex", self.tmpPostProcessRT2)
    self:initPass(self.commandBufStatic, self.tmpPostProcessRT, self.quadMesh, self.postprocess_h_material)
    self.postprocess_v_material:setTex("u_InputTex", self.tmpPostProcessRT)
    self:initPass(self.commandBufStatic, self.tmpPostProcessRT2, self.quadMesh, self.postprocess_v_material)
    self.postprocess_h2_material:setTex("u_InputTex", self.tmpPostProcessRT2)
    self:initPass(self.commandBufStatic, self.tmpPostProcessRT, self.quadMesh, self.postprocess_h2_material)
    self.postprocess_v2_material:setTex("u_InputTex", self.tmpPostProcessRT)
    self:initPass(self.commandBufStatic, self.tmpPostProcessRT2, self.quadMesh, self.postprocess_v2_material)

    self.render_by_offset_material:setTex("inputTexture1", self.inputTexture)
    self.render_by_offset_material:setTex("inputTexture3", self.tmpPostProcessRT2) -- offset
    if deviceLevel ~= DEVICE_LEVEL.MIDDLE_LOW then
        self.render_by_offset_material:setTex("inputTexture4", self.tmpFace1) -- face mask (blurred)
    else
        self.render_by_offset_material:setTex("inputTexture4", self.mattingText) -- face mask (ori)
    end

    -- self.render_by_offset_material:setTex("inputTexture4", self.mattingText) -- matting mask (blurred)
    -- self.render_by_offset_material:setTex("inputTexture4", self.inputTexture) -- debug 
    self:initPass(self.commandBufStatic, self.outputRT, self.quadMesh, self.render_by_offset_material)


    
end

function SeekModeScript:initPass(cmdbuf, rt, mesh, material)
    cmdbuf:setRenderTexture(rt)
    cmdbuf:clearRenderTexture(true, true, self.clearColor)
    cmdbuf:drawMesh(mesh, self.identityMatrix, material, 0, 0, nil, true)
end



function SeekModeScript:onUpdate(comp, deltaTime)
    local seed = math.floor(os.time() + os.clock() * 100000000)
    -- seed = os.time()+assert(tonumber(tostring({}):sub(7)))
    math.randomseed(seed)

    -- print("rand="..tostring(math.random()))

    if type == FLOW_TYPE.SMALL then
        -- adapt max life according to flowSizeDecrease
        local tmpV = math.min(1.0, math.max(self.flowSizeDecrease, 0.0))
        self.maxLife = Utils.mix(2.0, 5.0, tmpV)
    end

    -- get optical flow result
    local result = Amaz.Algorithm.getAEAlgorithmResult()
    
    local avgABSFlow = Amaz.Vector2f(0.0, 0.0)
    if result ~= nil then
        local nh_script = result:getScriptInfo("2023_0908_cmj_flowwarp", "nh_script_0")
        -- print("result: " .. tostring(nh_script))
        if nh_script ~= nil then
            local disMap = nh_script.outputMap
            if disMap ~= nil then
                local disImage1 = disMap:get("image1")
                avgABSFlow = disMap:get("avgABSFlow")
                if avgABSFlow == nil then
                    avgABSFlow = Amaz.Vector2f(0.0, 0.0)
                end

                if disImage1 == nil then
                        print("disImage1=" .. tostring(disImage1))
                else
                    self.opticalFlowText:storage(disImage1)
                end
            else
                print("disMap is nil")
            end
        else
            print("nh_script is nil")
        end

        -- get matting result
        local mattingInfo = result:getBgInfo()

        if mattingInfo ~= nil then
            local mask_buffer = mattingInfo.bgMask
            if mask_buffer ~= nil then
                self.mattingText:storage(mask_buffer)
            end
        end
    else
        print("getAEAlgorithmResult is nil")
    end

    local avgFlowTotal = avgABSFlow.x+avgABSFlow.y
    local isStatic = 0
    local needAdd = 1
    local randomPos = Amaz.Vector2f(0, 0)
    local randomDir = Amaz.Vector2f(0, 0)

    if self.opticalFlowText.width == 0 and self.opticalFlowText.height == 0 then
        isStatic = 1
    end

  
    if (avgFlowTotal < 0.0001) or (self.opticalFlowText.width == 0 and self.opticalFlowText.height == 0) then
        if self.frame_count % 30 == 0 then
            isStatic = 1
            randomPos = Amaz.Vector2f(math.random(), math.random())
            randomDir = Amaz.Vector2f(
                (math.random() - 0.5),
                (math.random() - 0.5)
            );
            randomDir = randomDir * 0.05
            randomDir.x = randomDir.x * self.width / self.height
        else
            needAdd = 0
        end
    end

    -- print("frame:"..tostring(self.frame_count).." curtime=" .. tostring(self.curTime) .." avgFlowTotal="..tostring(avgFlowTotal).." isStatic="..tostring(isStatic).." needAdd="..tostring(needAdd))

    if deviceLevel ~= DEVICE_LEVEL.MIDDLE_LOW then
        -- -- dialte face mask
        self.dilate_face_h_material:setVec2("direction", Amaz.Vector2f(0.0, 1.0/self.tmpFace1.height))
        self.dilate_face_v_material:setVec2("direction", Amaz.Vector2f(1.0/self.tmpFace1.width, 0.0))

        -- blur face mask
        self.face_blur_h_material:setFloat("u_Sigma", 150.0)
        self.face_blur_h_material:setInt("u_BlurR", 1.0)
        self.face_blur_h_material:setVec2("u_Direction", Amaz.Vector2f(0.0, 1.0/self.tmpFace1.height))

        self.face_blur_v_material:setFloat("u_Sigma", 150.0)
        self.face_blur_v_material:setInt("u_BlurR", 1.0)
        self.face_blur_v_material:setVec2("u_Direction", Amaz.Vector2f(1.0/self.tmpFace1.width, 0.0))
    end

    -- draw particle (if need)
    local randSeed = Amaz.Vector2f(math.random(), math.random())
    local particleRatio = self:calcParticleRatio()
    self.render_particle_material:setFloat("u_particleRatio", particleRatio)
    self.render_particle_material:setVec2("frameResolution", Amaz.Vector2f(1.0/self.width, 1.0/self.height))
    self.render_particle_material:setFloat("u_flowSizeDecrease", self.flowSizeDecrease)
    self.render_particle_material:setFloat("u_maxLife", self.maxLife)
    self.render_particle_material:setFloat("u_FPS", self.FPS)
    if type == FLOW_TYPE.SMALL then
        self.render_particle_material:setFloat("u_maxParticleSize", self.maxParticleSize)
        self.render_particle_material:setFloat("u_sizeSplitPoint", 0.05)
    else
        self.render_particle_material:setFloat("u_maxParticleSize", 70.0)
        self.render_particle_material:setFloat("u_sizeSplitPoint", 0.1)
    end

    self.filter_particle_uv_material:setVec2("u_frameSize", Amaz.Vector2f(self.width, self.height))

    -- add new particle
    local is_first_frame = 0
    if self.frame_count == 0 then
        is_first_frame = 1
    end
    self.add_new_particle_material:setVec2("u_frameSize", Amaz.Vector2f(self.width, self.height))
    self.add_new_particle_material:setInt("u_isFirstFrame", is_first_frame)
    self.add_new_particle_material:setVec2("u_randSeed", randSeed)
    self.add_new_particle_material:setFloat("u_threshold", self.minFlowStrength)
    self.add_new_particle_material:setFloat("u_emmiterRateRatio", self.emmiterRateRatio)
    self.add_new_particle_material:setVec2("u_avgABSFlow", avgABSFlow)
    self.add_new_particle_material:setFloat("u_isStatic", isStatic)
    self.add_new_particle_material:setVec2("u_randomPos", randomPos)
    -- self.add_new_particle_material:setVec2("u_randomDir", randomDir)
    -- self.add_new_particle_material:setFloat("u_flowSpeed", self.flowSpeed)

    self.add_new_particle2_material:setVec2("u_randomDir", randomDir)
    self.add_new_particle2_material:setFloat("u_flowSpeed", self.flowSpeed)
    self.add_new_particle2_material:setVec2("u_frameSize", Amaz.Vector2f(self.width, self.height))
    self.add_new_particle2_material:setFloat("u_FPS", self.FPS)
    self.add_new_particle2_material:setFloat("u_maxLife", self.maxLife)
    self.add_new_particle2_material:setVec2("u_randSeed", randSeed)
    self.add_new_particle2_material:setFloat("u_threshold", self.minFlowStrength)
    self.add_new_particle2_material:setFloat("u_isStatic", isStatic)
    self.add_new_particle2_material:setInt("u_isFirstFrame", is_first_frame)
    self.add_new_particle2_material:setFloat("u_emmiterRateRatio", self.emmiterRateRatio)
    self.add_new_particle2_material:setVec2("u_avgABSFlow", avgABSFlow)
    self.add_new_particle2_material:setFloat("u_needAdd", needAdd)

    self.update_particle_material:setVec2("u_frameSize", Amaz.Vector2f(self.width, self.height))
    self.update_particle_material:setFloat("u_flowSpeed", self.flowSpeed)
    self.update_particle_material:setFloat("u_isStatic", isStatic)
    self.update_particle2_material:setVec2("u_frameSize", Amaz.Vector2f(self.width, self.height))
    self.update_particle2_material:setFloat("u_flowSpeed", self.flowSpeed)
    self.update_particle2_material:setFloat("u_isStatic", isStatic)
    


    -- blur offset uv (2 pass)
    self.postprocess_h_material:setFloat("u_Sigma", self.blurSigma)
    self.postprocess_h_material:setInt("u_BlurR", self.blurR)
    self.postprocess_h_material:setVec2("u_Direction", Amaz.Vector2f(0.0, 1.0/self.tmpPostProcessRT2.height))

    self.postprocess_v_material:setFloat("u_Sigma", self.blurSigma)
    self.postprocess_v_material:setInt("u_BlurR", self.blurR)
    self.postprocess_v_material:setVec2("u_Direction", Amaz.Vector2f(1.0/self.tmpPostProcessRT2.width, 0.0))

    self.postprocess_h2_material:setFloat("u_Sigma", self.blurSigma)
    self.postprocess_h2_material:setInt("u_BlurR", self.blurR)
    self.postprocess_h2_material:setVec2("u_Direction", Amaz.Vector2f(0.0, 1.0/self.tmpPostProcessRT2.height))

    self.postprocess_v2_material:setFloat("u_Sigma", self.blurSigma)
    self.postprocess_v2_material:setInt("u_BlurR", self.blurR)
    self.postprocess_v2_material:setVec2("u_Direction", Amaz.Vector2f(1.0/self.tmpPostProcessRT2.width, 0.0))

    -- render by offset
    self.render_by_offset_material:setFloat("chromatismStrength", self.chromatismStrength)
    self.render_by_offset_material:setFloat("offsetStrength", self.offsetStrength)
    self.render_by_offset_material:setFloat("faceOffsetStrength", self.faceOffsetStrength)
    -- local minSize = Amaz.Vector2f(math.min(flowWidth, flowHeight), math.min(flowWidth, flowHeight))
    -- print("minSize="..tostring(minSize))
    -- self.render_by_offset_material:setVec2("flowResolution", Amaz.Vector2f(minSize, minSize))

    if self.curTime > self.endTime - self.startTime - 1 then
        local w = (self.curTime - self.endTime + 1) / 1
        local strength = Utils.mix(self.offsetStrength, 0, w)
        self.render_by_offset_material:setFloat("offsetStrength", strength)
    end

    comp.entity.scene:commitCommandBuffer(self.commandBufStatic)

    self.frame_count = self.frame_count + 1

    -- print(string.format("frame%d onUpdate", self.frame_count))
end

function SeekModeScript:onEvent(sys, event)
    if "effects_adjust_horizontal_chromatic" == event.args:get(0) then -- range=[0, 0.6]
        local chromatismStrength = event.args:get(1)
        self.chromatismStrength = chromatismStrength * 0.6
    end
    if "effects_adjust_distortion" == event.args:get(0) then -- overall strength, range=[0, 2]
        local offsetStrength = event.args:get(1)
        self.offsetStrength = offsetStrength
    end
    if "effects_adjust_intensity" == event.args:get(0) then  -- face protection strength, range=[0, 1]
        local faceOffsetStrength = event.args:get(1)
        self.faceOffsetStrength = faceOffsetStrength
    end

    if "effects_adjust_speed" == event.args:get(0) then  -- min flow speed, range=[0~2]
        local flowSpeed = (event.args:get(1))
        self.flowSpeed = Utils.mix(0.0, 2.0, flowSpeed)
    end

    if type == FLOW_TYPE.SMALL then
        if "effects_adjust_size" == event.args:get(0) then   -- particle blurR, range=[0, 30]
            local ratio = event.args:get(1)
            if ratio > 0.5 then
                self.blurR = Utils.mix(0.0, 1.5, (ratio-0.5)*2)
                self.maxParticleSize = 70.0
            else
                self.blurR = 0
                self.maxParticleSize = Utils.mix(30.0, 70.0, 2*ratio)
            end
        end
        if "effects_adjust_number" == event.args:get(0) then  -- min flow strength, range=[0~30]
            local minFlowStrength = event.args:get(1)
            self.minFlowStrength = Utils.mix(30.0, 0.0, minFlowStrength)
        end
    elseif type == FLOW_TYPE.LARGE then
        if "effects_adjust_size" == event.args:get(0) then   -- particle blurR, range=[0, 30]
            local blur = event.args:get(1)
            self.blurR = blur * 30
        end
        if "effects_adjust_number" == event.args:get(0) then  -- min flow strength, range=[0~30]
            local minFlowStrength = event.args:get(1)
            self.minFlowStrength = Utils.mix(30.0, 0.0, minFlowStrength)
    
            if minFlowStrength > 0.6 then
                self.emmiterRateRatio = 1.0
            else
                self.emmiterRateRatio = Utils.mix(0, 1, minFlowStrength*1.667)
            end
        end
    end
end

function SeekModeScript:seekToTime(comp, time)
    local w = Amaz.BuiltinObject:getInputTextureWidth()
    local h = Amaz.BuiltinObject:getInputTextureHeight()
    if w ~= self.width or h ~= self.height then
        self.width = w
        self.height = h
    end
    self.frame_count = 0;
end

exports.SeekModeScript = SeekModeScript
return exports
