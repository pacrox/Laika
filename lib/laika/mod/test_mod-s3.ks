// ----------------------------------------------------------------------------------[WINDOW'S WIDTH]---->

//									
//	Prototype for LAIKA Modules.					
//									
// * Structure format type 3.	
// * Uses PreProcessor.		
// * Updated for KoS 1.1.5.0.	
// * Upgraded for Laika v.1.0.	

//			
// CONFIG SETUP		
//			
// {{{
// >> Sets-up module's basic data			     <<	

LOCAL _mFullN IS
// **** [0]: MODULE FULLNAME				   ****	
	"NewMod Arch v.3".

// **** [1]: MODULE SHORT NAME				   ****	
LOCAL _mShortN IS
	"NEWMOD".

LOCAL _defaultP IS
// **** [2]: EXTRA PARAMETERS (can be FALSE).		   ****	
	LEXICON(
		"opt1",			TRUE,
		"opt2",			2,
		"opt3",			LEXICON(
						"Day", TRUE,
						"Night", FALSE,
						"Undet.", FALSE),
		"opt4",			"string"
	).

//@ IF (FALSE):			
// Block executed during CONFIG-PHASE.
// MOD_DATA LIST(					{{{	
//	[0]		Module fullname				
//	[1]		Module short name			
//	[2] 		Extra parameters (can be FALSE)		
//	[3] LIST()	Informations				
//	[4] LIST()	Version					
//	[5] LIST()	UI Placement				
//	[6] LEX()	Required Modules			
//	[7] LEX()	Configurator Calls			
//	[8] LEX()	Configurator Options (can be FALSE)	
// 							}}}	
GLOBAL MOD_DATA IS LIST( _mFullN, _mShortN, _defaultP,

// **** [3]: INFORMATIONS				   ****	
	LIST(
//	   >>>> [3,0]: Module's description.		
		"A test module for the new architecture.
		 This is the description block.",

//	   >>>>	[3,1]: Author name.			
		"(Laika Dev Team)",
//	   >>>>	[3,2]: Extra Options' descriptions.	
		LEXICON(
			"opt1",			"This is the first option.",
			"opt3",			LEXICON(
							"Day", "When sun is up the sky.",
							"Night", "When sun is set."
						)
		),
//	   >>>>	[3,3]: Config Options' descriptions.	
		LEXICON(
			"Export CSV",		"Output data will be exported in
						 CSV (comma separated values) format.",
			"Export Octave",	"Output data will be exported in
						 GNU-Octave format.
						 (www.gnu.org/software/octave/)"
		)
	),

// ****	[4]: VERSION					   ****	
	LIST(
// 	   >>>>	[4,0]: MAJOR				
		0,
// 	   >>>>	[4,1]: MINOR				
		1,
//	   >>>> [4,2]: PATCH				
		3
	),

// ****	[5]: UI-PLACEMENT				   ****	
	LIST(
// 	   >>>>	[5,0]: Self menu name.			
		"NTEST",

// 	   >>>>	[5,1]: Parent menu name.		
		"MAIN",

// 	   >>>>	[5,2]: Btn num in parent menu (base1).	
		5
	),

// ****	[6]: REQUIRED MODULES				   ****	
	LEXICON(
		"NewMod B Arch v.3", LIST(0,1,3),	// mod name, options
		"Pippo", LIST(0,1,3)			// mod name, options
	),

// **** [7]: CONFIGURATOR CALLS				   ****	
	LEXICON(
		"prebuild", _prebuild@
	),

// **** [8]: CONFIGURATOR OPTIONS (can be FALSE)	   ****	
	LEXICON(
		"Export CSV",		FALSE,
		"Export Octave", 	TRUE
	)
).


// _prebuild function must return a LEXICON() structure.
LOCAL FUNCTION _prebuild {
	PARAMETER m.
	LOCAL ret IS LEXICON().

	RETURN ret.
}


PRINT msgModF +_mFullN.		// Module found message.
// }}}

IF FALSE {
//@ ELSE:		{{{	
// Block executed after preprocessing by LAIKA.

//			
// INSTALLATION		
//			
// {{{
PARAMETER _mName	IS "UNKN", // Module menu name
	_mParent	IS "MAIN", // Parent menu name
	_mButton	IS 7,	   // Button number in parent menu (base1)
	_extraP		IS FALSE.  // Extra configuration for this module (FALSE if none).

// The followings are mandatory lines.
PRINT msgModF +_mFullN.		// Module loaded message.

// The following is not needed if MOD has no extra parameters.
// Uncomment if needed (safe function).
//SET _extraP TO import( _extraP, _defaultP).

// >> Adds the new menu structure to MenuRegistry			
LK_MOD:ADD( _mName,
	UIinitMenu( 0, _mName, LEXICON(
			1, LIST("A", {dUpdate(status, "STATUS: char A").}),
			2, LIST("B", {dUpdate(status, "STATUS: a number B").}),
			3, LIST("C", {dUpdate(status, "STATUS: string C").}),
			4, LIST("D", {dUpdate(status, "STATUS: dot D").}),
			5, LIST("E", testFunct@)
	))
).


// >> Install module menu to desired parent-menu's button		
UIaddCall(
	LK_MOD[_mParent],
	0, LEXICON(
		_mButton, LIST( _mName, {gotoMenu(LK_MOD[_mName]).})
	)
).
// }}}

// Optional Functions called by CommadsRegistry (if needed).
LOCAL status	IS UIaddDisp( LK_MOD[_mName], "STATUS: NOTHING TO DECLARE", 2, 2).
LOCAL fld1	IS UIaddDisp( LK_MOD[_mName], " ", 2, 3).
LOCAL fld2	IS UIaddDisp( LK_MOD[_mName], " ", 2, 4).

LOCAL Show IS FALSE.
LOCAL FUNCTION testFunct {
	IF Show {
		dClear( fld1).
		dClear( fld2).
	} ELSE {
		dUpdate( fld1, "THIS IS LAIKA TEST E FUNCTION.").
		dUpdate( fld2, "THIS IS " +_mFullN +" " +_mName).
	}
	SET Show TO (NOT Show).
} 

//@ ENDIF.		}}}	

//@ EXCLUDE NEXT.		
}

// last size: 746b
// last size: 768b
//
// vim: fdc=6 fdm=marker :
