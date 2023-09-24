--@name OBJs lib
--@author Elias

objs=class("objs")

if SERVER then
    local objEnts={}
    waitList={}

    function queue(time,func,data)
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
    
    function objs:initialize(objArray,data,scale)
        self.objArray=objArray
        self.data=data
        self.scale=scale
        
        for i=1,#self.objArray do
            queue(1/3,function()
                http.get(string.replace(self.objArray[i],"https://www.dropbox.com/","https://dl.dropboxusercontent.com/"),function(objdata)
                    if !self.data[i] then
                        self.data[i]={}
                    end
                    
                    local name=string.split(self.objArray[i],"/")
                    self.data[i].name=string.split(name[#name],".obj")[1]
                    
                    local data={mesh.parseObj(objdata,nil,true)}
                    local p=data[2].positions
                    local v=data[1][self.data[i].name] or data[1]

                    local convexes={}
                    local vertices={}
                    
                    for ii=1,#p do
                        convexes[ii]=Vector(p[ii][1],p[ii][2],p[ii][3])*self.scale
                    end
                    
                    for ii=1,#v do
                        vertices[ii]=v[ii]
                        vertices[ii].pos=Vector(v[ii].pos[1],v[ii].pos[2],v[ii].pos[3])*self.scale
                        vertices[ii].normal=Vector(v[ii].normal[1],v[ii].normal[2],v[ii].normal[3])*self.scale
                    end
                    
                    local ent=prop.createCustom(chip():getPos()+(self.data[i].pos and self.data[i].pos*self.scale or Vector()), (self.data[i].ang or Angle())+Angle(0,0,90), {convexes}, true)
                    objEnts[ent:entIndex()]=ent
                    objEnts[ent:entIndex()].vertices=vertices
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
            net.start("cl_deliver")
            net.writeInt(packet,16)
            net.writeTable(objEnts[packet].vertices)
            net.send()
        end)
    end)
else
    cache={}
    
    net.receive("cl_deliver",function()
        local packet={net.readInt(16),net.readTable()}
        local ent=entity(packet[1])
        
        if cache[packet[1]]=="loading" then
            cache[packet[1]]={}
            cache[packet[1]].mat = material.create("VertexLitGeneric")
            cache[packet[1]].mat:setTexture("$basetexture","hunter/myplastic")
            cache[packet[1]].mesh=packet[2]
            
            ent:setMesh(mesh.createFromTable(cache[packet[1]].mesh))
            ent:setMeshMaterial(cache[packet[1]].mat)
        end          
    end)
    
    hook.add("think","objs_mats",function()
        local objs=find.byClass("starfall_prop")
        
        for i,obj in pairs(objs) do
            try(function()
                if !cache[obj:entIndex()] and obj:getOwner()==owner() then
                    printConsole("Loading OBJ: "..obj:entIndex())
                    
                    cache[obj:entIndex()]="loading"
                    
                    net.start("sv_request")
                    net.writeInt(obj:entIndex(),16)
                    net.send()
                end
            end)
        end
    end)
end