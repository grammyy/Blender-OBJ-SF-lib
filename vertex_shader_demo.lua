--@name Vertex shader demo
--@author Elias
--@include libs/objs_lib.lua

require("libs/objs_lib.lua")

if SERVER then
    local test=objs:new({
        "https://www.dropbox.com/scl/fi/tb7gwumffuain0ecxhsb9/bottom_armor_plate.obj?rlkey=xxxun3h8ze0wp6wbxmajjvz2t&dl=0"
    },{},3)
else
    hook.add("think","test",function()
        for id,ent in pairs(cache) do
            if ent=="loading" then 
                return 
            end
            
            local shader=table.copy(ent.mesh)
            
            for i,data in pairs(shader) do
                shader[i].pos=Vector(shader[i].pos[1]+math.sin(timer.realtime()*5+i*5),(shader[i].pos[2]*10)+math.sin(timer.realtime()*5+i*5),shader[i].pos[3]+math.sin(timer.realtime()*5+i*5))
                shader[i].normal=Vector(shader[i].normal[1],shader[i].normal[2],shader[i].normal[3])
            end
            
            if memory then
                memory:destroy()
            end
            
            mesh_=mesh.createFromTable(shader)
            memory=mesh_
            
            entity(id):setMesh(mesh_)
        end
    end)
end