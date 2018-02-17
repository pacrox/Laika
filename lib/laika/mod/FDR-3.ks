// ----------------------------------------------------------------------------------[WINDOW'S WIDTH]---->

//									
//	Flight Data Recorder Module for LAIKA.				
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
	"Flight Data Recorder".

// **** [1]: MODULE SHORT NAME				   ****	
LOCAL _mShortN IS
	"FDR".

LOCAL _defaultP IS
// **** [2]: EXTRA PARAMETERS (can be FALSE).		   ****	
	LEXICON(
		"Destination Dir",		"0:/telemetry/",
		"File Prefix",			"FDR_",
		"Sampling Rate",		1.0
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
//	   >>>> [3,0]: Description.			
		"An advanced Flight Data Recorder that allow telemetry analisys.
		 Can export data in CSV and GNU-Octave format.",

//	   >>>>	[3,1]: Author name.			
		"(Laika Dev Team)",
//	   >>>>	[3,2]: Extra Options' descriptions.	
		LEXICON(
			"Sampling Rate",	"Delta time (in seconds) between each log entry."
		),
//	   >>>>	[3,3]: Config Options' descriptions.	
		LEXICON(
			"Export CSV",		"Output data will be exported in
						 CSV (comma separated values) format.",
			"Export Octave",	"Output data will be exported in
						 GNU-Octave format.
						\(https://www.gnu.org/software/octave/)"
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
		"FDR",

// 	   >>>>	[5,1]: Parent menu name.		
		"MAIN",

// 	   >>>>	[5,2]: Btn num in parent menu (base1).	
		8
	),

// ****	[6]: REQUIRED MODULES				   ****	
	LEXICON(
	),

// **** [7]: CONFIGURATOR CALLS				   ****	
	LEXICON(
	),

// **** [8]: CONFIGURATOR OPTIONS (can be FALSE)	   ****	
	LEXICON(
		"Export CSV",			FALSE,
		"Export Octave",		TRUE
	)
).


PRINT msgModF +_mFullN.		// Module found message.
// }}}


IF FALSE {
//@ELSE:		{{{	
// Block executed after preprocessing by LAIKA.

//			
// INSTALLATION		
//			
// {{{
PARAMETER _mName	IS "UNKN", // Module menu name
	_mParent	IS "MAIN", // Parent menu name
	_mButton	IS 7,	   // Button number in parent menu (base1)
	_extraP		IS FALSE.  // Extra configuration for this module(*)

// The followings are mandatory lines.
PRINT msgModF +_mFullN.		// Module loaded message.

SET _extraP TO import( _extraP, _defaultP).

// >> Adds the new menu structure to MenuRegistry		{{{	
//									
//	LK_MENUS:ADD(							
//		menu_name,						
//		LIST(							
//			back_menu,					
//			LIST(button_name),				
//			LIST(is_submenu?)				
//		)							
// 	).								
//								}}}	
LK_MENUS:ADD(
	_mName, LIST( _mParent,		// module menu name - parent menu name
		LIST("", "", "", "START", "", "", "", "STOP"),
		LIST(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE))
).


// >> Install module menu to desired parent-menu's button	{{{	
//									
//	LK_MENUS[menu_name][0] = back_menu				
//      	              [1] = LIST(button_name)			
//	 		      [2] = LIST(is_submenu?)			
//								}}}	
SET LK_MENUS[_mParent][1][_mButton-1] TO _mName.
SET LK_MENUS[_mParent][2][_mButton-1] TO TRUE.


// >> Adds module menu commands to CommandsRegistry.		{{{	
//									
//	LK_CMDS:ADD( menu_name,						
//		LIST (							
//			LEXICON(button_name, function),			
//			LIST(daemon_running_while_on_this_menu)		
//			LEXICON(exported_functions_to_Laika)		
//		)							
//	).								
//								}}}	
LK_CMDS:ADD(_mName, LIST(   
	LEXICON(
		"START",	startLOG@,
		"STOP",		stopLOG@
	),
	LIST(disUpd@),
	LEXICON("DISP", display@))
).
// }}}

//			
// DISPLAY MANAGER	
//			
// {{{
LOCAL FUNCTION display {
	DPRINT(_mFullN, "c", 0).
	DLINE("-", 1).

	DLINE("_", -2).
	DPRINT("SR: " +_extraP["Sampling Rate"] +"s", 2, -1).
	//@IF (Export CSV):
	DPRINT("CSV", -10, -1).
	//@ENDIF.
	//@IF (Export Octave):
	DPRINT("OCT", -5, -1).
	//@ENDIF.

	disStatus.
}

LOCAL FUNCTION disUpd {
	DPRINT("Δt: " +ROUND(dT,3) +"s         ", 16, -1).
}

LOCAL FUNCTION disStatus {
	IF DAEMONS:HASKEY("FDR3")
		DPRINT("Logging data...", 2, 3).
	ELSE
		DPRINT("Idle.          ", 2, 3).
}
// }}}

//			
// DATA LOGGER		
//			
// {{{
LOCAL nT IS 0.		// nextTime (when data should be logged)
LOCAL dT IS 0.		// deltaTime between checks
LOCAL lT IS 0.		// lastTime (last sampled time)
LOCAL sT IS 0.		// startingTime (time at start)
LOCAL FUNCTION updateAll {    //{{{
	SET t TO TIME:SECONDS.
	IF t >= nT {
		calcEngineDatas().
		logData().
		SET dT TO t - lT.
		SET nT TO t +_extraP["Sampling Rate"] - MOD(t-sT,_extraP["Sampling Rate"]).
		SET lT TO t.
	}
}   //}}}

LOCAL FUNCTION startLOG {   //{{{
	IF DAEMONS:HASKEY("FDR3") RETURN.
	//@IF (Export Octave):    {{{
	IF NOT EXISTS(fOct) {
		// DELETEPATH(fOct).
		LOG "% v." +fmt_ver TO fOct.
		LOG ("atm2kPa = " +CONSTANT:ATMTOKPA) +";" TO fOct.
		LOCAL i IS 1.
		FOR k IN dataCall:KEYS {
			LOG "fld.(" +quote +k +quote +") = " +i +";" TO fOct.
			SET i TO i +1.
		}
		LOG "fdata = [];" TO fOct.
	}
	//@ENDIF.    }}}
	//@IF (Export CSV):    {{{
	IF NOT EXISTS(fCSV) {
		LOCAL line IS "".
		FOR k IN dataCall:KEYS {
			SET line TO line +quote +k +quote +", ".
		}
		LOG line:TRIM:SUBSTRING(0,line:LENGTH-2) TO fCSV.
	}
	//@ENDIF.    }}}

	SET nT TO TIME:SECONDS.
	DAEMONS:ADD("FDR3", updateAll@).	
	SET sT TO TIME:SECONDS.
	SET lT TO sT.
	disStatus.
}   //}}}

LOCAL FUNCTION stopLOG { //{{{
	IF (NOT DAEMONS:HASKEY("FDR3")) RETURN.

	DAEMONS:REMOVE("FDR3").
	SET dT TO 0.
	disStatus.
} //}}}

//@IF (Export Octave):
LOCAL fOct IS (_extraP["Destination Dir"]+_extraP["File Prefix"]+"log.fdo").
LOCAL fmt_ver IS "5.0".
//@ENDIF.

//@IF (Export CSV):
LOCAL fCSV IS (_extraP["Destination Dir"]+_extraP["File Prefix"]+"log.csv").
//@ENDIF.

LOCAL FUNCTION logData {   //{{{
	//@IF (Export Octave):
	LOCAL lOct IS "fdata = [fdata; ".
	//@ENDIF.
	//@IF (Export CSV):
	LOCAL lCSV IS "".
	//@ENDIF.

	LOCAL val IS 0.
	FOR k IN dataCall:KEYS {
		SET val TO dataCall[k]:CALL().
		//@IF (Export Octave):
		SET lOct TO lOct +val +", ".
		//@ENDIF.
		//@IF (Export CSV):
		SET lCSV TO lCSV +val +", ".
		//@ENDIF.
	}
	//@IF (Export Octave):
	SET lOct TO lOct +" ];".
	LOG lOct TO fOct.
	//@ENDIF.
	//@IF (Export CSV):
	LOG lCSV:TRIM:SUBSTRING(0,lCSV:LENGTH-2) TO fCSV.
	//@ENDIF.
}   //}}}
//}}}

//			
// DATA REFRESH		
//			
// {{{
LOCAL cThr IS 0.
LOCAL cIsp IS 0.
LOCAL cFFl IS 0.
LOCAL cG IS 0.
LOCAL FUNCTION calcEngineDatas {
	SET cThr TO 0.
	SET cIsp TO 0.
	SET cFFl TO 0.
	SET cG TO SHIP:BODY:MU/SHIP:BODY:POSITION:MAG^2.

	IF SHIP:MAXTHRUST > 0 {
		LOCAL eng IS 0.
		LIST ENGINES IN eng.
		FOR e IN eng {
			SET cThr TO cThr +e:THRUST.
			SET cIsp TO cIsp +e:ISP.
			SET cFFl TO cFFl +e:FUELFLOW.
		}
		// SET currT TO currT/SHIP:MAXTHRUST*100.
	}
}
// }}}

//			
// DATA CALLS		
//			
// {{{
LOCAL dataCall IS LEXICON (
	"UT",		{RETURN ROUND(TIME:SECONDS,2).},		// 1 - 0
	"MET",		{RETURN ROUND(MISSIONTIME,2).},			// 1 - 1
	"ALTITUDE",	{RETURN ROUND(SHIP:ALTITUDE).},			// 2 - 2
	"RADAR ALT",	{RETURN ROUND(ALT:RADAR).},			//	--  <<
	"SPEED",	{RETURN ROUND(SHIP:AIRSPEED,1).},		// 3 - 3
	"ACCEL",	{RETURN ROUND(cThr/SHIP:MASS,2).},		//   - 4    <<
	"THRUST",	{RETURN ROUND(cThr).},				// 4 - 5
	"TWR",		{RETURN ROUND(cThr/(cG*SHIP:MASS), 2).},	//   - 6    <<
	"MAXTHRUST",	{RETURN ROUND(SHIP:MAXTHRUST).},		//   - 7
	"ISP",		{RETURN ROUND(cIsp).},				// 5 - 8    <<
	"FUEL FLOW",	{RETURN ROUND(cFFl).},				// 6 - 9    <<
	"THROTTLE",	{RETURN ROUND(THROTTLE, 2).},			// 7 - 10
	"MASS",		{RETURN ROUND(SHIP:MASS, 2).},			// 8 - 11
	"Q",		{RETURN ROUND(SHIP:DYNAMICPRESSURE, 2).},	// 9 - 12
	"APOAPSIS",	{RETURN ROUND(ALT:APOAPSIS).},			// 10 - 13
	"PERIAPSIS",	{RETURN	ROUND(ALT:PERIAPSIS).},			// 11 - 14
	"TIME TO APO",	{RETURN ROUND(ETA:APOAPSIS, 1).},		// 12 - 15
	"TIME TO PERI",	{RETURN ROUND(ETA:PERIAPSIS, 1).},		// 13 - 16
	"ECCENTRICITY",	{RETURN ROUND(ORBIT:ECCENTRICITY, 3).},		// 14 - 17
	"INCLINATION",	{RETURN ROUND(ORBIT:INCLINATION, 2).},		//    - 18
	"PERIOD",	{RETURN ROUND(ORBIT:PERIOD, 1).},		//	--
	"SEMIMAJOR",	{RETURN ROUND(ORBIT:SEMIMAJORAXIS).},		// 	--
	"SEMIMINOR",	{RETURN ROUND(ORBIT:SEMIMINORAXIS).},		//	--
	"ORB SPEED",	{RETURN ROUND(SHIP:VELOCITY:ORBIT:MAG, 1).},	//	--  <<
	"BODY RADIUS",	{RETURN ROUND(ORBIT:BODY:RADIUS).},		//	--  <<
	"ATM PRESSURE", {RETURN ROUND(
		ORBIT:BODY:ATM:ALTITUDEPRESSURE(SHIP:ALTITUDE), 2).},	// 15 - 19
	"ATM HEIGHT",	{RETURN ROUND(ORBIT:BODY:ATM:HEIGHT).},		//    - 20
	"G ACCEL",	{RETURN ROUND(cG, 2).},				//    - 21  <<
	"YAW",		{RETURN ROUND(SHIP:FACING:YAW, 1).},		//	--
	"PITCH",	{RETURN ROUND(SHIP:FACING:PITCH, 1).},		//	--
	"ROLL",		{RETURN ROUND(SHIP:FACING:ROLL, 1).},		//	--

	"STAGE",	{RETURN STAGE:NUMBER.}				// 16 - 22
).
//}}}
	
//@ENDIF.		}}}	

//@EXCLUDE NEXT.		
}

// last size: 3436b (Oct only)
// last size: 3399b (CSV only)
// last size: 3447b (CSV only)
// last size: 3579b (Oct only)
// last size: 3875b (Both)
//
// last size: 3487b (CSV only)
// last size: 3594b (Oct only)
// last size: 3807b (Both)

// vim: fdc=6 fdm=marker :
