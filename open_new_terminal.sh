#!/bin/sh
#Script nw opens a new Terminal window
oascript <<EOF
tell app "System Events"
  keystroke "n" using command down
end tell
EOF
