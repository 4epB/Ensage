require("libs.SkillShot")
 
Keys = {false,false}
hotkey = "C"
sleepTick = 0
rotTick = 0
rotCheck = false
currentTick = 0
target = nil
xyz = {}
chatting = {false,false}
qrange = {700,900,1100,1300}
wdamage = {35,60,85,110}
range = 0
--------------
 
--------
 
function Tick( tick )
 
        if not engineClient.ingame or engineClient.console then
                return
        end
       
       
        if not me or me.name ~= "Pudge"  then
                script:Unload()
                if me then
                        print("You cant hook people with "..me.name)
                end
        end
       
        if me:GetAbility(1).level ~= 0 then
                range = qrange[me:GetAbility(1).level] + 350
        end
 
        xyz = {}
        currentTick = tick
       
        if rotCheck and rotTick + 400 < tick and me:GetAbility(2).activated == true then
                UseAbility(me:GetAbility(2))
                rotCheck = false
        end
       
        FindTarget()
        --print(me:GetAbility(2).autocastState)
       
        TrackTick(tick)
       
        if me.alive == true and SleepCheck() then
                if Keys[1] and target then
                        xyz = BlockableSkillShotXYZ(target,300,1333,125,true)
                        if CanCast(me:GetAbility(1)) and xyz then
                                        UseAbility(me:GetAbility(1),xyz[1],xyz[2],xyz[3])
                                        Sleep(250)
                        end
                elseif Keys[2] and CanCast(me:GetAbility(2)) then
                        print("LOL")
                        UseAbility(me:GetAbility(2))
                        --RotLastHit()
                end
                Sleep(250)
        end
       
end
 
function Sleep(duration)
        sleepTick = currentTick + duration
end
 
function RotLastHit()
        local creeps = entityList:FindEntities({classId=CDOTA_BaseNPC_Creep_Lane,alive=true,team=TEAM_ENEMY,visible=true})
        for i,v in ipairs(creeps) do
                if GetDistance2D(me,v) < 250 then
                        print(v.health)
                        if v.health < (wdamage[me:GetAbility(2).level]*2/5) then
                                UseAbility(me:GetAbility(2))
                                rotTick = currentTick
                                rotCheck = true
                        end
                end                    
        end
end
 
function SleepCheck()
        return sleepTick == nil or currentTick > sleepTick
end
 
function CanCast(spell)
        return  spell and spell.level ~= 0 and spell.state == STATE_READY
end
 
function FindTarget()
        local lowenemy = nil
        local enemies = entityList:FindEntities({type=TYPE_HERO,team=TEAM_ENEMY,alive=true,visible=true})
        for i,v in ipairs(enemies) do
                distance = GetDistance2D(me,v)
                if distance <= range and v.replicatingModel == -1 then
                        --local pred = SkillShotXYZ(v,300,1333)
                        --if pred and not GetBlock(me.x,me.y,pred[1],pred[2],v,125,true) then
                                if lowenemy == nil then
                                        lowenemy = v
                                elseif (lowenemy.health) > (v.health) then
                                        lowenemy = v
                                end
                        --end
                end
        end
        target = lowenemy
end
 
 
function Key( msg, code )
    if code == 13  then
        if msg == KEY_UP and chatting[2] then
            chatting[1] = (not chatting[1])
        end
        chatting[2] = (not chatting[2])
        end
        if chatting[1] then return end
       
                if code == string.byte(hotkey) then Keys[1] = (msg == KEY_DOWN)
        elseif code == string.byte("X") then Keys[2] = (msg == KEY_DOWN)
        end
end
 
function Frame(tick)
   --Target Info
        if target ~= nil and  range ~= 0 then
                drawManager:DrawText(33,50,0xFFFFFFFF,"Target : "..target.name)
                drawManager:DrawText(33,60,0xFFFFFFFF,"Distance : "..GetDistance2D(target,me))
                xyz = SkillShotXYZ(target,0,1333)
        --      if CanCast(me:GetAbility(1)) and target and xyz and not GetBlock(me.x,me.y,xyz[1],xyz[2],target,125) then
        --              drawManager:DrawText(33,70,0xFFFFFFFF,"Can Hook")
        --      end
        elseif range ~= 0 then
                 drawManager:DrawText(33,50,0xFFFFFFFF,"Search Range : "..range)
        end
end
 
script:RegisterEvent(EVENT_TICK,Tick)
script:RegisterEvent(EVENT_FRAME,Frame)
script:RegisterEvent(EVENT_KEY,Key)
