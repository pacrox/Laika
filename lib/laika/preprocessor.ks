// ----------------------------------------------------------------------------------[WINDOW'S WIDTH]---->

//											
//			      KOS COMPILER PREPROCESSOR					
//											
//											
//											
// * Updated for KoS 1.1.5.0.								
//											

// Available Directives: 
//	* IF (<bool_var>):			
//	* IF NOT (<bool_var>):			
//	* IF NOT DECLARED (<bool_var>):		
//	* IF DECLARED (<bool_var>):		
//	* ELSE:					
//	* ENDIF.				
//	* DECLARE (<bool_var>, <bool>).		
//	* UNDECLARE (<bool_var>).		
//	* INCLUDE (<file>).			
//	* ADDCODE (<string_var>).		
//	* DEFAULT (<bool>).			
//	* EXCLUDE NEXT (<num_of_lines>).	
//
// Planned Directives: 	
//	- BEGIN SAVEBLOCK (<filename>): 	
//	- END SAVEBLOCK.			

// Directive structure:	
//													
//	//@   DIRECTIVE  [(<parm>,<parm>,<parm>)] <:|.>[...]						
//	 ^  ^     ^    ^      ^     ^      ^     ^  ^    ^						
//	 |  |     |    |      |     |      |     |  |    |						
//	 |  |     |    |      |     |      |     |  |    +- Following chars will be ignored.		
//	 |  |     |    |      +-----+------+     |  +- Directive terminator marker (: for blocks).	
//       |  |     |    |            |       	 +- Optional space (zero or more).			
//	 |  |     |    |            +- Directive Parameters (if it has any), separated by commas.	
//	 |  |     |    +- Optional Space (zero or more).						
//	 |  |     +- Directive command, as list of words.						
//	 |  +- Optional space (zero or more).								
//	 +- Mandatory directive identifier, has to be at the beginning of the line.			
//													
//
// Example: 		
//	//@IF (FOO):	<-- Here the block starts.	
//	SOME CODE.					
//	...						
//	//@ ENDIF.	// Here the blocks ends.	
//							
//
// Options: 		
//	-V, -VERBOSE		Verbose output (by default only WARN and ERR)		
//	-C, -STRIP_COMMENTS	Strip all comments.					
//	-E, -SKIP_EMPTY_LINES	Remove empty lines.(*)					
//	-I, -REMOVE_INDENT	Remove indentation.					
//	-T, -TRIM_LINE_END	Remove trailing spaces from lines.			
//	-S, -REPORT_STATUS	Show report at the end.					
//	-D, -DONT_REPLACE	Don't replace stripped lines.(*)			
//											
//	(*) by default keep all the empty lines to mantain corrispondency of		
//		line-numbers after compiling.						
//											

@LAZYGLOBAL OFF.

// PARAMETER _PPopts IS LIST().

GLOBAL _PPopts IS LIST().

LOCAL VER IS "v.0.1.7".

LOCAL BEEP	IS CHAR(7).
LOCAL ENDL	IS CHAR(10).
LOCAL QUOTE	IS CHAR(34).
LOCAL COMMA	IS CHAR(44).

LOCAL _VAR 	IS LEXICON().
LOCAL last_line	IS 0.
LOCAL proc	IS LEXICON().

//IF NOT (DEFINED PP)
GLOBAL PP 	IS LEXICON().

