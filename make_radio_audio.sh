#!/bin/bash
# make_radio_audio.sh — generates synthetic radio clips for both incident scenarios.
# macOS only (uses the built-in `say`). Requires ffmpeg: brew install ffmpeg
#
#   chmod +x make_radio_audio.sh
#   ./make_radio_audio.sh
#
# Output: ./audio/fire/m1..m6.mp3 and ./audio/storm/m1..m5.mp3

set -e
mkdir -p audio/fire audio/storm tmp

# Voice per role. Keep a voice tied to one unit across both scenarios.
V_DISPATCH="Tom"        # Dispatch
V_UNIT_A="Alex"         # Engine 4 / Unit 12
V_UNIT_B="Fred"         # Engine 7
V_COMMAND="Daniel"      # Incident Command / Supervisor

# Radio character: narrowband voice channel + digital artifact.
RADIO="highpass=f=300,lowpass=f=3000,acrusher=bits=8:mode=log,volume=1.4"
# Heavier treatment for the deliberately unclear transmission.
RADIO_BAD="highpass=f=450,lowpass=f=2200,acrusher=bits=5:mode=log,volume=1.2,aecho=0.8:0.6:40:0.4"

speak () {  # speak <voice> <rate> <outfile> <text>
  say -v "$1" -r "$2" -o "tmp/$3.aiff" "$4"
}

radioize () {  # radioize <name> <dir> <filter>
  ffmpeg -loglevel error -i "tmp/$1.aiff" -af "$3" \
    -ar 22050 -ac 1 -b:a 64k "audio/$2/$1.mp3" -y
}

echo "=== Warehouse fire (6 transmissions) ==="
speak "$V_DISPATCH" 180 m1 "Commercial warehouse fire at 2400 Harbor Road. Units E4 and E7 responding."
speak "$V_UNIT_A"   190 m2 "Smoke visible on the east side. We are approaching the east entrance."
speak "$V_DISPATCH" 180 m3 "East entrance is closed. All arriving units use the north access road."
speak "$V_UNIT_B"   195 m4 "Two crew members entering from the north. Requesting ventilation support."
speak "$V_UNIT_A"   210 m5 "Command, be advised, second floor, uh, cannot confirm, repeat, cannot confirm."
speak "$V_COMMAND"  175 m6 "Request evacuation of the adjacent office. Confirm all units have received the north access update."

for n in 1 2 3 4 6; do radioize "m$n" fire "$RADIO"; done
radioize m5 fire "$RADIO_BAD"          # message 5 is the unclear one
echo "    -> audio/fire/"

echo "=== Storm response (5 transmissions) ==="
speak "$V_DISPATCH" 180 s1 "Reports of a downed power line near Oak Street and 5th Avenue. Utility team notified."
speak "$V_UNIT_A"   190 s2 "We have closed Oak Street at 4th Avenue. Pedestrians are gathering near the intersection."
speak "$V_DISPATCH" 180 s3 "Utility estimated arrival is 15 minutes. Do not approach the line."
speak "$V_UNIT_A"   215 s4 "Dispatch, we may have a, possible second wire, stand by, unable to confirm."
speak "$V_COMMAND"  175 s5 "Request a second unit to manage the pedestrian perimeter."

for n in 1 2 3 5; do
  ffmpeg -loglevel error -i "tmp/s$n.aiff" -af "$RADIO" -ar 22050 -ac 1 -b:a 64k "audio/storm/m$n.mp3" -y
done
ffmpeg -loglevel error -i "tmp/s4.aiff" -af "$RADIO_BAD" -ar 22050 -ac 1 -b:a 64k "audio/storm/m4.mp3" -y
echo "    -> audio/storm/"

rm -rf tmp
echo
echo "Done. Listen to audio/fire/m5.mp3 and audio/storm/m4.mp3 —"
echo "those two should sound noticeably degraded. That is the point:"
echo "the Safety agent withholds the fact they contain."
echo
echo "To hear the available voices:  say -v '?'"
