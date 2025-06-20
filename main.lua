local midi = require("midi")

local opus = midi.midi2opus(love.filesystem.read("Raise Up Your Bat.mid"))
local ticks = opus[1]
local notes = {}
local latestHold = nil
local tempos = {}
local events = {}
local trackTimes = {}

for i = 2, #opus do
    trackTimes[i] = 0
    ---@diagnostic disable-next-line: param-type-mismatch
    for _, event in ipairs(opus[i]) do
        trackTimes[i] = trackTimes[i] + event[2]
        table.insert(events, {
            time = trackTimes[i],
            event = event
        })
    end
end

table.sort(events, function(a, b)
    return a.time < b.time
end)

for _, e in ipairs(events) do
    local dt = e.time
    local event = e.event

    if event[1] == "note_on" or event[1] == "note_off" then
        if event[1] == "note_on" then
            if event[4] == 39 then
                latestHold = {
                    type = "hold_left",
                    start = (dt / ticks),
                    end_ = nil,
                    note = event[4]
                }
                table.insert(notes, latestHold)
            elseif event[4] == 38 then
                if not (latestHold and latestHold.type == "hold_left" and latestHold.end_ == nil) then
                    table.insert(notes, {
                        type = "normal_left",
                        start = (dt / ticks),
                        end_ = nil,
                        note = event[4]
                    })
                end
            elseif event[4] == 35 then
                latestHold = {
                    type = "hold_right",
                    start = (dt / ticks),
                    end_ = nil,
                    note = event[4]
                }
                table.insert(notes, latestHold)
            elseif event[4] == 36 then
                if not (latestHold and latestHold.type == "hold_right" and latestHold.end_ == nil) then
                    table.insert(notes, {
                        type = "normal_right",
                        start = (dt / ticks),
                        end_ = nil,
                        note = event[4]
                    })
                end
            end
        elseif event[1] == "note_off" then
            if latestHold and latestHold.note == event[4] and latestHold.end_ == nil then
                latestHold.end_ = (dt / ticks)
                latestHold = nil
            end
        end
    elseif event[1] == "set_tempo" then
        table.insert(tempos, {
            start = (dt / ticks),
            bpm = math.floor((60000000 / event[3]) + 0.5),
        })
    end
end

local curBPM = 120
for _, note in ipairs(notes) do
    for _, tempo in ipairs(tempos) do
        if note.start >= tempo.start then
            curBPM = tempo.bpm
        end
    end

    note.start = note.start * (60000 / curBPM)
    if note.end_ then
        note.end_ = note.end_ * (60000 / curBPM)
    end
end

local uniqueNotes = {}
for _, note in ipairs(notes) do
    if note.type == "hold_left" or note.type == "hold_right" then
        table.insert(uniqueNotes, note)
    else
        local found = false
        for _, uniqueNote in ipairs(uniqueNotes) do
            if uniqueNote.type == note.type and uniqueNote.start == note.start then
                found = true
                break
            end
        end
        if not found then
            table.insert(uniqueNotes, note)
        end
    end
end

notes = uniqueNotes

local song = love.audio.newSource("Raise Up Your Bat.mp3", "stream")
song:play()

song:seek(13)

local musicTime = song:tell() * 1000
love.graphics.setLineWidth(4)
love.timer.step() -- we step because of the loading times

local receptor1 = {
    x = love.graphics.getWidth() / 2 - 62,
    y = love.graphics.getHeight() / 2 + 100,
    width = 60,
    height = 15,
    color = {13/255,166/255,155/255, 1},
    noteColor = {8/255, 230/255, 165/255, 1}
}

local receptor2 = {
    x = love.graphics.getWidth() / 2+2,
    y = love.graphics.getHeight() / 2 + 100,
    width = 60,
    height = 15,
    color = {86/255,197/255,237/255, 1},
    noteColor = {26/255, 237/255, 254/255, 1}
}


function love.update(dt)
    musicTime = musicTime + (dt * 1000)

    for i, note in ipairs(notes) do
        local receptor = (note.type:find("left") and receptor1) or receptor2
        note.y = math.floor(receptor.y - (note.start - musicTime))
        if note.end_ then
            note.y_end = math.floor(receptor.y - (note.end_ - musicTime))
        end

        if (note.start < musicTime and not note.end_) or (note.end_ and note.end_ < musicTime) then
            table.remove(notes, i)
        end
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Music Time: " .. musicTime, 10, 10)

    love.graphics.setColor(receptor1.color)
    love.graphics.rectangle("line", receptor1.x, receptor1.y, receptor1.width, receptor1.height)
    love.graphics.setColor(receptor2.color)
    love.graphics.rectangle("line", receptor2.x, receptor2.y, receptor2.width, receptor2.height)

    for i, note in ipairs(notes) do
        if note.start < 0 then
            goto continue
        end

        local receptor = (note.type:find("left") and receptor1) or receptor2
        love.graphics.setColor(receptor.noteColor)

        if note.type == "normal_left" or note.type == "normal_right" then
            love.graphics.rectangle("fill", receptor.x, note.y, receptor.width, receptor.height)
        elseif note.type == "hold_left" or note.type == "hold_right" then
            love.graphics.rectangle("fill", receptor.x, note.y, receptor.width, receptor.height)

            if note.end_ then
                love.graphics.rectangle("fill", receptor.x + receptor.width - receptor.width/1.71, note.y_end, receptor.width/4, note.y - note.y_end)
            end
        end


        ::continue::
    end
end