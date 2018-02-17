// ----------------------------------------------------------------------------------[WINDOW'S WIDTH]---->

//									
// LAIKA CONFIGURATOR.							
//									
// The configurator for LAIKA Modular Computer.				
//									
// * Updated for KoS 1.1.5.0.						
//									

@LAZYGLOBAL OFF.

GLOBAL LKC_VER	IS "в.0.9.3.".

//					
// -- INITIAL SETUP --			
//					
// {{{
PRINT "  Казненный: laika_conf.".

LOCAL LAIKA IS "Лайка Модули Конфигурация " +LKC_VER.

GLOBAL LK_MAIN IS "ЛАЙКА".
GLOBAL msgModF IS "  Найденный: ".	// "FOUND:"

SET CONFIG:IPU	TO 500.			// we need faster cpu

// Define special characters
GLOBAL beep	IS char(7).
GLOBAL endl	IS char(10).
GLOBAL quote	IS char(34).
GLOBAL comma	IS char(44).

LOCAL MAGIC	IS "\".

// }}}

//					
// LOAD NECESSARY LIBRARIES		
//					
// {{{
// Configuration for Ozin's libraries.
GLOBAL nameLength 	IS 24.		// width of the names column for lib_menu.
GLOBAL valueLength 	IS 24.		// width of the value column for lib_menu.
GLOBAL selectedLine 	IS 0.		// we need to access 'selectedLine' in lib_menu.

// Loads OZIN libraries.
CD("0:/lib/laika/ozin/").
RUNONCEPATH("lib_menu.ks").
RUNONCEPATH("lib_list.ks").

// Loads PreProcessor.
CD("0:/lib/laika/").
RUNONCEPATH("preprocessor.ks").
SET _PPopts TO LIST("-v", "-c", "-t", "-i"). 
SWITCH TO 1.
// }}}

//					
// LAIKA CONFIGURATION TABLE		
//					
// {{{
GLOBAL LK_CONF IS LEXICON(
	"CPU_CLOCK",		0.05,
	"CPU_SPEED",		200,
	"MAIN_DISK",		1,
	"MODS_DISK",		1
//	"ALW_AGNAV",		TRUE		// Allow ActionGroup Navigation
).

LOCAL VOL IS 0.
LIST VOLUMES IN VOL.

IF VOL:LENGTH > 2 {
	PRINT " Информация: found "+(VOL:LENGTH-2)+" volume(s).".
}
LOCAL LAST_VOL IS VOL:LENGTH-1.

// }}}

//					
// PARSE EXISTING CONFIG FILE		
//					
// {{{
LOCAL conf_file IS "config.lk".
LOCAL C_MOD IS LEXICON().
GLOBAL LK_MOD IS LIST().	// Should be GLOBAL, will be filled by config.lk.
IF EXISTS(conf_file) {
	RUNPATH(conf_file).
	FOR m IN LK_MOD {
		SET m[0] TO m[0]:SUBSTRING(0, m[0]:LENGTH-1).
		IF m[2] = LK_MAIN SET m[2] TO "MAIN".
		
		// C_MOD LEXICON(					
		//	[0]	File name (.ks)				
		//	[1] LIST(					
		//		[0]	Module Menu Name		
		//		[1]	Parent Menu Name		
		//		[2]	Parent Menu Button Number	
		//		[3]	Module Extra Options		
		//		[4]	Module Compile Options		
		//	).						
		// ).							
		C_MOD:ADD(m[0], LIST(m[1], m[2], m[3], m[4])).

		IF m:LENGTH > 5
			C_MOD[m[0]]:ADD(m[5]).
		ELSE
			C_MOD[m[0]]:ADD(FALSE).
	}
}

// Update the fields of the input lexicon with the one from the second
FUNCTION importData {
	PARAMETER i,		// Input Lexicon
		a,		// Lexicon to add
		pres IS FALSE.	// Preserve input structure, do not create missing keys.

	IF (a):ISTYPE("Lexicon")
		FOR k IN a:KEYS
			IF i:HASKEY(k) OR (NOT pres)
				SET i[k] TO a[k].
	RETURN i.
}
// }}}

//					
// SCAN ALL MODULES			
//					
// {{{
// Parse available mods and initialize MODS list.
CD("0:/lib/laika/mod/").
LOCAL FL IS LIST().
LIST FILES IN FL.

