function onSongStart()
	-- Inst and Vocals start playing, songPosition = 0
end

function onStepHit()
    stepdev = curStep % 16;
    if stepdev == 0 then 
        section = curStep / 16;
    end
    if difficulty == 2 then
        movebyStrumLine(90,nil,1,true,false)
        movebyStrumLine(730,nil,1,false,true)
    end
end

function movebyStrumLine(x,y,time,movebf,movedad) 
    if y == nil then 
        if downscroll == true then 
            y = 570
        else
            y = 50
        end
    end

    if time <= 0 then
        if movebf == true then
            for i = 4,7 do 
                setPropertyFromGroup('strumLineNotes', i, 'x', x + ((i - 4) * 112))
                setPropertyFromGroup('strumLineNotes', i, 'y', y)
            end
        end
        if movedad == true then
            for i = 0,3 do 
                setPropertyFromGroup('strumLineNotes', i, 'x', x + (i * 112))
                setPropertyFromGroup('strumLineNotes', i, 'y', y)
            end
        end
    else
        if movebf == true then
            for i = 4,7 do 
                noteTweenX("movementX " .. i, i, x + ((i - 4) * 112), time, "linear")
                noteTweenY("movementY " .. i, i, y, time, "linear")
            end
        end
        if movedad == true then
            for i = 0,3 do 
                noteTweenX("movementX " .. i, i, x + (i * 112), time, "linear")
                noteTweenY("movementY " .. i, i, y, time, "linear")
            end
        end
    end
end 

function coolresetStrums(time)
    for i = 4,7 do
        noteTweenX("movementX " .. i, i, defaultNotePos[i + 1][1], time, "linear")
        noteTweenY("movementY " .. i, i, defaultNotePos[i + 1][2], time, "linear")
        noteTweenAngle("movementAngle " .. i, i, 360, time, "linear")
    end
end
-- I'll admit, most of this code is not written by me, I just got a bunch of codes from other sources and put them in this one script file. I'm really sorry, but I suck at writing lua scripts, or writing any code... - JTSF