FUNCTION initAll {   //{{{
	SET _VAR TO LEXICON(
		"VERBOSE",		FALSE,
		"STRIPCOMMENTS",	FALSE,
		"SKIPEMPTY",		FALSE,
		"TRIMINDENT",		FALSE,
		"TRIMLINE",		FALSE,
		"REPORT",		FALSE,
		"DONTREPLACE",		FALSE,
		"WARN",			0,
		"ERR",			0,
		"LINE:IN",		0,
		"LINE:OUT",		0,
		"LINE:STRIPPED",	0
	).
	SET proc TO LEXICON(
		"IF-BLOCK:IGNORE_LINE",		LIST(),
		"IF-BLOCK:ELSE_FLAG",		LIST(),
		"IF-BLOCK:SKIPPING_LINES",	FALSE,		// If it's currently skipping lines
		"BOOL-VAR:DEFAULT",		TRUE,
		"EXCLUDE:UNTIL_LINE",		-1,
		"INCLUDED:FILE_LIST",		LEXICON()
	).

	IF (NOT PP:HASKEY("TRUE"))
		PP:ADD("TRUE", TRUE).
	IF (NOT PP:HASKEY("FALSE"))
		PP:ADD("FALSE", FALSE).

	SET last_line TO 0.

	FOR k IN _PPopts {
		IF k = "-VERBOSE" OR k = "-V"
			SET _VAR["VERBOSE"] TO TRUE.

		ELSE IF k = "-STRIP_COMMENTS" OR k = "-C"
			SET _VAR["STRIPCOMMENTS"] TO TRUE.

		ELSE IF k = "-SKIP_EMPTY_LINES" OR k = "-E"
			SET _VAR["SKIPEMPTY"] TO TRUE.

		ELSE IF k = "-REMOVE_INDENT" OR k = "-I"
			SET _VAR["TRIMINDENT"] TO TRUE.

		ELSE IF k = "-TRIM_LINE_END" OR k = "-T"
			SET _VAR["TRIMLINE"] TO TRUE.

		ELSE IF k = "-REPORT_STATS" OR k = "-S"
			SET _VAR["REPORT"] TO TRUE.

		ELSE IF k = "-DONT_REPLACE_LINES" OR k = "-D"
			SET _VAR["DONTREPLACE"] TO TRUE.

		ELSE
			DEBUG(ERR, "Unknown option '" +k +"'.").
	}
}   //}}}

LOCAL inDATA IS 0.
FUNCTION PREPROCESS {   //{{{
	PARAMETER in_FILE.
	PARAMETER out_FILE.

	initAll.
	DEBUG(INFO, "KoS PreProcessor " +VER +".").

	IF (NOT EXISTS(in_FILE)) {
		DEBUG(ERR, "Input file does not exists.").
		RETURN LIST(1, 0, 0).
	}

	IF EXISTS(out_FILE) {
		DELETEPATH(out_FILE).
		DEBUG(WARN, "Deleted file '" +out_FILE +"'.").
	}

	SET inDATA TO OPEN(in_FILE):READALL:STRING.
	DEBUG(INFO, "Input file opened for reading.").

	LOCAL k IS 0.
	LOCAL p IS 0.
	LOCAL line IS 0.
	SET _VAR["LINE:IN"] TO 1.
	DEBUG(INFO, "Beginning of file.").
	UNTIL FALSE {
		SET p TO inDATA:FIND(ENDL).
		IF p = -1 
			SET line TO inDATA:SUBSTRING(0, inDATA:LENGTH-1).
		ELSE
			SET line TO inDATA:SUBSTRING(0, p).

		SET line TO findDirective(line).

		IF _VAR["STRIPCOMMENTS"]
			SET line TO stripComments(line).

		//IF _VAR["SKIPEMPTY"]
		//	SET line TO stripEmptyLine(line).

		IF _VAR["TRIMINDENT"]
			SET line TO removeIndent(line).

		IF _VAR["TRIMLINE"]
			SET line TO trimLine(line).

		SET line TO stripEmptyLine(line).

		countQuotes(line).
		IF line <> -1 AND isVisible {
			LOG line TO out_FILE.
			SET _VAR["LINE:OUT"] TO _VAR ["LINE:OUT"]+1.
		} ELSE {
			IF (NOT _VAR["SKIPEMPTY"]) AND (NOT _VAR["DONTREPLACE"]) {
				LOG "" TO out_FILE.
				SET _VAR["LINE:OUT"] TO _VAR["LINE:OUT"]+1.
			}
			SET _VAR["LINE:STRIPPED"] TO _VAR["LINE:STRIPPED"]+1.
		}

		IF (p = -1 OR inDATA:LENGTH-p-1 = 0) BREAK.

		SET _VAR["LINE:IN"] TO _VAR["LINE:IN"] +1.
		SET inDATA TO inDATA:SUBSTRING(p+1, inDATA:LENGTH-p-1).
	}
	DEBUG(INFO, "Reached end of file (EOF).").
	SET last_line TO _VAR["LINE:IN"].
	DEBUG(REP).

	RETURN LIST(0, _VAR["WARN"], _VAR["ERR"]).
}   //}}}