// NMODS LIST(										
//	[0]		Full filename (includes extension)				
//	[1]		Is is selected (boolean)					
//	[2] LIST(									
//		[0]*		Module Name (long format)				
//		[1]		Module Short Name (no-space, allcaps)			
//		[2]*LIST()	Module Extra Options (current, default)			
//		[3] LIST()	Informations (description, author)			
//		[4] LIST(3)	Version (MAJOR, MINOR, PATCH)				
//		[5] LIST(3)	UI Placement (self name, parent name, parent btn-num)	
//		[6] LEX(...)	Required Modules (dependencies)				
//		[7] LEX(...)	Configurator Calls					
//		[8] LIST()	Configurator Options (current, default)			
//	)										
// ).											

// 	long_name	Full name of the module (can use spaces)
//	short_name	Abreviated name of acronym of the moduls (no spaces allowed)
// ?	category	Module classification
//	author		Name of the author
//	class		Level required for this module (to be used in career mode)

LOCAL NMODS IS LIST().

GLOBAL MOD_DATA IS LIST().	// Should be GLOBAL, will be filled by runned mods.
LOCAL sel IS FALSE.
FOR f IN FL {
	RUNPATH(f).
	SET sel TO FALSE.
	IF (MOD_DATA[2]):TYPENAME <> "Lexicon"		// Module Options
		SET MOD_DATA[2] TO LEXICON().
	SET MOD_DATA[2] TO LIST(MOD_DATA[2]:COPY).

	IF (MOD_DATA[8]):TYPENAME <> "Lexicon"		// Install Options
		SET MOD_DATA[8] TO LEXICON().
	SET MOD_DATA[8] TO LIST(MOD_DATA[8]:COPY).

	MOD_DATA[2]:ADD(MOD_DATA[2][0]:COPY).		// Copy Default values
	FOR k IN MOD_DATA[2][0]:KEYS
		IF MOD_DATA[2][0][k]:TYPENAME = "Lexicon"
			SET MOD_DATA[2][1][k] TO MOD_DATA[2][0][k]:COPY.
		
	MOD_DATA[8]:ADD(MOD_DATA[8][0]:COPY).		// Copy Default values

	IF C_MOD:HASKEY(f:NAME) {
		SET sel TO TRUE.
		SET MOD_DATA[5][0] TO C_MOD[f:NAME][0].			// Menu Name
		SET MOD_DATA[5][1] TO C_MOD[f:NAME][1].			// Parent Menu Name
		SET MOD_DATA[5][2] TO C_MOD[f:NAME][2].			// Parent Menu Btn Number
		importData(MOD_DATA[2][0], C_MOD[f:NAME][3], TRUE).	// Extra Options
		importData(MOD_DATA[8][0], C_MOD[f:NAME][4], TRUE).	// Install Options
	}

	NMODS:ADD(LIST(f, sel, MOD_DATA:COPY)).

}
SWITCH TO 1.

// The following block add some fake modules for testing purpose.
// It will be soon deleted.
IF FALSE {
	LOCAL FAKE_DATA IS 0.
	LOCAL i IS 0.
	UNTIL i > 90 {
		SET FAKE_DATA TO LIST( "Fake Module "+i, "FMD" +i, LIST(LEXICON(),LEXICON()),
			LIST( "Fake mod description " +i, "Pippo"),
			LIST( 1, 2, 3),
			LIST( "FK" +i, "MAIN", 4),
			LEXICON(),
			LEXICON(),
			LIST(LEXICON(),LEXICON())
		).
		NMODS:ADD(LIST( "fk_mod_" +i +".ks", FALSE, FAKE_DATA:COPY)).
		SET i TO i+1. 
	}
}
// }}}

