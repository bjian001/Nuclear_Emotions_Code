local Helper = {}

---@param scene Scene
---@param rootName string
---@param layer number|nil
---@param order number|nil
---@return number, number
function Helper.initPipeline (scene, rootName, layer, order)
    layer = layer or 1
    order = order or 0
    local function setLayerRecursion (node)
        node.entity.layer = order
        for i = 0, node.children:size() - 1 do
            setLayerRecursion(node.children:get(i))
        end
    end
    local root = scene:findEntityBy(rootName)
    if not root then
        return
    end
    local nodes = root:getComponent("Transform").children
    for i = 0, nodes:size() - 1 do
        local node = nodes:get(i)
        local entity = node.entity
        local camera = entity:getComponent("Camera")
        if camera then
            order = order + 1
            layer = layer * 2
            entity.layer = 0
            camera.renderOrder = order
            camera.layerVisibleMask = Amaz.DynamicBitset.new(64, string.format("%#x", layer))
            setLayerRecursion(node)
        else
            setLayerRecursion(node)
        end
    end
    return layer, order
end



return Helper