LOCAL in_quote IS FALSE.
FUNCTION countQuotes {   //{{{
	PARAMETER line.

	IF line = -1 RETURN -1.
	
	LOCAL sline IS line.
	LOCAL c IS -1.
	LOCAL q IS -1.

	UNTIL FALSE {
		IF (c <> -1 AND c < q) AND (NOT in_quote) {
			SET sline TO sline:SUBSTRING(0,c).
		} ELSE IF ( q <> -1 ) {
			SET in_quote TO (NOT in_quote).
		}

		IF q > sline:LENGTH BREAK.
		SET c TO sline:FINDAT("//", q+1).
		SET q TO sline:FINDAT(QUOTE, q+1).
		IF q = -1 BREAK.
	}

	RETURN line.	
}   //}}}

FUNCTION countQuotesTo {   //{{{
	PARAMETER line,
		in_qt.

	IF line = -1 RETURN -1.

	LOCAL p IS line:FIND(QUOTE).
	UNTIL p = -1 {
		SET in_qt TO (NOT in_qt).
		SET p TO line:FINDAT(QUOTE,p+1).
	}
	RETURN in_qt.	
}   //}}}

FUNCTION stripComments {   //{{{
	PARAMETER line.

	IF line = -1 RETURN -1.

	LOCAL p IS line:FIND("//").
	IF p = 0 AND (NOT in_quote) RETURN -1.
	UNTIL p = -1 {
		IF NOT countQuotesTo(line:SUBSTRING(0,p), in_quote) BREAK.
		SET p TO line:FINDAT("//", p+2).
	}
	IF p = -1 RETURN line.

	RETURN line:SUBSTRING(0, p).
}   //}}}

FUNCTION stripEmptyLine {    //{{{
	PARAMETER line.

	IF in_quote RETURN line.
	IF line = -1 OR line:TRIM = "" RETURN -1.

	RETURN line.
}   //}}}

FUNCTION removeIndent {   //{{{
	PARAMETER line.

	IF line = -1 RETURN -1.
	IF in_quote RETURN line.

	RETURN line:TRIMSTART.
}   //}}}

FUNCTION trimLine {   //{{{
	PARAMETER line.

	IF line = -1 RETURN -1.
	IF countQuotesTo(line, in_quote) RETURN line.

	RETURN line:TRIMEND.
}   //}}}

FUNCTION findDirective {   //{{{
	PARAMETER line.

	IF line = -1 RETURN -1.
	IF in_quote RETURN line.
	IF NOT line:TRIM:STARTSWITH("//@") RETURN line.
	IF line:TRIM:LENGTH < 5 RETURN line.

	IF (NOT line:MATCHESPATTERN("[:.]")) {
		DEBUG(WARN, "Ignoring unterminated directive.").
		RETURN line.
	}
	LOCAL dir IS line:TRIM:REMOVE(0,3):TRIM.

	IF dir:FIND(".") = -1
		SET dir TO dir:SUBSTRING(0, dir:FIND(":")):TRIM.
	ELSE IF dir:FIND(":") = -1
		SET dir TO dir:SUBSTRING(0, dir:FIND(".")):TRIM.
	ELSE
		SET dir TO dir:SUBSTRING(0, MIN(dir:FIND("."), dir:FIND(":"))):TRIM.
		
	LOCAL parm IS 0.
	LOCAL p IS 0.
	IF dir:MATCHESPATTERN("[(]") AND dir:MATCHESPATTERN("[)]")  {
		SET p TO dir:FIND("(").
		SET parm TO dir:SUBSTRING(p+1, dir:FIND(")")-p-1):TRIM.
		SET dir TO dir:SUBSTRING(0, p):TRIM.
	}

//	IF parm <> 0
//		DEBUG(INFO, "Found parameter= "+parm).

	IF (NOT DIRECTIVE:HASKEY(dir)) {
		DEBUG(WARN, "Unknown directive " +dir +".").
		RETURN line.
	}

	DEBUG(INFO, "Found directive " +dir +".").

	DIRECTIVE[dir](parm).

	RETURN -1.
}   //}}}