//					
// MENU PAGINATOR FUNCTIONS		
//					
// {{{
LOCAL currMenuPages	IS LIST().
LOCAL currMenuDescr	IS FALSE.
LOCAL currPage		IS 0.
FUNCTION menuPaginator {   // {{{
	PARAMETER inList,
		menuName,
		backMenu IS mainMenu@.

	SET currMenuPages TO LIST().
	SET currMenuDescr TO LIST().

	LOCAL tPg	IS CEILING(inList:LENGTH / EntriesPerPage). // total number of pages
	LOCAL p 	IS -1.	// used as Page Counter
	LOCAL i 	IS 0.   // used as Item index counter
	UNTIL i >= inList:LENGTH {
		IF MOD(i, EntriesPerPage) = 0 { // checks if the current module is at page beginning
			IF p > -1 {
				currMenuPages[p]:ADD(LIST("-", "text")).
				currMenuDescr[p]:ADD("").
				IF tPg > 1 {
					currMenuPages[p]:ADD(LIST( "NEXT PAGE", "menu", 
						changePage@:bind(p+1))).
					currMenuDescr[p]:ADD("").
				}
				currMenuPages[p]:ADD(LIST("RETURN", "backmenu", 
						switchToMenu@:bind(backMenu))).
				currMenuDescr[p]:ADD("").
			}
			SET p TO p +1. // increase Page Counter

			currMenuPages:ADD(LIST()).
			currMenuDescr:ADD(LIST()).

			IF tPg > 1
				currMenuPages[p]:ADD(
					LIST( menuName +"  (" +(p+1) +"/" +tPg +")", "text")).
			ELSE 
				currMenuPages[p]:ADD(LIST( menuName, "text")).
			currMenuDescr[p]:ADD("").
			currMenuPages[p]:ADD(LIST( "=", "line")).
			currMenuDescr[p]:ADD("").
			currMenuPages[p]:ADD(LIST( " ", "text")).
			currMenuDescr[p]:ADD("").
			IF tPg > 1 {
				IF p = 0 {
					currMenuPages[p]:ADD(LIST( "LAST PAGE", "menu",
						changePage@:bind(tPg-1))).
					currMenuDescr[p]:ADD("").
				} ELSE {
					currMenuPages[p]:ADD(LIST( "PREV PAGE", "menu",
						changePage@:bind(p-1))).
					currMenuDescr[p]:ADD("").
				}
				currMenuPages[p]:ADD(LIST( "-", "text")).
				currMenuDescr[p]:ADD("").
			}
		}
		currMenuPages[p]:ADD(LIST(inList[i][0], inList[i][1], inList[i][2], inList[i][3])).
		currMenuDescr[p]:ADD(inList[i][4]).
		SET i TO i+1.
	}
	currMenuPages[p]:ADD(LIST("-", "text")).
	currMenuDescr[p]:ADD("").
	IF tPg > 1 {
		currMenuPages[p]:ADD(LIST( "FIRST PAGE", "menu", changePage@:bind(0))).
		currMenuDescr[p]:ADD("").
	}
	currMenuPages[p]:ADD(LIST("RETURN", "backmenu", switchToMenu@:bind(backMenu))).

	currMenuDescr[p]:ADD("").
	SET currPage TO 0.
	RETURN currMenuPages[0].
} // }}}

FUNCTION changePage {
	PARAMETER p.

	IF p < 0 SET p TO 0.
	IF p >= currMenuPages:LENGTH SET p TO currMenuPages:LENGTH-1.

	SET currPage TO p.
	RETURN currMenuPages[p].
}

FUNCTION switchToMenu {
	PARAMETER m.

	SET currMenuDescr TO FALSE.
	SET lastline TO -1.

	IF m:TYPENAME = "List"
		RETURN m.
	RETURN m().
}
// }}}

//					
// DEFINE ALL MENUS 			
//					
// {{{
// Initialize menu page's arrays.
LOCAL mainPage		IS LIST().	// [MAIN] menu				
LOCAL LKconfigPage	IS LIST().	// [CONFIG LAIKA MENU] dynamic menu	

LOCAL EntriesPerPage	IS 20.		// number of modules listed on each page

// Current module's description field.
List_Position(1, TERMINAL:WIDTH-2, 30, 36).

// *** [AVAILABLE MODS MENU] ***	
// {{{
LOCAL availModList	IS LIST().
LOCAL _dscr IS 0.
LOCAL i IS 0.
UNTIL i >= NMODS:LENGTH {
	SET _dscr TO depDescr(i).
	availModList:ADD(LIST(NMODS[i][2][0], "bool", toggleMod@:bind(i), FALSE, _dscr)).
	SET i TO i+1.
}

// Function for Mod List Page.
FUNCTION toggleMod {
	PARAMETER o,
		k IS MAGIC.

	IF k <> MAGIC {
		SET NMODS[o][1] TO (NOT NMODS[o][1]).	// Is it selected?
	}
	RETURN NMODS[o][1].				// Is it selected?
}

FUNCTION depDescr {
	PARAMETER i.

	LOCAL d IS 0.
	SET d TO NMODS[i][2][3][0].

	IF NMODS[i][2][6]:LENGTH > 0 {
		SET d TO d +"\Required module".
		IF NMODS[i][2][6]:LENGTH > 1 
			SET d TO d +"s: ".
		ELSE
			SET d TO d +": ".
	}
	IF NMODS[i][2][6]:LENGTH = 0
		RETURN d.
	FOR k IN NMODS[i][2][6]:KEYS {
		SET d TO d +"'" +k +"', ".
	}
	SET d TO d:SUBSTRING(0, d:LENGTH-2) +".".
	RETURN d.
}
// }}}

