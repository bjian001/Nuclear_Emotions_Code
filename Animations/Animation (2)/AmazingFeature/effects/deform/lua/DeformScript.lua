

local exports = exports or {}
local DeformScript = DeformScript or {}

---@class DeformScript : ScriptComponent
---@field size number
---@field twist number [UI(Range={-100, 100}, Slider)]
DeformScript.__index = DeformScript

function DeformScript.new()
    local self = {}
    setmetatable(self, DeformScript)
    self.mesh_size = 100
    self.twist = 0
    self.transform = {}
    return self
end

local createQuadMesh = function(vertexNumber)
    local customMesh = Amaz.Mesh()
    local customSubMesh = Amaz.SubMesh()
    customSubMesh.primitive = Amaz.Primitive.TRIANGLES
    local pos = Amaz.VertexAttribDesc()
    pos.semantic = Amaz.VertexAttribType.POSITION
    local uv = Amaz.VertexAttribDesc()
    uv.semantic = Amaz.VertexAttribType.TEXCOORD0
    local vads = Amaz.Vector()
    vads:pushBack(pos)
    vads:pushBack(uv)
    customMesh.vertexAttribs = vads
    local vertexData = {}
    local indexData = {}
    for i = 0, vertexNumber - 1 do
        for j = 0, vertexNumber - 1 do
            local x = j / (vertexNumber - 1)
            local y = i / (vertexNumber - 1)
            table.insert(vertexData, #vertexData + 1, x * 2 - 1)
            table.insert(vertexData, #vertexData + 1, y * 2 - 1)
            table.insert(vertexData, #vertexData + 1, 0)
            table.insert(vertexData, #vertexData + 1, x)
            table.insert(vertexData, #vertexData + 1, y)
        end
    end


    for i = 0, vertexNumber - 2 do
        for j = 0, vertexNumber - 2 do
            local k = i * vertexNumber + j
            table.insert(indexData, #indexData + 1, k)
            table.insert(indexData, #indexData + 1, k + 1)
            table.insert(indexData, #indexData + 1, k + vertexNumber)
            table.insert(indexData, #indexData + 1, k + 1)
            table.insert(indexData, #indexData + 1, k + vertexNumber + 1)
            table.insert(indexData, #indexData + 1, k + vertexNumber)
        end
    end
    local fv = Amaz.FloatVector()
    for i = 1, table.getn(vertexData) do
        fv:pushBack(vertexData[i])
    end
    customMesh.vertices = fv
    local indices = Amaz.UInt16Vector()
    for i = 1, table.getn(indexData) do
        indices:pushBack(indexData[i])
    end

    customSubMesh.indices16 = indices
    customSubMesh.mesh = customMesh
    customMesh:addSubMesh(customSubMesh)
    return customMesh
end

---@param comp Component
function DeformScript:onStart(comp)
    self.deform_mr = comp.entity:searchEntity("Deform"):getComponent("MeshRenderer")
    self.deform_mat = self.deform_mr.material
    self.mesh = createQuadMesh(self.size)
    self.deform_mr.mesh = self.mesh
    self.prop = comp.properties
end

---@param comp Component
---@param deltaTime number
function DeformScript:onUpdate(comp, deltaTime)
    self.deform_mat:setFloat("u_Twist", self.prop:get("twist") * 0.01)
end

---@param comp Component
---@param event Event
function DeformScript:onEvent(comp, event)
end

exports.DeformScript = DeformScript
return exports