LOCAL DIRECTIVE IS LEXICON(   //{{{
	"IF",			dIF@:bind(0),
	"IF NOT DECLARED",	dIF@:bind(1),
	"IF DECLARED",		dIF@:bind(2),
	"IF NOT",		dIF@:bind(3),
	"ELSE",			dELSE@,
	"ENDIF",		dENDIF@,
	"DECLARE",		dDECLARE@,
	"UNDECLARE",		dUNDECLARE@,
	"INCLUDE",		dINCLUDE@,
	"ADDCODE",		dADDCODE@,
	"EXCLUDE NEXT",		dEXCLUDENEXT@,
	"DEFAULT",		dDEFAULT@
).   //}}}

FUNCTION isVisible {   //{{{
	LOCAL k TO proc["IF-BLOCK:IGNORE_LINE"]:LENGTH.

	IF k > 0 AND proc["IF-BLOCK:IGNORE_LINE"][k-1]
		RETURN FALSE.

	IF _VAR["LINE:IN"] <= proc["EXCLUDE:UNTIL_LINE"]
		RETURN FALSE.

	RETURN TRUE.
}   //}}}

FUNCTION dIF {   //{{{
		// 0:	IF statement
		// 1:	IF NOT DECLARED statement
		// 2:	IF DECLARED statement
		// 3:	IF NOT statement
	PARAMETER type,
		parm.

	LOCAL k IS 0.		// holds the IGNORE LINE status
	IF (NOT PP:HASKEY(parm)) {
		IF type = 1 {		// IF NOT DECLARED statement
			SET k TO FALSE.	// don't ignore following lines
			DEBUG(INFO,"Var '" +parm +"' is unknown, will include block.").
		} ELSE IF type = 2 {
			SET k TO TRUE.	// ignore following lines
		} ELSE {
			DEBUG(WARN, "Unknown bool-var '" +parm
				+"'. Using default '" +proc["BOOL-VAR:DEFAULT"] +"'.").
			SET k TO (NOT proc["BOOL-VAR:DEFAULT"]).
		}
	} ELSE {
		IF type = 1 {			// IF NOT DECLARED statement
			SET k TO TRUE.		// var was not declared, will ignore the lines.
			DEBUG(INFO,"Var '" +parm +"' is known, will skip block.").
		} ELSE IF type = 2 {
			SET k TO FALSE.		// don't ignore following lines
		} ELSE 
			SET k TO (NOT PP[parm]).	// if the var is true, will
							// not ignore the lines (and vice-versa)
	}
	IF type = 3		// IF NOT statement
		SET k to (NOT k).

	LOCAL l IS proc["IF-BLOCK:IGNORE_LINE"]:LENGTH.	// stack of IGNORE LINE, one per if-block

	IF l > 0 AND proc["IF-BLOCK:IGNORE_LINE"][(l-1)] 	// if the last if-block is TRUE
		SET k TO TRUE.					// will keep ignoring lines regardless.

	proc["IF-BLOCK:IGNORE_LINE"]:ADD(k).		// add the status to the stack.
	proc["IF-BLOCK:ELSE_FLAG"]:ADD(FALSE).		// add the status to the stack.

	DEBUG(INFO, "IF-BLOCK (lvl=" +(l+1) +", strip=" +k:TOSTRING:SUBSTRING(0,1) +")").
}   //}}}

FUNCTION dELSE {   //{{{
	PARAMETER parm.

	IF proc["IF-BLOCK:ELSE_FLAG"]:LENGTH = 0 {
		DEBUG(ERR, "Missing previous IF. Ignoring ELSE directive.").
		RETURN.
	}

	LOCAL l IS proc["IF-BLOCK:IGNORE_LINE"]:LENGTH-1.

	IF proc["IF-BLOCK:ELSE_FLAG"][l] {
		DEBUG(ERR, "Ignoring extra ELSE directive in IF-BLOCK.").
		RETURN.
	}

	SET proc["IF-BLOCK:ELSE_FLAG"][l] TO TRUE.

	IF (l > 0 AND (NOT proc["IF-BLOCK:IGNORE_LINE"][l-1])) OR l=0
		SET proc["IF-BLOCK:IGNORE_LINE"][l] TO (NOT proc["IF-BLOCK:IGNORE_LINE"][l]).

	DEBUG(INFO, "IF-ELSE-BLOCK (lvl=" +(l+1) +", strip="
		+proc["IF-BLOCK:IGNORE_LINE"][l]:TOSTRING:SUBSTRING(0,1) +")").
}   //}}}