// *** [MAIN MENU] ***			
// {{{
LOCAL mainPage IS LIST(
	LIST(LAIKA,			"text"),
	LIST("=",			"line"),
	LIST(" ",			"text"),
	LIST("CONFIGURE LAIKA",		"menu",	LKconfigMenu@),
	LIST("-",			"text"),
	LIST("INSTALL MODULES",		"menu",	menuPaginator@:bind(availModList, "AVAILABLE MODS")),
	LIST("CONFIG INSTALLED MODS",	"menu", installedModsPage@),
	LIST("-",			"text"),
	LIST("BUILD LAIKA",		"action", buildConfigFile@ ),
	LIST("-",			"text"),
	LIST("CREDITS",			"action", creditsScreen@),
	LIST("-",			"text"),
	LIST("REBOOT",			"action", { REBOOT. }),
	LIST("EXIT",			"action", { SET done TO TRUE. })
).

LOCAL mainDescr IS LIST( "", "", "",
	"Laika Computer configuration: clock speed, installation disk, etc.", "",
	"Choose modules to install.",
	"Configure modules installed in Laika.", "",
	"Save current configuration, then process and compile Laika core, libraries and modules."
).

FUNCTION mainMenu {
	SET currPage TO 0.
	SET currMenuDescr TO LIST().
	currMenuDescr:ADD(mainDescr).	
	SET lastLine TO -1.
	RETURN mainPage.
}

FUNCTION creditsScreen {
	CLEARSCREEN.

	PRINT "    LAIKA CREDITS" +ENDL +" ".
	PRINT "  - Laika Modular Computer".
	PRINT "  - Laika Computer Configurator".
	PRINT "  - KoS Preprocessor".
	PRINT "      are made and maintained by Pacrox.".
	PRINT "      (https://github.com/pacrox/Laika)".

	PRINT " ".
	PRINT "  - Ozin Libraries".
	PRINT "      were modified form the originals".
	PRINT "      made and maintained by ozin370.".
	PRINT "      (https://github.com/ozin370/Script)".

	PRINT " ".
	PRINT "  - Laika GUI Library (lk_gui)".
	PRINT "      is made and maintained by Pacrox.".
	PRINT "      uses code portions from TDW86.".
	PRINT "      (https://github.com/KSP-KOS/KSLib)".

	PRINT " ".
	PRINT "  - KoS Language Interpreter and Compiler".
	PRINT "      was originally made by Nivekk and".
	PRINT "      is currently mantained by Dunbaratu.".
	PRINT "      (https://github.com/KSP-KOS/KOS)".

	PRINT " ".
	PRINT "      IN MEMORY OF Лайка 1954 - 1957.".
	PRINT "  LAIKA is dedicated to the first space dog.".

	PRINT " " +ENDL +"  [Press any key to close]" +BEEP.
	TERMINAL:INPUT:GETCHAR().
	
	CLEARSCREEN.
	drawAll().
}
// }}}

// *** [INSTALLED MODS MENU] ***	
// {{{
FUNCTION installedModsPage {
	LOCAL pageList IS LIST().

	LOCAL i IS 0.
	FOR m IN NMODS {
		IF m[1]	{		// It is selected.
			pageList:ADD(LIST(m[2][0], "menu", configModPage@:bind(i), FALSE, m[2][3][0])).
		}
		SET i TO i + 1.
	}

	IF pageList:LENGTH = 0
			pageList:ADD(LIST("(NO MODS INSTALLED)", "text", FALSE, FALSE, "")).

	RETURN menuPaginator(pageList, "INSTALLED MODS").
}
// }}}

