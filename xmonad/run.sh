#!/bin/bash

picom -b &
setxkbmap -layout us,ru -option 'grp:alt_shift_toggle' &
feh --bg-fill /home/okulus/Images/macosdra.jpg &

exec xmonad