FUNCTION dENDIF {   //{{{
	PARAMETER parm.

	IF proc["IF-BLOCK:IGNORE_LINE"]:LENGTH = 0 {
		DEBUG(ERR, "Missing previous IF. Ignoring ENDIF directive.").
		RETURN.
	}

	LOCAL l IS proc["IF-BLOCK:IGNORE_LINE"]:LENGTH-1.
	LOCAL lval IS FALSE.
	IF l > 0
		SET lval TO proc["IF-BLOCK:IGNORE_LINE"][l-1].

	proc["IF-BLOCK:IGNORE_LINE"]:REMOVE(l).
	proc["IF-BLOCK:ELSE_FLAG"]:REMOVE(l).

	DEBUG(INFO, "IF-BLOCK (lvl=" +l +", strip=" +lval:TOSTRING:SUBSTRING(0,1) +")").
}   //}}}

FUNCTION dDECLARE {   //{{{
	PARAMETER parm.

	IF (NOT isVisible) RETURN.

	IF parm = 0 {
		DEBUG(WARN, "Missing needed parameter. Ignoring DECLARE directive.").
		RETURN.
	}

	LOCAL p IS parm:SPLIT(",").
	IF p:LENGTH > 2
		RETURN.

	LOCAL val IS proc["BOOL-VAR:DEFAULT"].
	IF p:LENGTH = 2 {
		IF p[1]:TOSTRING:TRIM:TOUPPER = "TRUE" OR p[1] = 1
			SET val TO TRUE.
		ELSE IF p[1]:TOSTRING:TRIM:TOUPPER = "FALSE" OR p[1] = 1
			SET val TO FALSE.
		ELSE {
			DEBUG(ERR, "Invalid parameter '" +p[1] +"'. Ignoring DECLARE directive.").
			RETURN.
		}
	} ELSE
		DEBUG(INFO, "Will use default '" +val +"' value.").

	IF PP:HASKEY(p[0]:TRIM)
		SET pp[p[0]:TRIM] TO val.
	ELSE
		PP:ADD(p[0]:TRIM, val).
}   //}}}

FUNCTION dUNDECLARE {   //{{{
	PARAMETER parm.

	IF (NOT isVisible) RETURN.

	IF parm = 0 {
		DEBUG(WARN, "Missing needed parameter. Ignoring UNDECLARE directive.").
		RETURN.
	}

	IF PP:HASKEY(parm)
		PP:REMOVE(parm).
	ELSE
		DEBUG(WARN, "Unknown variable '" +parm +"' .").

}   //}}}

FUNCTION dDEFAULT {   //{{{
	PARAMETER parm.

	IF (NOT isVisible) RETURN.

	IF parm = 0 {
		DEBUG(WARN, "Missing needed parameter. Ignoring DEFAULT directive.").
		RETURN.
	}

	IF parm:TOSTRING:TRIM:TOUPPER = "TRUE" OR parm = 1
		SET proc["BOOL-VAR:DEFAULT"] TO	TRUE.
	ELSE IF parm:TOSTRING:TRIM:TOUPPER = "FALSE" OR parm = 0
		SET proc["BOOL-VAR:DEFAULT"] TO	FALSE.
	ELSE {
		DEBUG(ERR, "Invalid parameter '" +parm +"'. Ignoring DEFAULT directive.").
		RETURN.
	}

	DEBUG(INFO, "Undeclared bool-vars will default to '" +proc["BOOL-VAR:DEFAULT"] +"',").
}   //}}}

FUNCTION dINCLUDE {   //{{{
	PARAMETER parm.

	IF (NOT isVisible) RETURN.
	
	IF parm = 0 {
		DEBUG(WARN, "Missing needed parameter. Ignoring INCLUDE directive.").
		RETURN.
	}

	IF (NOT EXISTS(parm)) {
		DEBUG(ERR, "File '" +parm +"' not found. Ignoring INCLUDE directive.").
		RETURN.
	}

	IF proc["INCLUDED:FILE_LIST"]:HASKEY(parm) {
		DEBUG(WARN, "File '" +parm +"' was already included. Skipping.").
		RETURN.
	} ELSE
		proc["INCLUDED:FILE_LIST"]:ADD(parm, TRUE).

	LOCAL fDATA IS OPEN(parm):READALL:STRING.

	LOCAL p IS inDATA:FIND(ENDL).
	IF p = -1
		SET inDATA TO inDATA +ENDL +fDATA.
	ELSE
		SET inDATA TO inDATA:INSERT(p+1, fDATA).

	DEBUG(INFO, "Included file '" +parm +"'.").
}   //}}}