// *** [CONFIG MODS MENU] ***		
// {{{ 
FUNCTION configModPage {
	PARAMETER n.

	LOCAL pageList IS LIST().
	LOCAL currM IS NMODS[n][2].	// Current Mod structure

	pageList:ADD(LIST("--| LAIKA UI OPTIONS |--", "text", FALSE, FALSE, "")). 
	pageList:ADD(LIST("MENU NAME", "string", modifyModVar@:bind(currM[5], 0), FALSE,
		"Name that will be shown in Laika interface.")).
	pageList:ADD(LIST("PARENT MENU", "string", modifyModVar@:bind(currM[5], 1), FALSE,
		"Name of the menu where this module will be installed as child.")).
	pageList:ADD(LIST("PARENT MENU BUTTON", "number",
			modifyModVar@:bind(currM[5], 2, LIST(1,8)), 1,
				"Number of the slot where the button for this menu will be installed.")).

	LOCAL typ IS 0.
	LOCAL extra IS currM[2][0].	// Module's Extra Options
	IF extra:LENGTH > 0 {
		pageList:ADD(LIST(" ", "text", FALSE, FALSE, "")).
		pageList:ADD(LIST("--| MODULE OPTIONS |--", "text", FALSE, FALSE, "")). 
	}

	LOCAL descr IS "".
	LOCAL indent IS "      ".
	FOR x IN extra:KEYS {
		SET typ TO (extra[x]):TYPENAME.
		IF currM[3][2]:HASKEY(x)
			SET descr TO currM[3][2][x].
		ELSE
			SET descr TO "".
		IF typ = "Scalar" 
			pageList:ADD(LIST(x, "number", modifyModVar@:bind(extra, x), 1, descr)).
		ELSE IF typ = "Boolean"
			pageList:ADD(LIST(x, "bool", modifyModVar@:bind(extra, x), FALSE, descr)).
		ELSE IF typ = "Lexicon" {
			pageList:ADD(LIST(x + ":", "text", FALSE, FALSE, "")).
			LOCAL subdescr IS "".
			FOR o IN extra[x]:KEYS {
				IF descr:TYPENAME = "Lexicon" AND descr:HASKEY(o)
					SET subdescr TO descr[o].
				ELSE
					SET subdescr TO "".
				pageList:ADD(LIST(indent+o, "radio", modifyModRadio@:bind(extra, x, o),
					FALSE, subdescr)).
			}
		} ELSE 
			pageList:ADD(LIST(x, "string", modifyModVar@:bind(extra, x), FALSE, descr)).
	}

	IF extra:LENGTH > 0 {
		//pageList:ADD(LIST("-", "text", FALSE, FALSE, "")).
		pageList:ADD(LIST("REVERT TO DEFAULTS", "action",
			revertModExtraData@:bind(currM[2]), FALSE,
				"Revert module options to default values.")).
	}

	LOCAL confOpt IS currM[8][0].	// Module's Configuration Options
	IF confOpt:LENGTH > 0 {
		pageList:ADD(LIST(" ", "text", FALSE, FALSE, "")).
		pageList:ADD(LIST("--| INSTALL OPTIONS |--", "text", FALSE, FALSE, "")).
	}

	FOR x IN confOpt:KEYS {
		SET typ TO (confOpt[x]):TYPENAME.
		IF currM[3][3]:HASKEY(x)
			SET descr TO currM[3][3][x].
		ELSE
			SET descr TO "".
		IF typ = "Scalar" 
			pageList:ADD(LIST(x, "number", modifyModVar@:bind(confOpt, x), 1, descr)).
		ELSE IF typ = "Boolean"
			pageList:ADD(LIST(x, "bool", modifyModVar@:bind(confOpt, x), FALSE, descr)).
		ELSE 
			pageList:ADD(LIST(x, "string", modifyModVar@:bind(confOpt, x), FALSE, descr)).
	}

	IF confOpt:LENGTH > 0 {
		//pageList:ADD(LIST("-", "text", FALSE, FALSE, "")).
		pageList:ADD(LIST("REVERT TO DEFAULTS", "action",
			revertModExtraData@:bind(currM[8]), FALSE,
				"Revert installation options to default values.")).
	}

	SET lastLine TO -1.
	RETURN menuPaginator(pageList, ("'" +currM[0] +"' CONFIGURATION"), installedModsPage@).
}

FUNCTION revertModExtraData {
	PARAMETER n.

	FOR k IN n[0]:KEYS {
		IF (n[0][k]):TYPENAME = "Lexicon"
			SET n[0][k] TO n[1][k]:COPY.
		ELSE
			SET n[0][k] TO n[1][k].
	}
}

FUNCTION modifyModVar {
	PARAMETER var,		// Variable Name
		idx,		// Variable Index
		lim IS MAGIC,	// Limits for scalar type LIST(min, max)
		k IS MAGIC.	// New value (if MAGIC just return old value)

	IF (lim):TYPENAME <> "List"	// If no limit has entered, roll parameters.
		SET k TO lim.
	
	IF k <> MAGIC
		IF (var[idx]):TYPENAME = "Boolean"
			SET var[idx] TO (NOT var[idx]).
		ELSE IF (var[idx]):TYPENAME = "Scalar" {
			// If we have limits, we clamp the input value
			IF (lim):TYPENAME = "List" AND lim:LENGTH = 2 {
				IF k < lim[0] SET k TO lim[0].
				IF k > lim[1] SET k TO lim[1].
			}
			SET var[idx] TO k.
		} ELSE
			SET var[idx] TO k.

	RETURN var[idx].
}

FUNCTION modifyModRadio {
	PARAMETER var,		// Variable Name
		idx,		// Variable Index
		opt,		// Radio Option
		k IS MAGIC.	// New value (if MAGIC just return old value)

	IF k <> MAGIC {
		FOR o IN var[idx]:KEYS {
			SET var[idx][o] TO FALSE.
		}
		SET var[idx][opt] TO TRUE.
	}

	RETURN var[idx][opt].
}
// }}}

