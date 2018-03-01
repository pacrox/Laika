// ----------------------------------------------------------------------------------[WINDOW'S WIDTH]---->

//									
//	Prototype for LAIKA Modules.					
//									
// * Structure format type 3.	
// * Uses PreProcessor.		
// * Updated for KoS 1.1.5.0.	

//			
// CONFIG SETUP		
//			
// {{{
// >> Sets-up module's basic data			     <<	

LOCAL _mFullN IS
// **** [0]: MODULE FULLNAME				   ****	
	"NewMod B Arch v.3".

// **** [1]: MODULE SHORT NAME				   ****	
LOCAL _mShortN IS
	"NEWMODB".

LOCAL _defaultP IS
// **** [2]: EXTRA PARAMETERS (can be FALSE).		   ****	
	FALSE.

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
//	   >>>> [3,0]: Description.			
		"Another test module for the new architecture.
		 This is the description block.",

//	   >>>>	[3,1]: Author name.			
		"(Laika Dev Team)",
//	   >>>>	[3,2]: Extra Options' descriptions.	
		LEXICON(),
//	   >>>>	[3,3]: Config Options' descriptions.	
		LEXICON()
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
		"NTESTB",

// 	   >>>>	[5,1]: Parent menu name.		
		"MAIN",

// 	   >>>>	[5,2]: Btn num in parent menu (base1).	
		5
	),

// ****	[6]: REQUIRED MODULES				   ****	
	LEXICON(
	),

// **** [7]: CONFIGURATOR CALLS				   ****	
	LEXICON(
	),

// **** [8]: CONFIGURATOR OPTIONS (can be FALSE)	   ****	
	FALSE
).


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
			1, LIST("A", {dUpdate(status, "BUTTON: A").}),
			2, LIST("B", {dUpdate(status, "BUTTON: B").}),
			3, LIST("C", {dUpdate(status, "BUTTON: C").}),
			4, LIST("D", {dUpdate(status, "BUTTON: D").}),
			5, LIST("E", {dUpdate(status, "BUTTON: E").}),
			6, LIST("F", {dUpdate(status, "BUTTON: F").}),
			7, LIST("G", {dUpdate(status, "BUTTON: G"). testFunct.}),
			8, LIST("H", testFunct@)
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
LOCAL fld1	IS UIaddDisp( LK_MOD[_mName], " ", 2, -5).
LOCAL fld2	IS UIaddDisp( LK_MOD[_mName], " ", 2, -4).

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