FUNCTION dADDCODE {   //{{{
	PARAMETER parm.

	IF (NOT isVisible) RETURN.

	IF parm = 0 {
		DEBUG(WARN, "Missing needed parameter. Ignoring ADDCODE directive.").
		RETURN.
	}

	IF (NOT PP:HASKEY(parm)) {
		DEBUG(WARN, "Unknown var '" +parm +"'. No code added.").
		RETURN.
	}

	LOCAL p IS inDATA:FIND(ENDL).
	IF p = -1
		SET inDATA TO inDATA +ENDL +PP[parm].
	ELSE
		SET inDATA TO inDATA:INSERT(p, +ENDL +PP[parm]).

	DEBUG(INFO, "Added code from var '" +parm +"'.").
}   //}}}

FUNCTION dEXCLUDENEXT {   //{{{
	PARAMETER parm.

	IF (NOT isVisible) RETURN.

	LOCAL c IS 0.
	IF parm = 0 
		SET c TO 1.
	ELSE
		SET c TO parm:TONUMBER.
	DEBUG(INFO, "Will skip the next " +c +" lines.").

	SET proc["EXCLUDE:UNTIL_LINE"] TO _VAR["LINE:IN"]+c.
}   //}}}

LOCAL ERR IS -1.
LOCAL WARN IS 0.
LOCAL INFO IS 1.
LOCAL REP IS 2.

FUNCTION DEBUG {   //{{{
	PARAMETER level,
		msg IS "".

	LOCAL line IS "      ".

	IF _VAR["LINE:IN"] <> last_line {
		SET line TO " " +_VAR["LINE:IN"]:TOSTRING:PADLEFT(4):REPLACE(" ", " ") +":".
		IF _VAR["VERBOSE"]
			SET last_line TO _VAR["LINE:IN"].
	}

	IF level = WARN {
		SET line TO "!" +line:REMOVE(0,1).
		PRINT line +"[WARN]: " +msg.
		SET _VAR["WARN"] TO _VAR["WARN"] +1.
	} ELSE IF level = ERR {
		SET line TO "@" +line:REMOVE(0,1).
		PRINT line +"[ERR!]: " +msg +BEEP.
		SET _VAR["ERR"] TO _VAR["ERR"] +1.
	} ELSE IF level = INFO AND _VAR["VERBOSE"] {
		PRINT line +"[INFO]: " +msg.
	} ELSE IF level = REP {
		IF ( _VAR["VERBOSE"] OR _VAR["ERR"] > 0 OR _VAR["REPORT"] )
			PRINT line +"[INFO]: "
				+_VAR["WARN"]:TOSTRING:PADLEFT(4) +" WARNINGS,":PADRIGHT(12)
				+_VAR["ERR"]:TOSTRING:PADLEFT(4) +" ERRORS. ":PADRIGHT(12).
		IF _VAR["VERBOSE"] OR _VAR["REPORT"] {
			PRINT line +"[INFO]: "
				+_VAR["LINE:IN"]:TOSTRING:PADLEFT(4) +" lines in, ":PADRIGHT(12)
				+_VAR["LINE:STRIPPED"]:TOSTRING:PADLEFT(4) +" stripped, ":PADRIGHT(12).
			PRINT line +"[INFO]: "
				+_VAR["LINE:OUT"]:TOSTRING:PADLEFT(4) +" lines out.".
		}
	}
}   //}}}

//PP:ADD("STUKA", FALSE).
//PP:ADD("CODE", "PRINT " +QUOTE +"Codicebello" +QUOTE +".
//SET funziona TO 1.
//SET magari TO TRUE.
//").

//preProcess("mod/m_Nlaika2_module.ks", "tutu.ks").

// vim: fdc=6 fdm=marker :