// *** [CONFIG LAIKA MENU] ***		
// {{{
LOCAL LKconfigPage IS LIST(
	LIST( "CONFIGURE LAIKA", 	"text"),
	LIST( "=",			"line"),
	LIST( " ",			"text"),
	LIST( "Laika Master Disk",	"number",	volNumType@:bind("MAIN_DISK"), 1 ),
	LIST( "Modules Disk",		"number",	volNumType@:bind("MODS_DISK"), 1 ),
	LIST( "Master Loop Clock",	"number",	clockNumType@:bind("CPU_CLOCK"), 1000 ),
	LIST( "Instruction Per Cycle",	"number",	clampNumType@:bind("CPU_SPEED"), 50 ),
	LIST( "-",			"text"),
	LIST( "RETURN",			"backmenu", 	mainMenu@ )
).

LOCAL LKconfigDescr IS LIST("", "", "",
	"Disk destination for Laika core and libraries installation.",
	"Disk destination for modules installation.",
	"Refresh rate for Laika master loop.",
	"CPU instruction per cycle (affects power drain)."
).

FUNCTION LKconfigMenu {
	SET currPage TO 0.
	SET currMenuDescr TO LIST().
	currMenuDescr:ADD(LKconfigDescr).	
	SET lastLine TO -1.
	RETURN LKconfigPage.
}

FUNCTION volNumType {
	PARAMETER f,
		k IS MAGIC.

	IF k <> MAGIC {
		IF k < 1 SET k TO 1.
		IF k > LAST_VOL SET k TO LAST_VOL.
		SET LK_CONF[f] TO k.
	}

	RETURN LK_CONF[f].
}

LOCAL clock_values IS LIST (
	0.001,
	0.005,
	0.01,
	0.05,
	0.1,
	0.15,
	0.2
).
FUNCTION clockNumType {
	PARAMETER f,
		k IS MAGIC.

	LOCAL d IS 0.
	IF k <> MAGIC {
		IF k < 0 {
			SET k TO k+1000.
			SET d TO -1.
		} ELSE {
			SET k TO k-1000.
			SET d TO 1.
		}
		SET k TO ROUND(k, 4).

		LOCAL c IS 0.
		FOR i IN clock_values {
			IF i = k BREAK.
			SET c TO c+1.
		}

		SET c TO (c + d).
		IF c < 0 SET c TO 0.
		IF c >= clock_values:LENGTH() SET c TO clock_values:LENGTH()-1.

		SET LK_CONF[f] TO clock_values[c].
	}

	RETURN LK_CONF[f].
}
FUNCTION clampNumType {
	PARAMETER f,
		k IS MAGIC.
	IF k <> MAGIC {
		IF k < 50 SET k TO 50.
		IF k > 1000 SET k TO 1000.

		SET LK_CONF[f] TO k.
	}

	RETURN LK_CONF[f].
}
// }}}

// Set MainPage as initial active menu.
LOCAL lastLine	IS 0.			// used to track 'selectedLine' changes
GLOBAL activeMenu IS mainMenu().	// Initial menu page (needed ad GLOBAL by lib_menu).

// }}}

