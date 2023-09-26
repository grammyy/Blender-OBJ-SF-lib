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
            
            timer.simple(1,function()
                network(ply,packet)
            end)
        end
    end
    
    function objs:initialize(objArray,data,scale,ArrayData)
        self.objArray=objArray
        self.data=data
        self.scale=scale
        
        for i=1,#self.objArray do
            queue(1/3,function()
                http.get(string.replace(self.objArray[i],"https://www.dropbox.com/","https://dl.dropboxusercontent.com/"),function(objdata)
                    local obj=self.data[i]
                    
                    if !obj then
                        self.data[i]={}
                    end
                    
                    local name=string.split(self.objArray[i],"/")
                    self.data[i].name=string.split(name[#name],".obj")[1]
                    
                    local data={mesh.parseObj(objdata,nil,true)}
                    local p=data[2].positions
                    local v=data[1][obj.name] or data[1]

                    local convexes={}
                    local vertices={}
                    
                    for ii=1,#p do
                        convexes[ii]=Vector(p[ii][1],p[ii][2],p[ii][3])*self.scale
                    end
                    
                    for ii=1,#v do
                        vertices[ii]=v[ii]
                        vertices[ii].pos=Vector(v[ii].pos[1],v[ii].pos[2],v[ii].pos[3])*self.scale
                        vertices[ii].normal=Vector(v[ii].normal[1],v[ii].normal[2],v[ii].normal[3])
                    end
                    
                    local ent=prop.createCustom(chip():getPos()+(obj.pos and obj.pos*self.scale or Vector()), (obj.ang or Angle())+Angle(0,0,90), {convexes}, true)
                    objEnts[ent:entIndex()]=ent
                    objEnts[ent:entIndex()].vertices=vertices
                    objEnts[ent:entIndex()].texture=obj.texture or "hunter/myplastic"
                    local index=objEnts[ent:entIndex()]
                    
                    ent:setColor((ArrayData and ArrayData.color) and ArrayData.color or (obj.color or Color(255,255,255)))

                    if obj.physMaterial then
                        ent:setPhysMaterial(obj.physMaterial)
                    end
                    
                    if obj.mass then
                        ent:setMass(obj.mass)
                    end
                    
                    if !ArrayData then
                        return
                    end
                    
                    if ArrayData.parent then
                        ent:setParent(ArrayData.parent)
                    end
                end)
            end)
        end
        
        return self
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