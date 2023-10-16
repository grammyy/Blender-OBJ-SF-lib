--@name Meat vertex test
--@author Elias
--@include libs/objs_lib.lua

require("libs/objs_lib.lua")

if SERVER then
    local test=objs:new({
        ["https://www.dropbox.com/scl/fi/2zkfoqjzpc7g2urdkkzhs/Cube.obj?rlkey=3ims8uw1fotvwh2vnthld35vd&dl=0"]={
            texture="models/flesh"
        }
    }):spawn({
        scale=10
    })
else
    local memeory={}
    
    hook.add("think","",function()
        for id,ent in pairs(cache) do
            if ent=="loading" or quotaAverage()>quotaMax()*0.7 then
                return 
            end
            
            local shader=table.copy(ent.mesh)
            
            for i,data in pairs(shader) do
                shader[i].pos=shader[i].pos*Vector(math.clamp(0.5+math.sin(shader[i].pos[2]*2+timer.realtime()*3)/2,0.5,1.5))+Vector(math.sin(shader[i].pos[2]*3+timer.realtime()*2))
            end
            
            if memeory[id] and memeory[id].mem then
                memeory[id].mem:destroy()
            end
            
            memeory[id]={
                mesh=mesh.createFromTable(shader)
            }
            memeory[id].mem=memeory[id].mesh
            
            try(function()
                entity(id):setMesh(memeory[id].mesh)
            end)
        end
    end)
end