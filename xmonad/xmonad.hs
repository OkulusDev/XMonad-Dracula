-- Important stuff
import XMonad
import XMonad.Core

-- Hotkeys 
import XMonad.Util.EZConfig
import XMonad.Util.Ungrab

-- ThreeCol Layout
import XMonad.Layout.ThreeColumns

-- Fullscreen
import XMonad.Hooks.EwmhDesktops
import XMonad.Layout.NoBorders

-- Swap master
import qualified XMonad.StackSet as W

-- Xmobar
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.StatusBar
import XMonad.Util.Loggers


term       = "alacritty"
rofi       = "~/.config/rofi/launchers/type-4/launcher.sh"
powermenu  = "~/.config/rofi/powermenu/type-1/powermenu.sh"
restartCmd = "if type xmonad; then xmonad --recompile && xmonad --restart; else xmessage xmonad not in \\$PATH: \"$PATH\"; fi"
scrot      = "scrot"

volmute    = "~/.config/xmonad/dunstvol mute"
volup      = "~/.config/xmonad/dunstvol up"
voldown    = "~/.config/xmonad/dunstvol down"

colorFocused = "#50fa7b"
colorNormal  = "#171a25"

-- Layouts configuration
myLayout = smartBorders tiled ||| threeCol ||| Mirror tiled ||| noBorders Full
  where
    threeCol = ThreeColMid nmaster delta ratio
    tiled    = Tall nmaster delta ratio
    nmaster  = 1      -- Default number of windows in the master pane
    ratio    = 1/2    -- Default proportion of screen occupied by master pane
    delta    = 3/100  -- Percent of screen to increment by when resizing panes

-- Floating rules
myManageHook = composeAll
    [ className =? "feh" --> doFloat
    , className =? "mpv" --> doFloat
    ]

-- Main config
myConfig = def 
	{ layoutHook         = myLayout
	, modMask            = mod4Mask
	, terminal           = term
	, borderWidth        = 3
	, workspaces         = [" 1 ", " 2 ", " 3 ", " 4 "]
	, normalBorderColor  = colorNormal
	, focusedBorderColor = colorFocused
	, manageHook = myManageHook <+> manageHook def
	}
	`additionalKeysP`
	[ ("M-<Return>", 	spawn term            	)
	, ("M-q", 		kill			)

	, ("M-<Space>", 	sendMessage NextLayout 	)
	, ("M-S-<Return>",	windows W.swapMaster 	)

	, ("M-C-q",		spawn restartCmd	)

	, ("M-d", 		spawn rofi              )
	, ("M-p",       spawn powermenu         )
	, ("<Print>", 		unGrab *> spawn scrot   )

	, ("<XF86AudioMute>", 	spawn volmute		)
	, ("<XF86AudioRaiseVolume>", spawn volup	)
	, ("<XF86AudioLowerVolume>", spawn voldown	)
	]

myXmobarPP :: PP
myXmobarPP = def
    { ppSep             = grey  "•"
    , ppTitleSanitize   = xmobarStrip
    , ppCurrent         = pureWhite . wrap " " "" . xmobarBorder "VBoth" colorFocused 4
    , ppHidden          = lowWhite . wrap " " ""
    , ppHiddenNoWindows = grey . wrap " " ""
    , ppUrgent          = red . wrap (yellow "!") (yellow "!")
    , ppOrder           = \[ws, l, _, wins] -> [ws, l, wins]
    , ppExtras          = [logTitles formatFocused formatUnfocused]
    }
  where
    formatFocused   = wrap (white    "[") (white    "]") . red    . ppWindow
    formatUnfocused = wrap (lowWhite "[") (lowWhite "]") . grey . ppWindow

    -- | Windows should have *some* title, which should not not exceed a
    -- sane length.
    ppWindow :: String -> String
    ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 12

    blue, lowWhite, magenta, red, white, yellow :: String -> String
    pureWhite = xmobarColor "#ffffff" ""
    magenta   = xmobarColor "#bd93f9" ""
    blue      = xmobarColor "#8be9fd" ""
    white     = xmobarColor "#f8f8f2" ""
    yellow    = xmobarColor "#f1fa8c" ""
    red       = xmobarColor "#ff5555" ""
    lowWhite  = xmobarColor "#b8b8b8" ""
    grey      = xmobarColor "#44475a" ""

main :: IO ()
main =    xmonad 
	. ewmhFullscreen 
	. ewmh 
	. withEasySB (statusBarProp "xmobar" (pure myXmobarPP)) defToggleStrutsKey
	$ myConfig
