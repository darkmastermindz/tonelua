local midi = require('luamidi')
local json = require('dkjson')

-- Serialized JSON data from Tone.js (or similar format)
local serialized_data = [[
{
    "tracks": [
        {
            "notes": [
                {"time": 0, "note": "C4", "duration": 1},
                {"time": 1, "note": "E4", "duration": 1},
                {"time": 2, "note": "G4", "duration": 1},
                {"time": 3, "note": "B4", "duration": 1}
            ]
        }
    ]
}
]]

-- Deserialize JSON data
local data = json.decode(serialized_data)

-- Create a MIDI file
local mf = midi.new_midi_file()

-- Set MIDI file properties
mf:setTicksPerQuarter(480)

-- Add a new track
local track = mf:addTrack()

local function note_to_midi_number(note)
    local note_names = {C=0, D=2, E=4, F=5, G=7, A=9, B=11}
    local octave, name, accidental = note:match('(%d)([ABCDEFG])(#|b?)')
    local semitones = note_names[name] + (accidental == '#' and 1 or (accidental == 'b' and -1 or 0))
    return (tonumber(octave) + 1) * 12 + semitones
end

-- Add events to the track
for _, track_data in ipairs(data.tracks) do
    for _, note_data in ipairs(track_data.notes) do
        local note_number = note_to_midi_number(note_data.note)
        local time = note_data.time * mf:getTicksPerQuarter()
        local duration = note_data.duration * mf:getTicksPerQuarter()

        -- Add Note On event
        track:addEvent(midi.new_event(midi.EVENT_NOTE_ON, time, 1, note_number, 127))

        -- Add Note Off event
        track:addEvent(midi.new_event(midi.EVENT_NOTE_OFF, time + duration, 1, note_number))
    end
end

-- Save the MIDI file
mf:save("output.mid")
