--@name Meat vertex test
--@author Elias
--@include libs/objs_lib.lua

require("libs/objs_lib.lua")

if SERVER then
    local test=objs:new({
        "https://www.dropbox.com/scl/fi/vql1p7y0xjxoips5ydupz/Cube.obj?rlkey=2y6vmxln1zm55014f32fqj3qh&dl=0"
    },{
        {
            texture="models/flesh"
        }
    },10)
else
    hook.add("think","test",function()
        for id,ent in pairs(cache) do
            if ent=="loading" then 
                return 
            end
            
            local shader=table.copy(ent.mesh)
            
            for i,data in pairs(shader) do
                shader[i].pos=Vector(shader[i].pos[1],(shader[i].pos[2]),shader[i].pos[3])*Vector(math.clamp(0.5+math.sin(shader[i].pos[2]*2+timer.realtime()*3)/2,0.5,1.5))+Vector(math.sin(shader[i].pos[2]*3+timer.realtime()*2))
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