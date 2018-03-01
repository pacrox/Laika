// ----------------------------------------------------------------------------------[WINDOW'S WIDTH]---->

//											
//				LAIKA CORE FUNCTIONS.					
//											
//											
//											
// * Updated for KoS 1.1.5.0.								
// * Upgraded to lib_laikaUI.								
//											

@LAZYGLOBAL OFF.
PARAMETER _boot IS TRUE.

GLOBAL LK_VER	IS "в.1.0.2".

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
//SET TERMINAL:WIDTH TO 50. 	// Minimum width:  46
//SET TERMINAL:HEIGHT TO 36.	// Minimum height: 24

GLOBAL LAIKA	IS "Лайка Модульный Компьютер " +LK_VER.
GLOBAL LK_CONF	IS LEXICON().
GLOBAL LK_ADDON	IS LIST().


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

//LOAD("/lib/", "lib_lk_gui").
//RUNPATH("0:/lib/laika/lib_laikaUI.ks").
LOAD("/lib/", "lib_laikaUI").
LOAD("/", "config.lk").

//					
//    MENU REGISTRY 			
//					
// {{{
GLOBAL UImain IS "ЛАЙКА".
GLOBAL UIback IS "НАЗАД".

GLOBAL LK_MOD IS LEXICON(
	"MAIN", UIinitMenu( 0, UImain, LEXICON(
		0, LIST( UIback, { gotoMenu(LK_MOD["SYSTEM"]).}))
	),
	"SYSTEM", UIinitMenu( 0, "SYSTEM", LEXICON(
		7, LIST("QUIT", {SET QUIT TO TRUE.}),
		8, LIST("REBOOT", {WAIT 0.5. REBOOT.}))
	)	
).
// }}}

//					
//    DAEMONS REGISTRY			
//					
// {{{
GLOBAL DAEMONS IS LEXICON(
//	"LCI",	D_LCI@		// Laika Core Informations
).

// }}}

//					
//    DAEMONS EXECUTION HELPERS 	
//					
// {{{
FUNCTION CALL_D {		// CALL all Daemons
//	LOCAL m IS GUIMenuName.	// current menu

	// Call daemons
	FOR k IN DAEMONS:KEYS { DAEMONS[k](). }

	IF UIcurrMenu:HASKEY("daemon")
		FOR i IN UIcurrMenu["daemon"] i:CALL().

	// Call menu specific daemons
//	FOR i IN LK_CMDS[m][1] { i(). }
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

GLOBAL QUIT	IS FALSE.

SET CONFIG:IPU	TO LK_CONF["CPU_SPEED"].
GLOBAL CLOCK	IS LK_CONF["CPU_CLOCK"].
GLOBAL CLOCK	IS 0.05.

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
FOR m IN LK_ADDON {
	//RUNPATH( LK_CONF["MODS_DISK"] +":/mod/" + m[0], m[1], m[2], m[3], m[4]).
	RUNPATH( LK_CONF["MODS_DISK"] +":/mod/" + m[0], m[1], m[2], m[3], m[4]).
}
// }}}

PRINT " " +endl +LAIKA.
PRINT "Ладно.".
WAIT 2.
PRINT BEEP.

UIsetMenu(LK_MOD["MAIN"]).
UIupdate().

//					
//    MAIN LOOP 			
//					
// {{{
LOCAL cs IS CONFIG:IPU.
LOCAL keyCur IS 0.
UNTIL QUIT {
	// Check if term has been resized
	IF TERMINAL:WIDTH <> SCR[0] OR TERMINAL:HEIGHT <> SCR[1] {
		SET CONFIG:IPU	TO 1000.
		UIupdate().
		SET CONFIG:IPU	TO cs.
	}

	// Check AG-keys
	IF AG7 { navUI["btn:next"](). AG7 OFF. }	// [NEXT]
	IF AG8 { navUI["btn:prev"](). AG8 OFF. }	// [PREV]
	IF AG9 { navUI["btn:enter"](). AG9 OFF. }	// [ENTER]

	// Check keyboard-keys
	IF TERMINAL:INPUT:HASCHAR() {
		SET keyCur TO UNCHAR(TERMINAL:INPUT:GETCHAR()).
		IF keyMap:HASKEY(keyCur)
			navUI[keyMap[keyCur]]:CALL().
	}
	
	CALL_D.		// Call all daemons.

	WAIT CLOCK.
}
// }}}

SET CONFIG:IPU	TO 200.
CLEARSCREEN.
PRINT "Готов.".

// last size: 3491b
// last size: 3667b
// last size: 3780b
// last size: 3824b
// last size: 4444b
// last size: 4955b

// vim: fdc=6 fdm=marker :
