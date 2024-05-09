local exports = exports or {}
local Utils = Utils or {}
Utils.__index = Utils

function Utils.loadAmazingFile(scene, path)
    return scene.assetMgr:SyncLoad(path)
end

function Utils.print(...)
    local arg = { ... }
    local msg = "effect_lua:"
    for k, v in pairs(arg) do
        msg = msg .. tostring(v) .. " "
    end
    Amaz.LOGE("flow_seekmode", msg)
end

function Utils.createTexture()
    local tex1 = Amaz.Texture2D()
    tex1.filterMin = Amaz.FilterMode.LINEAR
    tex1.filterMag = Amaz.FilterMode.LINEAR

    return tex1
end

function Utils.createRT(width, height, format, filterMode)
    local rt = Amaz.RenderTexture()
    rt.width = width
    rt.height = height
    rt.depth = 1
    -- rt.filterMag = Amaz.FilterMode.FilterMode_LINEAR
    -- rt.filterMin = Amaz.FilterMode.FilterMode_LINEAR
    -- rt.filterMipmap = Amaz.FilterMipmapMode.FilterMode_NONE
    rt.attachment = Amaz.RenderTextureAttachment.NONE

    if format == TEXTURE_FORMAT.RGBA32F then
        rt.internalFormat = Amaz.InternalFormat.RGBA32F
        rt.dataType = Amaz.DataType.F32
        rt.colorFormat = Amaz.PixelFormat.RGBA32Sfloat
    elseif format == TEXTURE_FORMAT.RGBA16F then
        rt.internalFormat = Amaz.InternalFormat.RGBA16F
        rt.dataType = Amaz.DataType.F16
        rt.colorFormat = Amaz.PixelFormat.RGBA16Sfloat
    elseif format == TEXTURE_FORMAT.RGBA8U then
        rt.internalFormat = Amaz.InternalFormat.RGBA8
        rt.dataType = Amaz.DataType.U8norm
        rt.colorFormat = Amaz.PixelFormat.RGBA8Unorm
    elseif format == TEXTURE_FORMAT.R8U then
        rt.internalFormat = Amaz.InternalFormat.R8
        rt.dataType = Amaz.DataType.U8norm
        rt.colorFormat = Amaz.PixelFormat.R8Unorm
    elseif format == TEXTURE_FORMAT.R16F then
        rt.internalFormat = Amaz.InternalFormat.R16F
        rt.dataType = Amaz.DataType.F16
        rt.colorFormat = Amaz.PixelFormat.R16Sfloat
    elseif format == TEXTURE_FORMAT.RG16F then
        rt.internalFormat = Amaz.InternalFormat.RG16F
        rt.dataType = Amaz.DataType.F16
        rt.colorFormat = Amaz.PixelFormat.RG16Sfloat
    elseif format == TEXTURE_FORMAT.RGB8U then
        rt.internalFormat = Amaz.InternalFormat.RGB8
        rt.dataType = Amaz.DataType.U8norm
        rt.colorFormat = Amaz.PixelFormat.RGB8Unorm
    else
        print("Utils.createRT: unknown pixel format "..tostring(format))
    end

    if filterMode == TEXTURE_FILTER_MODE.LINEAR then
        rt.filterMag = Amaz.FilterMode.LINEAR
        rt.filterMin = Amaz.FilterMode.LINEAR
    elseif filterMode == TEXTURE_FILTER_MODE.NEAREST then
        rt.filterMag = Amaz.FilterMode.NEAREST
        rt.filterMin = Amaz.FilterMode.NEAREST
    end
    
    rt.filterMipmap = Amaz.FilterMipmapMode.NONE
    rt.massMode	= Amaz.MSAAMode.NONE
    rt.shared = false
    rt.maxAnisotropy = 1

    Utils.print("percent x="..tostring(rt.pecentX))
    Utils.print("percent y="..tostring(rt.pecentY))
    Utils.print("percent x="..tostring(rt.width).." passin="..tostring(width))
    Utils.print("percent y="..tostring(rt.height).." passin="..tostring(height))

    return rt
end

function Utils.mix(val1, val2, weight)
    if weight <= 0 then
        return val1
    elseif weight >= 1 then
        return val2
    else
        return (1.0-weight)*val1 + weight * val2
    end
end


exports.Utils = Utils
return exports