//					
// CONFIG FILE GENERATOR		
//					
// {{{
LOCAL stats IS 0.
FUNCTION buildConfigFile {   // {{{
	LOCAL lk_dsk IS LK_CONF["MAIN_DISK"]+":/".
	LOCAL f IS lk_dsk+conf_file.
	LOCAL line IS 0.

	SET stats TO LIST(0, 0).

	CLEARSCREEN.
	PRINT "[BUILDING LAIKA]".
	DELETEPATH(f).
	LOG "GLOBAL LK_CONF IS LEXICON(" TO f.

	// Dump list of mod and configuration to install.
	LOCAL inst_mod IS LIST().
	LOCAL extra IS 0.
	LOCAL confO IS 0.
	FOR m IN NMODS {
		IF m[1] {
			IF m[2][5][1] = "MAIN" SET m[2][5][1] TO LK_MAIN.
			IF m[2][2][0]:DUMP = m[2][2][1]:DUMP
				SET extra TO FALSE.
			ELSE {
				SET extra TO "LEXICON( ". // <- extra space added for safety
				FOR k IN m[2][2][0]:KEYS {
					IF m[2][2][0][k]:TOSTRING <> m[2][2][1][k]:TOSTRING {
						// adds key
						SET extra TO extra +quote +k +quote +comma.
						IF (m[2][2][0][k]):TYPENAME = "String"
							SET extra TO extra +quote +m[2][2][0][k] +quote.
						ELSE IF (m[2][2][0][k]):TYPENAME = "Lexicon" {
							SET extra TO extra +"LEXICON( ".
							FOR subk IN m[2][2][0][k]:KEYS {
								SET extra TO extra +quote +subk +quote
									+comma +m[2][2][0][k][subk]
									+comma.
							}
							SET extra TO extra:SUBSTRING(0, extra:LENGTH-1).
							SET extra TO extra +")".
						}
						ELSE
							SET extra TO extra +m[2][2][0][k].
						SET extra TO extra +comma.
					}
				}
				// because we've checked if the lexicon has changed,
				// we are sure that there is at least one element in the list.
				// Anyway we've added an extra space to 'extra' var for safety.
				SET extra TO extra:SUBSTRING(0, extra:LENGTH -1) +")".
			}
			IF m[2][8][0]:DUMP = m[2][8][1]:DUMP
				SET confO TO FALSE.
			ELSE {
				SET confO TO "LEXICON( ". // <- extra space added for safety
				FOR k IN m[2][8][0]:KEYS {
					IF m[2][8][0][k] <> m[2][8][1][k] {
						// adds key
						SET confO TO confO +quote +k +quote +comma.
						IF (m[2][8][0][k]):TYPENAME = "String"
							SET confO TO confO +quote +m[2][8][0][k] +quote.
						ELSE
							SET confO TO confO +m[2][8][0][k].
						SET confO TO confO +comma.
					}
				}
				// because we've checked if the lexicon has changed,
				// we are sure that there is at least one element in the list.
				// Anyway we've added an extra space to 'extra' var for safety.
				SET confO TO confO:SUBSTRING(0, confO:LENGTH -1) +")".
			}

			inst_mod:ADD(LIST(m[0] +"m", m[2][5][0], m[2][5][1], m[2][5][2],
				extra, confO, TRUE)).
//			PRINT " " +ENDL +"[Installing " +m[2][0] +"]".
//			installMod(m[0], m[2][8][0]).
		}
	}
	// sets the last element's flag to false; this will be used to handle the comma.
	SET inst_mod[inst_mod:LENGTH()-1][6] TO FALSE.

	PRINT " " +ENDL +"[Generating Config File]".
	// Dump LK_CONF.
	LOCAL c IS 1.
	FOR i IN LK_CONF:KEYS {
		SET line TO quote +i +quote +comma.

		IF (LK_CONF[i]):typename() = "Scalar"
		    OR (LK_CONF[i]):typename() = "Boolean" {
			SET line TO line +LK_CONF[i].
		}
		ELSE IF (LK_CONF[i]):typename() = "String" {
			SET line TO line +quote +LK_CONF[i] +quote.
		}

		IF c < LK_CONF:LENGTH() {
			SET line TO line +comma.
		}
		LOG line TO f.
		SET c TO c + 1.
	}
	LOG ")." TO f.

	LOG "GLOBAL LK_MOD IS LIST(" TO f.
	FOR m IN inst_mod {
		SET line TO "LIST("
			+quote +m[0] +quote +comma		// Module File Name
			+quote +m[1] +quote +comma		// Module Menu Name
			+quote +m[2] +quote +comma		// Parent Menu Name
			+m[3] +comma +m[4]. 			// Button Num & Extra Data
		IF m[5] <> FALSE
			SET line TO line +comma +m[5].		// Conf Data
		SET line TO line +")".
		IF m[6] 
			SET line TO line +comma.
		
		LOG line TO f.
	}
	LOG ")." TO f.

	installLaikaCore().

	FOR m IN NMODS {
		IF m[1] {
			PRINT " " +ENDL +"[Installing " +m[2][0] +"]".
			installMod(m).
		}
	}

	PRINT " " +ENDL +"      [INFO]: " +stats[0] +" WARNINGS in total,".
	PRINT "              " +stats[1] +" ERRORS in total.".
	PRINT "[Press any key to continue]" +BEEP.
	TERMINAL:INPUT:GETCHAR().
	CLEARSCREEN.
	drawAll().
} // }}}

