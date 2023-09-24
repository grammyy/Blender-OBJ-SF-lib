--@name Blender OBJ test loader
--@author Elias
--@include libs/objs_lib.lua

require("libs/objs_lib.lua")

if SERVER then
    local test=objs:new({
        "https://www.dropbox.com/scl/fi/tb7gwumffuain0ecxhsb9/bottom_armor_plate.obj?rlkey=xxxun3h8ze0wp6wbxmajjvz2t&dl=0",
        "https://www.dropbox.com/scl/fi/d95mj0gidqz6ahp7cwp3a/top_armor_plate.obj?rlkey=m3eox23f0tln3ax1r14ixz1g7&dl=0",
        "https://www.dropbox.com/scl/fi/w3t5lspmxny3sd26g3w4z/front_bottom_plate.obj?rlkey=ff5icvuwh8x0dwd446t1vl70k&dl=0",
        "https://www.dropbox.com/scl/fi/99enolwbjl9lghlnl4b5g/front_top_plate.obj?rlkey=6jq6aqvjwxeacdswqkcddieqw&dl=0",
        "https://www.dropbox.com/scl/fi/rrsex1nbub9yvwao3o4vz/left_armor_plate.obj?rlkey=rki0al7okfav8ft7r8qox6uzy&dl=0",
        "https://www.dropbox.com/scl/fi/p5r3qixy3shva52o8cmvw/right_armor_plate.obj?rlkey=jhfa89b14qbi9lvmpm5qqzqrx&dl=0",
    },{
        {
            ["pos"]=Vector(8.1,0,7.65)
        },
        {
            ["pos"]=Vector(8.1,0,-7.65)
        },
        {
            ["pos"]=Vector(15.75,0,-4.05)
        },
        {
            ["pos"]=Vector(15.75,0,4.05)
        },
        {
            ["pos"]=Vector(8.1,5.15,0)
        },
        {
            ["pos"]=Vector(8.1,-5.15,0)
        }
    },2)
end