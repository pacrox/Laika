// ----------------------------------------------------------------------------------[WINDOW'S WIDTH]---->

//											
//				LAIKA CORE FUNCTIONS.					
//											
//											
//											
// * Updated for KoS 1.1.5.0.								
//											

@LAZYGLOBAL OFF.
PARAMETER _boot IS TRUE.

GLOBAL LK_VER	IS "в.0.9.5".

//					
//    INITIAL SETUP			
//					
// {{{
IF _boot {
	CLEARSCREEN.
	CORE:DOACTION("open terminal", TRUE).
	PRINT "Загрузка...".
}

// Default screen dimensions. (Laika supports dynamic screen resizing)
//SET TERMINAL:WIDTH TO 50. 	// Minimum width: 44
//SET TERMINAL:HEIGHT TO 36.
LOCAL mTW IS 46.	// Minimum Terminal width
LOCAL mTH IS 24.	// Minimum Terminal Height

GLOBAL LAIKA	IS "Лайка Модульный Компьютер " +LK_VER.
GLOBAL LK_CONF	IS LEXICON().
GLOBAL LK_MOD	IS LIST().

GLOBAL msgModF IS " Установлен: ".	// "INSTALLED:"

WAIT 1.
PRINT "  Казненный: laika_core.".

GLOBAL beep IS CHAR(7).
GLOBAL endl IS CHAR(10).
GLOBAL quote IS CHAR(34).
// }}}

//					
//    FILES AND LIB LOADER FUNCTIONS 	
//					
// {{{
FUNCTION LOAD {
	PARAMETER dir,
		file.

	RUNPATH(dir+file).
	PRINT "  Казненный: "+file+".".
}
// }}}

//					
//    VOLUMES INFORMATION FUNCTION 	
//					
// {{{
GLOBAL VOL IS 0.
LIST VOLUMES IN VOL.

IF VOL:LENGTH > 2 {
	PRINT " Информация: found "+(VOL:LENGTH-2)+" volume(s).".
}
//}}}

//					
//    RESOURCES PARSER 			
//					
// {{{
LOCAL RES IS 0.
LIST RESOURCES IN RES.

LOCAL k IS 0.
FOR i IN RES {
	IF i:NAME = "ElectricCharge" {
		GLOBAL BATTERIES IS k.
	}
	SET k TO k+1.
}

// Battery capacity conversion factors
LOCAL BAT_CPM IS RES[BATTERIES]:CAPACITY/6000.		// BATtery Capacity Per Minute in %.
LOCAL BAT_CPS IS RES[BATTERIES]:CAPACITY/100.		// BATtery Capacity Per Second in %.
//}}}

//					
//    LIB_LK_GUI HELPERS		
//					
// {{{
FUNCTION SHOW_MENU {
	PARAMETER m.

	GUI_drawMenuScreen(m, LK_MENUS[m][0], LK_MENUS[m][1]).
	GUI_setChoice(1).
	DUPDATE.
}

FUNCTION DUPDATE {
	IF LK_CMDS[GUIMenuName][2]:HASKEY("DISP")
		LK_CMDS[GUIMenuName][2]["DISP"]().
}

LOCAL ERLN IS "".
FUNCTION SUPDATE {
	UNTIL FALSE {
		IF TERMINAL:WIDTH < mTW SET TERMINAL:WIDTH TO mTW.
		IF TERMINAL:HEIGHT < mTH SET TERMINAL:HEIGHT TO mTH.
		SET SCR[0] TO TERMINAL:WIDTH.
		SET SCR[1] TO TERMINAL:HEIGHT.
		WAIT 0.2.
		IF TERMINAL:WIDTH = SCR[0] AND TERMINAL:HEIGHT = SCR[1]
			BREAK.
	}
	SET DIS[2] TO SCR[0]-(DIS[0]*2)-MOD(SCR[0],2).
	SET DIS[3] TO SCR[1]-DIS[1]-15.

	UNTIL ERLN:LENGTH > DIS[2]
		SET ERLN TO ERLN + " ".
}