FUNCTION installLaikaCore {   // {{{
	LOCAL d IS "".
	LOCAL f IS "laika_core.".
	LOCAL boot IS "".

	//LIST VOLUMES IN VOL.
	//DELETEPATH(d).

	IF LK_CONF["MAIN_DISK"] = 1 {
		// Will boot using LAIKA_CORE.
		SET d TO ":/boot/".
		SET boot TO "/boot/laika_core.ksm".
	} ELSE {
		SET d TO ":/lib/".
		SET boot TO "/boot/laika.ks".
		LOCAL b IS "1:" +boot.

		// Generate new BOOT file.
		DELETEPATH(b).
		LOG "CLEARSCREEN." TO b.
		LOG "CORE:DOACTION(" +quote +"open terminal" +quote +", TRUE)." TO b.
		LOG "PRINT " +quote +"Загрузка..." +quote +"." TO b.
		LOG "PRINT " +quote +"Switching to disk: " +LK_CONF["MAIN_DISK"] +quote +"." TO b.
		LOG "SWITCH TO " +LK_CONF["MAIN_DISK"] +"." TO b.
		LOG "RUNPATH(" +quote +LK_CONF["MAIN_DISK"] +d +f +"ksm" +quote +", FALSE)." TO b.
	}

	PRINT " " +ENDL +"[Installing Laika Core]".
	safeCompileTo("0:/lib/laika/", "laika_core.ks", LK_CONF["MAIN_DISK"], d).
	PRINT " " +ENDL +"[Installing Laika Lib-GUI]".
	safeCompileTo("0:/lib/laika/", "lib_lk_gui.ks", LK_CONF["MAIN_DISK"], ":/lib/").

	SET CORE:BOOTFILENAME TO boot.
}   // }}}

FUNCTION installMod {
	PARAMETER m.

	SET PP TO m[2][8][0]:COPY.
	IF m[2][7]:HASKEY("prebuild")
		importData( PP, m[2][7]["prebuild"]:CALL(m[2])).
	safeCompileTo("0:/lib/laika/mod/", m[0],  LK_CONF["MODS_DISK"], ":/mod/").
	SET PP TO LEXICON().
}

FUNCTION installModOLD {
	PARAMETER f,
		extra.

	SET PP TO extra:COPY.
	safeCompileTo("0:/lib/laika/mod/", f,  LK_CONF["MODS_DISK"], ":/mod/").
	SET PP TO LEXICON().
}

FUNCTION safeCompileTo {   // {{{
	PARAMETER src_path,
		src_file,
		dst_disk,
		dst_dir.

	LOCAL ret IS FALSE.
	LOCAL cwd IS PATH().

	LIST VOLUMES IN VOL.
	LOCAL d_free IS VOL[dst_disk]:FREESPACE.
	
	LOCAL tmp IS "0:/tmp/".
	DELETEPATH(tmp +src_file).
	DELETEPATH(tmp +src_file +"m").
	LOCAL ppstat IS PREPROCESS(src_path +src_file, tmp +src_file).
	SET stats[0] TO stats[0] +ppstat[1].
	SET stats[1] TO stats[1] +ppstat[2].

	COMPILE tmp +src_file TO tmp +src_file +"m".

	CD(tmp).
	LOCAL f_size IS 0.
	LOCAL f IS 0.
	LIST FILES IN f.
	FOR file IN f {
		IF file:NAME = src_file+"m" {
			SET f_size TO file:SIZE.
		}
	}
	CD(cwd).
	
	IF f_size < d_free {
		COPYPATH(tmp +src_file +"m", dst_disk +dst_dir +src_file +"m").
		SET ret TO TRUE.
	}

	DELETEPATH(tmp +src_file +"m").
	
	RETURN ret.
}   // }}}
// }}}

//					
// MAIN LOOP				
//					
// {{{
// Laika_conf is ready.
PRINT " "+endl+LAIKA.
PRINT "Ладно."+BEEP.
WAIT 1.00.

CLEARSCREEN.
drawAll().

LOCAL done 	IS FALSE.	// exit the main loop?
LOCAL _tlist	IS 0.
LOCAL _titer	IS 0.
UNTIL done { // {{{
	//			
	// DESCRIPTIONS HANDLER	
	//			
	IF lastLine <> selectedLine {   // {{{
		// Update the description.
		List_Menu:CLEAR().	// clear the old description
		IF (currMenuDescr):TYPENAME = "List" AND selectedLine<currMenuDescr[currPage]:LENGTH
			AND currMenuDescr[currPage][selectedLine] <> "" {
			//List_Menu:ADD(currMenuDescr[currPage][selectedLine]).
			SET _tlist TO currMenuDescr[currPage][selectedLine]:SPLIT("\").
			SET _titer TO _tlist:REVERSEITERATOR.
			UNTIL (NOT _titer:NEXT) {
				List_Menu:ADD(_titer:VALUE).
			}
		}
		parse_list().
		draw_list().
		SET lastLine TO selectedLine.
	}   // }}}

	inputs().
	refreshAll().

	WAIT 0.05.
} // }}}
// }}}

SET CONFIG:IPU TO 200.
CLEARSCREEN.
PRINT "Готов.".

// vim: fdc=6 fdm=marker :
