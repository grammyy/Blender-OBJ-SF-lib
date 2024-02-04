--@name OBJs lib
--@author Elias

objs=class("objs")

if SERVER then
    local objEnts={}
    waitList={}
    
    local function queue(time,func,data)
        if !waitList[time] then
            waitList[time]={}
            local list=waitList[time]
                    
            func()
                    
            timer.create("waitList_"..time,time,0,function()
                if list[#waitList[time]] then
                    list[#waitList[time]]()
                    
                    waitList[time][#waitList[time]]=nil
                else
                    timer.remove("waitList_"..time)
                    
                    waitList[time]=nil
                end
            end)
        else
            table.insert(waitList[time],1,func)
        end
    end
    
    function network(ply,packet) --add counter so if it refuses too much it ignores the data
        if !ply:isValid() then
            return
        end
        
        if !suspend and net.getBytesLeft()>0 then
            net.start("cl_deliver")
            net.writeInt(packet,16)
            net.writeTable(objEnts[packet].vertices)
            net.writeString(objEnts[packet].texture)
        end
        
        local lot=net.getBytesLeft()

        if lot>0 then
            printConsole(Color(255,255,255),"["..string.rep("0",5-#tostring(lot))..lot..":",Color(0,255,0),"Sent",Color(255,255,255),"] > Sending OBJ data to ",Color(0,220,255),ply:getName(),Color(255,255,255),".")

            net.send(ply)
            
            suspend=false            
        else
            printConsole("["..string.rep("0",5-#tostring(lot))..lot..":",Color(255,0,0),"Refused",Color(255,255,255),"] > Refusing data transfer to ",Color(0,220,255),ply:getName(),Color(255,255,255),". Standing by.")
            
            suspend=true
            
            timer.simple(2,function()
                network(ply,packet)
            end)
        end
    end
    
    function objs:initialize(objs)
        self.parts={}
        self.status="loading"
        
        for link,obj in pairs(objs) do
            if isnumber(link) then
                link=obj
            end
            
            queue(1/3,function()
                http.get(string.replace(link,"https://www.dropbox.com/","https://dl.dropboxusercontent.com/"),function(data)      
                    local data={mesh.parseObj(data,nil,true)}    
                    local objKeys=table.getKeys(objs)
                    local partKeys=table.getKeys(data[1])
                    
                    for part,partData in pairs(data[1]) do
                        local vertexes={}
                        
                        if type(obj)!="string" then
                            if !objs[link][part] then
                                objs[link][part]={}
                            end
                            
                            for i,vertex in pairs(data[2].positions) do
                                vertexes[i]=vertex*Vector(objs[link][part].scale or 1)
                            end
                            
                            if objs[link][part].scale then
                                for i,vertex in pairs(partData) do
                                    vertex.pos=vertex.pos*objs[link][part].scale
                                end
                            end

                            table.add(self.parts,{[part]={
                                physMaterial=objs[link].physMaterial or objs[link][part].physMaterial,
                                texture=objs[link].texture or objs[link][part].texture,
                                parent=objs[link].parent or objs[link][part].parent,
                                color=objs[link].color or objs[link][part].color,
                                mass=objs[link].mass or objs[link][part].mass,
                                pos=objs[link].pos or objs[link][part].pos,
                                ang=objs[link].ang or objs[link][part].ang,
                                vertexes=vertexes,
                                data=partData
                            }})
                        else
                            table.add(self.parts,{[part]={
                                vertexes=data[2].positions,
                                data=partData
                            }})
                        end
                        
                        if partData==data[1][partKeys[#partKeys]] and obj==objs[objKeys[#objKeys]] then
                            self.status="done"
                        end
                    end
                    
                    return self
                end)
            end)
        end
    end
    
    function objs:spawn(global)
        if self.status=="loading" then
            hook.add("think","awaiting_obj"..table.address(self),function()
                if self.status!="loading" then
                    self:spawn(global)
                    
                    hook.remove("think","awaiting_obj"..table.address(self))
                end
            end)
            
            return
        end

        if !global then
            global={}
        end

        for part,data in pairs(self.parts) do
            local vertexes=table.copy(data.vertexes)
            local partData=table.copy(data.data)
            
            if global.scale then
                for i,vertex in pairs(data.vertexes) do
                    vertexes[i]=vertex*global.scale
                end
                
                for i,vertex in pairs(data.data) do
                    partData[i].pos=vertex.pos*global.scale
                end
            end
        
            queue(1/3,function()
                local ent=prop.createCustom(((global.pos or Vector())+(data.pos and (data.pos*(global.scale or 1)) or Vector())),(ang or Angle())+Angle(0,0,90),{vertexes},true)
                objEnts[ent:entIndex()]=ent
                objEnts[ent:entIndex()].vertices=partData
                objEnts[ent:entIndex()].texture=(global.texture or data.texture) or "hunter/myplastic"
                
                if global.physMaterial or data.physMaterial then
                    ent:setPhysMaterial(global.physMaterial or data.physMaterial)
                end
                
                if global.parent or data.parent then
                    ent:setParent(global.parent or data.parent)
                end
                
                if global.color or data.color then
                    ent:setColor(global.color or data.color)
                end
                
                if global.mass or data.mass then
                    ent:setMass(global.mass or data.mass)
                end
            end)
        end
        
        return ent
    end
    
    net.receive("sv_request",function(_,ply)
        local packet=net.readInt(16)
        
        if !objEnts[packet] then
            return
        end
        
        queue(1/5,function()
            network(ply,packet)
        end)
    end)
else
    cache={}
    version="beta_1"
    repo="https://raw.githubusercontent.com/grammyy/Blender-OBJ-SF-lib/main/version"
    
    http.get("https://raw.githubusercontent.com/grammyy/SF-linker/main/linker.lua",function(data)
        loadstring(data)()
        
        load({
            "https://raw.githubusercontent.com/grammyy/SF-linker/main/public%20libs/version%20changelog.lua"
        })
    end)
    
    net.receive("cl_deliver",function()
        local packet={net.readInt(16),net.readTable(),net.readString()}
        local ent=entity(packet[1])
        
        if cache[packet[1]]=="loading" then
            cache[packet[1]]={
                mesh=packet[2],
                mat=material.create("VertexLitGeneric")
            }
            cache[packet[1]].mat:setTexture("$basetexture",packet[3] or "hunter/myplastic")

            ent:setMesh(mesh.createFromTable(cache[packet[1]].mesh))
            ent:setMeshMaterial(cache[packet[1]].mat)
        end          
    end)
    
    hook.add("think","objs_mats",function()
        local objs=find.byClass("starfall_prop")
        
        for i,obj in pairs(objs) do
            if !cache[obj:entIndex()] and obj:getOwner()==owner() then
                printConsole("Loading OBJ: "..obj:entIndex())
                
                cache[obj:entIndex()]="loading"
                
                net.start("sv_request")
                net.writeInt(obj:entIndex(),16)
                net.send()
            end
        end
    end)
end