FUNCTION DPRINT {
	PARAMETER t,
		x, y.

	SET t TO t:TOSTRING.
	LOCAL l IS t:LENGTH.
	IF l = 0 RETURN.

	IF x = "c" SET x TO ROUND((DIS[2]-t:LENGTH)/2).
	ELSE IF x < 0 SET x TO DIS[2] +x.
	IF y < 0 SET y TO DIS[3] +y.
	IF x >= DIS[2] RETURN.
	IF y >= DIS[3] OR y < 0 RETURN.

	IF x >= 0 {
		LOCAL ax IS DIS[2]-x.
		IF l > ax
			SET t TO t:SUBSTRING(0, ax).
	} ELSE {
		IF l <= -x RETURN.
		SET t TO t:SUBSTRING(-x, l+x).
		IF l+x > DIS[2]
			SET t TO t:SUBSTRING(0, DIS[2]).
		SET x TO 0.
	}

	PRINT t AT(DIS[0]+x, DIS[1]+y).
}

FUNCTION DLINE {
	PARAMETER c, y.

	LOCAL l IS "".
	UNTIL l:LENGTH > DIS[2]
		SET l TO l +c.

	DPRINT(l, 0, y).
}

FUNCTION DCLEAR {
	PARAMETER a IS DIS.

	LOCAL w IS ERLN:SUBSTRING(0, a[2]).
	LOCAL i IS a[1].
	UNTIL i >= (a[1]+a[3]) {
		PRINT w AT(a[0], i).
		SET i TO i +1.
	}
}
// }}}

LOAD("/lib/", "lib_lk_gui").
LOAD("/", "config.lk").

//					
//    MENU REGISTRY 			
//					
// {{{
GLOBAL LK_MAIN IS "ЛАЙКА".

//											
// LK_MENUS LEXICON( menu_name, LIST( back_menu, LIST(btn_name), LIST(is_submenu?) ) )	
//											
//	LK_MENUS[menu_name][0] = back_menu						
//	                   [1] = LIST(btn_name)						
//			   [2] = LIST(is_submenu?)					
//											
GLOBAL LK_MENUS IS LEXICON(
	LK_MAIN, LIST( "SYSTEM",
		LIST( "", "", "", "", "", "", "", "" ),
		LIST( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE )),
	"SYSTEM", LIST( LK_MAIN,
		LIST( "", "", "", "QUIT", "", "", "", "REBOOT" ), 
		LIST( FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE ))
).

//											
// LK_CMDS LEXICON( menu_name, LIST( LEXICON(btn_name, function), LIST(daemons) ) )	
//											
//	LK_CMDS[menu_name][0] = LEXICON(btn_name, function)				
//	                  [1] = LIST(daemons)						
// 											
GLOBAL LK_CMDS IS LEXICON(
	LK_MAIN, LIST(
			LEXICON(),
			LIST(), LEXICON()),
	"SYSTEM", LIST( 
			LEXICON(
				"QUIT",		{ SET QUIT TO TRUE. },
				"REBOOT",	{ WAIT 0.5. REBOOT. }),
			LIST(), LEXICON())
).

// MENU COMMANDS PARSER {{{
FUNCTION EXEC_MC {		// EXECute_MenuCommand
	LOCAL c IS GUIChoices[GUICurrChoice][0].
	LOCAL m IS GUIMenuName.

	IF LK_CMDS[m][0]:HASKEY(c) {
		LK_CMDS[m][0][c]().
	}

	LOCAL b IS GUIChoices[GUICurrChoice][3].
	IF LK_MENUS[GUIMenuName][2][b] {
		SHOW_MENU(LK_MENUS[GUIMenuName][1][b]).
	} 
} // }}}

// }}}

//					
//    DAEMONS REGISTRY			
//					
// {{{
GLOBAL DAEMONS IS LEXICON(
	"LCI",	D_LCI@		// Laika Core Informations
).

// }}}

//					
//    DAEMONS EXECUTION HELPERS 	
//					
// {{{
FUNCTION CALL_D {		// CALL all Daemons
	LOCAL m IS GUIMenuName.	// current menu

	// Call daemons
	FOR k IN DAEMONS:KEYS { DAEMONS[k](). }

	// Call menu specific daemons
	FOR i IN LK_CMDS[m][1] { i(). }
}

FUNCTION D_LCI {		// Display Laika Core Informations
	LOCAL s IS "1: "+VOL[1]:FREESPACE+"b".
	PRINT "   "+s+"   " AT((SCR[0]-s:LENGTH)/2-3, SCR[1]-6).
	SET s TO "DISK SPACE:".
	PRINT s AT((SCR[0]-s:LENGTH)/2, SCR[1]-7).

	SET s TO "POWER DRAIN:".
	PRINT s AT((SCR[0]-s:LENGTH)/2, SCR[1]-10).
	SET s TO ROUND(CORE:GETFIELD("KOS AVERAGE POWER")/BAT_CPM,2)+"%/m".
	PRINT "   "+s+"   " AT((SCR[0]-s:LENGTH)/2-3, SCR[1]-9).

	SET s TO "  "+ROUND(RES[BATTERIES]:AMOUNT/BAT_CPS)+"%".
	PRINT s AT((SCR[0]-s:LENGTH)-1, 0).
}
// }}}

