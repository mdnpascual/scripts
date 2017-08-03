#include <Constants.au3>

Opt("WinTitleMatchMode", 2)
HotKeySet("{ESC}","Quit")

Global $count = 1
Global $MousePos = MouseGetPos()
Global $clip = ""

While True
   ;Serial number
   MouseClick($MOUSE_CLICK_LEFT, 2706, 11, 1) ; 2706, 11
   Sleep(100)
   Send("{SHIFTDOWN}")
   Sleep(50)
   Send("{LEFT}")
   Sleep(50)
   Send("{HOME}")
   Sleep(50)
   Send("{SHIFTUP}")
   Sleep(50)
   Send("{CTRLDOWN}c{CTRLUP}")
   Sleep(50)
   MouseClick($MOUSE_CLICK_LEFT, 464, 291, 1) ; 2706, 11
   Sleep(75)
   Send("{CTRLDOWN}v{CTRLUP}")
   Sleep(75)
   ;BIOS VER
   MouseClick($MOUSE_CLICK_LEFT, 2706, 11, 1) ; 2706, 11
   Sleep(100)
   Send("{DOWN}")
   Sleep(50)
   Send("{END}")
   Sleep(50)
   Send("{SHIFTDOWN}")
   Sleep(50)
   Send("{LEFT}")
   Sleep(50)
   Send("{HOME}")
   Sleep(50)
   Send("{SHIFTUP}")
   Sleep(50)
   Send("{CTRLDOWN}c{CTRLUP}")
   Sleep(50)
   MouseClick($MOUSE_CLICK_LEFT, 530, 318, 1) ; 2706, 11
   Sleep(75)
   Send("{CTRLDOWN}v{CTRLUP}")
   Sleep(75)
   ;Model Number
   MouseClick($MOUSE_CLICK_LEFT, 2706, 11, 1) ; 2706, 11
   Sleep(100)
   Send("{DOWN}")
   Sleep(50)
   Send("{END}")
   Sleep(50)
   Send("{SHIFTDOWN}")
   Sleep(50)
   Send("{LEFT}")
   Sleep(50)
   Send("{HOME}")
   Sleep(50)
   Send("{SHIFTUP}")
   Sleep(50)
   Send("{CTRLDOWN}c{CTRLUP}")
   Sleep(50)
   MouseClick($MOUSE_CLICK_LEFT, 875, 264, 1) ; 2706, 11
   Sleep(50)
   Send("{CTRLDOWN}v{CTRLUP}")
   Sleep(50)
   ;Processor
   MouseClick($MOUSE_CLICK_LEFT, 2706, 11, 1) ; 2706, 11
   Sleep(100)
   Send("{DOWN}")
   Sleep(50)
   Send("{END}")
   Sleep(50)
   Send("{SHIFTDOWN}")
   Sleep(50)
   Send("{LEFT}")
   Sleep(50)
   Send("{HOME}")
   Sleep(50)
   Send("{SHIFTUP}")
   Sleep(50)
   Send("{CTRLDOWN}c{CTRLUP}")
   Sleep(50)
   MouseClick($MOUSE_CLICK_LEFT, 872, 291, 1) ; 2706, 11
   Sleep(75)
   Send("{CTRLDOWN}v{CTRLUP}")
   Sleep(75)
   ;RAM
   MouseClick($MOUSE_CLICK_LEFT, 2706, 11, 1) ; 2706, 11
   Sleep(100)
   Send("{DOWN}")
   Sleep(50)
   Send("{END}")
   Sleep(50)
   Send("{SHIFTDOWN}")
   Sleep(50)
   Send("{LEFT}")
   Sleep(50)
   Send("{HOME}")
   Sleep(50)
   Send("{SHIFTUP}")
   Sleep(50)
   Send("{CTRLDOWN}c{CTRLUP}")
   Sleep(50)
   MouseClick($MOUSE_CLICK_LEFT, 827, 318, 1) ; 2706, 11
   Sleep(75)
   Send("{CTRLDOWN}v{CTRLUP}")
   Sleep(75)
   ;OS
   MouseClick($MOUSE_CLICK_LEFT, 2706, 11, 1) ; 2706, 11
   Sleep(100)
   Send("{DOWN}")
   Sleep(50)
   Send("{END}")
   Sleep(50)
   Send("{SHIFTDOWN}")
   Sleep(50)
   Send("{LEFT}")
   Sleep(50)
   Send("{HOME}")
   Sleep(50)
   Send("{SHIFTUP}")
   Sleep(50)
   Send("{CTRLDOWN}c{CTRLUP}")
   Sleep(50)
   MouseClick($MOUSE_CLICK_LEFT, 638, 354, 1) ; 2706, 11
   Sleep(50)
   MouseClick($MOUSE_CLICK_LEFT, 512, 369, 1) ; 2706, 11
   Sleep(75)
   Send("{CTRLDOWN}v{CTRLUP}")
   Sleep(75)
   Send("{ENTER}")
   Sleep(50)
   ;HDD
   MouseClick($MOUSE_CLICK_LEFT, 2706, 11, 1) ; 2706, 11
   Sleep(100)
   Send("{DOWN}")
   Sleep(50)
   Send("{END}")
   Sleep(50)
   Send("{SHIFTDOWN}")
   Sleep(50)
   Send("{LEFT}")
   Sleep(50)
   Send("{HOME}")
   Sleep(50)
   Send("{SHIFTUP}")
   Sleep(50)
   Send("{CTRLDOWN}c{CTRLUP}")
   Sleep(50)
   MouseClick($MOUSE_CLICK_LEFT, 1004, 354, 1) ; 2706, 11
   Sleep(100)
   MouseClick($MOUSE_CLICK_LEFT, 800, 369, 1) ; 2706, 11
   Sleep(50)
   Send("{CTRLDOWN}v{CTRLUP}")
   Sleep(50)
   Send("{ENTER}")
   Sleep(50)
   Send("{RIGHT}")
   Sleep(50)
   MouseClick($MOUSE_CLICK_LEFT, 2706, 11, 1) ; 2706, 11
   Sleep(100)
   Send("{DOWN}")
   Sleep(50)
   Send("{END}")
   Sleep(50)
   Send("{SHIFTDOWN}")
   Sleep(50)
   Send("{LEFT}")
   Sleep(50)
   Send("{HOME}")
   Sleep(50)
   Send("{SHIFTUP}")
   Sleep(50)
   Send("{CTRLDOWN}c{CTRLUP}")
   Sleep(50)
   MouseClick($MOUSE_CLICK_LEFT, 878, 369, 1) ; 2706, 11
   Sleep(200)
   Send("{CTRLDOWN}v{CTRLUP}")
   Sleep(50)
   Send("{ENTER}")
   Sleep(50)
   Send("{RIGHT}")
   Sleep(50)
   MouseClick($MOUSE_CLICK_LEFT, 2706, 11, 1) ; 2706, 11
   Sleep(100)
   Send("{DOWN}")
   Sleep(50)
   Send("{END}")
   Sleep(50)
   Send("{SHIFTDOWN}")
   Sleep(50)
   Send("{LEFT}")
   Sleep(50)
   Send("{HOME}")
   Sleep(50)
   Send("{SHIFTUP}")
   Sleep(50)
   Send("{CTRLDOWN}c{CTRLUP}")
   Sleep(50)
   MouseClick($MOUSE_CLICK_LEFT, 947, 369, 1) ; 2706, 11
   Sleep(200)
   Send("{CTRLDOWN}v{CTRLUP}")
   Sleep(50)
   Send("{ENTER}")
   Sleep(50)
   ;IP
   MouseClick($MOUSE_CLICK_LEFT, 2706, 11, 1) ; 2706, 11
   Sleep(100)
   Send("{DOWN}")
   Sleep(50)
   Send("{END}")
   Sleep(50)
   Send("{SHIFTDOWN}")
   Sleep(50)
   Send("{LEFT}")
   Sleep(50)
   Send("{HOME}")
   Sleep(50)
   Send("{SHIFTUP}")
   Sleep(50)
   Send("{CTRLDOWN}c{CTRLUP}")
   Sleep(50)
   MouseClick($MOUSE_CLICK_LEFT, 497, 450, 1) ; 2706, 11
   Sleep(50)
   MouseClick($MOUSE_CLICK_LEFT, 335, 465, 1) ; 2706, 11
   Sleep(75)
   Send("{CTRLDOWN}v{CTRLUP}")
   Sleep(75)
   Send("{ENTER}")
   Sleep(50)
   MouseClick($MOUSE_CLICK_LEFT, 464, 465, 1) ; 2706, 11
   Sleep(50)
   ;Mac Address (only 1)
   Do
	  MouseClick($MOUSE_CLICK_LEFT, 2706, 11, 1) ; 2706, 11
	  Sleep(100)
	  Send("{DOWN}")
	  Sleep(50)
	  Send("{END}")
	  Sleep(50)
	  Send("{SHIFTDOWN}")
	  Sleep(50)
	  Send("{LEFT}")
	  Sleep(50)
	  Send("{HOME}")
	  Sleep(50)
	  Send("{SHIFTUP}")
	  Sleep(50)
	  Send("{CTRLDOWN}c{CTRLUP}")
	  Sleep(50)
	  ;Mac address split
	  $clip = ClipGet()
	  Local $macArray = StringSplit($clip, "|")
	  For $i = 1 To $macArray[0]
		 MouseClick($MOUSE_CLICK_LEFT, 749, 450, 1) ; 2706, 11
		 Sleep(50)
		 MouseClick($MOUSE_CLICK_LEFT, 584, 465, 1) ; 2706, 11
		 Sleep(75)
		 Local $j = 1
		 While ($j < $i)
			Send("{DOWN}")
			Sleep(50)
			$j = $j + 1
		 WEnd
		 if (Ubound($macArray - 1)) > 1 Then
			Send("a")
			Sleep(50)
			Send("{BS}")
			ClipPut( $macArray[$i] )
			Sleep(50)
		 EndIF
		 Send("{CTRLDOWN}v{CTRLUP}")
		 Sleep(75)
		 Send("{ENTER}")
		 Sleep(50)
		 if (StringInStr( $clip, "|" ) < 1) Then
			MouseClick($MOUSE_CLICK_LEFT, 2706, 11, 1) ; 2706, 11
			Sleep(100)
			Send("{DOWN}")
			Sleep(50)
			Send("{END}")
			Sleep(50)
			Send("{SHIFTDOWN}")
			Sleep(50)
			Send("{LEFT}")
			Sleep(50)
			Send("{HOME}")
			Sleep(50)
			Send("{SHIFTUP}")
			Sleep(50)
			Send("{CTRLDOWN}c{CTRLUP}")
			Sleep(50)
			ExitLoop
		 EndIf
	  Next
   Until StringInStr( $clip, "|" ) < 1
   ;Hostname
   ;;MouseClick($MOUSE_CLICK_LEFT, 2706, 11, 1) ; 2706, 11
   ;;Sleep(100)
   ;;Send("{DOWN}")
   ;;Sleep(50)
   ;;Send("{END}")
   ;;Sleep(50)
   ;;Send("{SHIFTDOWN}")
   ;;Sleep(50)
   ;;Send("{LEFT}")
   ;;Sleep(50)
   ;;Send("{HOME}")
   ;;Sleep(50)
   ;;Send("{SHIFTUP}")
   ;;Sleep(50)
   ;;Send("{CTRLDOWN}c{CTRLUP}")
   ;;Sleep(50)
   MouseClick($MOUSE_CLICK_LEFT, 989, 450, 1) ; 2706, 11
   Sleep(50)
   MouseClick($MOUSE_CLICK_LEFT, 824, 465, 1) ; 2706, 11
   Sleep(50)
   Send("{CTRLDOWN}v{CTRLUP}")
   Sleep(50)
   Send("{ENTER}")
   Sleep(50)
   ;ATAG
   MouseClick($MOUSE_CLICK_LEFT, 2706, 11, 1) ; 2706, 11
   Sleep(100)
   Send("{DOWN}")
   Sleep(50)
   Send("{END}")
   Sleep(50)
   Send("{SHIFTDOWN}")
   Sleep(50)
   Send("{LEFT}")
   Sleep(50)
   Send("{HOME}")
   Sleep(50)
   Send("{SHIFTUP}")
   Sleep(50)
   Send("{CTRLDOWN}c{CTRLUP}")
   Sleep(50)
   MouseClick($MOUSE_CLICK_LEFT, 905, 558, 1) ; 2706, 11
   Sleep(75)
   Send("{CTRLDOWN}v{CTRLUP}")
   Sleep(75)
   CTAG
   MouseClick($MOUSE_CLICK_LEFT, 2706, 11, 1) ; 2706, 11
   Sleep(100)
   Send("{DOWN}")
   Sleep(50)
   Send("{END}")
   Sleep(50)
   Send("{SHIFTDOWN}")
   Sleep(50)
   Send("{LEFT}")
   Sleep(50)
   Send("{HOME}")
   Sleep(50)
   Send("{SHIFTUP}")
   Sleep(50)
   Send("{CTRLDOWN}c{CTRLUP}")
   Sleep(50)
   MouseClick($MOUSE_CLICK_LEFT, 917, 585, 1) ; 2706, 11
   Sleep(75)
   Send("{CTRLDOWN}v{CTRLUP}")
   Sleep(75)
   ;LOCATION
   MouseClick($MOUSE_CLICK_LEFT, 443, 588, 1) ; 2706, 11
   Sleep(50)
   Send("m")
   Sleep(50)
   Send("{DOWN}")
   Sleep(50)
   Send("{DOWN}")
   Sleep(50)
   Send("{DOWN}")
   Sleep(50)
   Send("{DOWN}")
   Sleep(50)
   Send("{DOWN}")
   Sleep(50)
   Send("{DOWN}")
   Sleep(50)
   Send("{DOWN}")
   Sleep(50)
   ;Send("{DOWN}")
   ;Sleep(50)
   ;Send("{DOWN}")
   ;Sleep(50)
   ;Send("{DOWN}")
   ;Sleep(50)
   ;Send("{DOWN}")
   ;Sleep(50)
   ;Send("{DOWN}")
   ;Sleep(50)
   ;Send("{DOWN}")
   ;Sleep(50)
   Send("{ENTER}")
   Sleep(50)
   Send("{TAB}")
   Sleep(50)
   ;Room number
   Send("2")
   Sleep(50)
   Send("3")
   Sleep(50)
   Send("6")
   Sleep(50)
   ;ZONE
   MouseClick($MOUSE_CLICK_LEFT, 506, 669, 1) ; 2706, 11
   Sleep(50)
   Send("{PGDN}")
   Sleep(50)
   Send("{DOWN}")
   Sleep(50)
   Send("{ENTER}")
   Sleep(50)
   ;Dept
   MouseClick($MOUSE_CLICK_LEFT, 506, 642, 1) ; 2706, 11
   Sleep(50)
   Send("D")
   Sleep(50)
   Send("{UP}")
   Sleep(50)
   Send("{UP}")
   Sleep(50)
   Send("{ENTER}")
   Sleep(500)

   MsgWait()

   if $count == 10 Then
	  $count = -2
   EndIf

   $MousePos = MouseGetPos()
   Sleep(50)
   MouseClick($MousePos[0], $MousePos[1]);
   Sleep(50)
   MouseClick($MousePos[0], $MousePos[1]);
   Sleep(50)
   MouseDown($MOUSE_CLICK_LEFT);
   Sleep(50)
   MouseMove($MousePos[0]-(25*$count), $MousePos[1]-(25*$count), 4);
   Sleep(200)
   MouseUp($MOUSE_CLICK_LEFT);
   $count = $count + 1
WEnd

Func MsgWait()
    $input1 = MsgBox(0, "randometext", "Forward cursor on notepad, click add new hardware, position mouse before entering ok")
    Switch $input1
        Case 1
            ConsoleWrite("OK!" & @CRLF)
    EndSwitch
EndFunc

Func Quit()
    Exit
 EndFunc

 ;BIOS VER
   ;MouseClick($MOUSE_CLICK_LEFT, 2706, 11, 1) ; 2706, 11
   ;Sleep(100)
   ;Send("{DOWN}")
   ;Sleep(50)
   ;Send("{END}")
   ;Sleep(50)
   ;Send("{SHIFTDOWN}")
   ;Sleep(50)
   ;Send("{LEFT}")
   ;Sleep(50)
   ;Send("{HOME}")
   ;Sleep(50)
   ;Send("{SHIFTUP}")
   ;Sleep(50)
   ;Send("{CTRLDOWN}c{CTRLUP}")
   ;Sleep(50)
   ;MouseClick($MOUSE_CLICK_LEFT, 579, 381, 1) ; 2706, 11
   ;Sleep(50)
   ;Send("{CTRLDOWN}v{CTRLUP}")
   ;Sleep(50)