//					
//    USER INTERFACE NAVIGATION 	
//					
// {{{

// A table that defines UI_Nav-Actions.
GLOBAL UI_NAV IS LEXICON(
	 1,	{GUI_setChoice(GUICurrChoice+1).},		// NEXT
	-1,	{GUI_setChoice(GUICurrChoice-1).},		// PREV
	 0,	{						// ENTER
			IF GUIChoices[GUICurrChoice][0] = "BACK" {
				UI_NAV[2]().		// BACK
			} ELSE { PRINT beep. EXEC_MC. }
		},
	 2,	{ IF GUIMenuBack <> "" {
			PRINT beep. SHOW_MENU(GUIMenuBack).} }	// BACK
).

// A table to link the Key-Pressed to the UI_Nav-Action.
GLOBAL UI_KEY IS LEXICON(
	55,	 1,		// '7' key	[NEXT]
	56,	-1,		// '8' key	[PREV]
	57,	 0,		// '9' key	[ENTER]
	57351, 	-1,		// UP    key	[PREV]
	57352, 	 1,		// DOWN  key	[NEXT]
	57353, 	 2,		// LEFT  key	[BACK]
	57354, 	 0		// RIGHT key	[ENTER]
).
//}}}

GLOBAL SCR	IS LIST(0, 0).		// Width, Height
GLOBAL DIS	IS LIST(1, 2, 0, 0).	// OriginX, OriginY, W, H.
GLOBAL QUIT	IS FALSE.

SET CONFIG:IPU	TO LK_CONF["CPU_SPEED"].
GLOBAL CLOCK	IS LK_CONF["CPU_CLOCK"].

//					
//    LOAD MODULES			
//					
// {{{
// Update the fields of the input lexicon with the one from the second
FUNCTION import {
	PARAMETER i,	// Input Lexicon
		a.	// Lexicon to add

	IF (NOT (i):ISTYPE("Lexicon")) SET i TO LEXICON().

	IF (a):ISTYPE("Lexicon")
		FOR k IN a:KEYS
			IF NOT i:HASKEY(k)
				i:ADD(k, a[k]).
	RETURN i.
}

// Loads all the modules that where listed in the config file.
FOR m IN LK_MOD {
	RUNPATH( LK_CONF["MODS_DISK"] +":/mod/" + m[0], m[1], m[2], m[3], m[4]).
}
// }}}

PRINT " " +endl +LAIKA.
PRINT "Ладно.".
WAIT 2.
PRINT BEEP.

SUPDATE.
SHOW_MENU(LK_MAIN).

//					
//    MAIN LOOP 			
//					
// {{{
UNTIL QUIT {
	// Check if term has been resized
	IF TERMINAL:WIDTH <> SCR[0] OR TERMINAL:HEIGHT <> SCR[1] {
		SUPDATE.
		GUI_redrawMenuScreen().
		DUPDATE.
	}

	// Check AG-keys
	IF AG7 { UI_NAV[ 1](). AG7 OFF. }	// [NEXT]
	IF AG8 { UI_NAV[-1](). AG8 OFF. }	// [PREV]
	IF AG9 { UI_NAV[ 0](). AG9 OFF. }	// [ENTER]

	// Check keyboard-keys
	IF TERMINAL:INPUT:HASCHAR() {
		LOCAL kp IS UNCHAR(TERMINAL:INPUT:GETCHAR()).
		IF UI_KEY:HASKEY(kp) {
			UI_NAV[UI_KEY[kp]](). 	// Call UI key action
		}
	}
	
	CALL_D.		// Call all daemons.

	WAIT CLOCK.
}
// }}}

SET CONFIG:IPU	TO 200.
CLEARSCREEN.
PRINT "Готов.".

// last size: 3491b - 0.07%/m
// last size: 3667b - 0.07%/m
// last size: 3780b
// last size: 3824b
// last size: 4444b
// last size: 4955b

// vim: fdc=6 fdm=marker :
