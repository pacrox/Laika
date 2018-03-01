// ----------------------------------------------------------------------------------[WINDOW'S WIDTH]---->

//											
//				LAIKA UI FUNCTIONS.					
//											
//											
//											
// * Updated for KoS 1.1.5.0.								
//											
// TODO:
//	- Add menu's unique name check.
//


//												{{{	
// PUBLIC FUNCTIONS:											
//	UIsetMenu()											
//	UIupdate()											
//													
// PRIVATE FUNCTIONS:											
//	trunc(s, w)   RETURN str									
//	drawMask()											
//	drawMenu(LEXICON(<menu_struct>))								
//	OR drawMenu(LEXICON(<menu_struct>), page)							
//	drawPage(page)											
//	drawButton(num, label)	 RETURN buttnCoord(x, y, w, h)						
//	drawNameTag()											
//	drawBox(x, y, w, h, LIST(h, v, tl, tr, bl, br))   RETURN area(x, y, w, h)			
//	drawSep(x, y, w, LIST(h, sr, sl))   RETURN coord(x, y)						
//	drawCenter(s, x, y)   RETURN x									
//	OR drawCenter(s, x, y, w)   RETURN x								
//	ItemSelect(idx)	RETURN idx									
//	OR ItemSelect("next"|"prev")   RETURN idx							
//	ItemCall()											
//	OR ItemCall(idx)										
//	clearNameTag()											
//	clearButtns()											
//	clearBox(x, y, w, h)										
//	OR clearBox(LIST(x, y, w, h))									
//	makeClearLine()											
//													
// PUBLIC VARIABLES:											
//	SCR 		IS LIST(w, h)									
//	optUI		IS LEXICON(<parm>, <value>)							
//													
// PRIVATE VARIABLES:											
//	frame		IS LIST(<list_of_chars>)							
//	led		IS LIST(<list_of_chars>)							
//	boxBackButtn	IS LIST(<six_frame_chars>)							
//	boxLeftButtn	IS LIST(<six_frame_chars>)							
//	boxRightButtn	IS LIST(<six_frame_chars>)							
//	boxTitleTag	IS LIST(<six_frame_chars>)							
//	coord		IS LEXICON(									
//		button		IS LEXICON(<num>, LIST(x, y, w, h))					
//		led		IS LEXICON(<num>, LIST(x, y))						
//		header:left	IS LIST(x, w)								
//		header:right	IS LIST(x, w)								
//			   )										
//	UIcurrMenu	IS LEXICON(<menu_struct>)							
//	UIcurrPage	IS LEXICON(<page_struct>)							
//	cleanStack	IS LEXICON(<cleanStack_struct>)							
//	clearLine	IS <variable_number_of_spaces>							
//													
// UNCERTAIN VARIABLES:											
//	header		IS <string>									
//	footer		IS <string>									
//												}}}	

LOCAL clearLine IS "".

// Interface options
GLOBAL optsUI IS LEXICON(
	"tagName:width",	12,
	"sideButton:width",	14,
	"backButton:width",	10,
	"header:width",		5,
	"screen:maxwidth",	46,
	"screen:maxheight",	24,
	"menu:height",		15
).

GLOBAL navUI IS LEXICON(
	"btn:next",	{ItemSelect("next").},
	"btn:prev",	{ItemSelect("prev").},
	"btn:enter",	{ItemCall().},
	"btn:back",	{goBack().},
	"scr:refresh",	{UIupdate().}
).

GLOBAL keyMap IS LEXICON(
	55,	"btn:next",	// '7'   key
	56,	"btn:prev",	// '8'   key
	57,	"btn:enter",	// '9'   key
	57351,	"btn:prev",	// UP    key
	57352,	"btn:next",	// DOWN  key
	57353,	"btn:back",	// LEFT  key
	57354,	"btn:enter",	// RIGHT key
	82,	"scr:refresh",	// 'R'   key
	114,	"scr:refresh"	// 'r'   key
).

// Frame and Indicators characters.
LOCAL frame IS LIST( // {{{
	"━",	//  [0] - Horizontal line
	"┃",	//  [1] - Vertical line
	"┏",	//  [2] - Upper Left corner
	"┓",	//  [3] - Upper Right corner
	"┗",	//  [4] - Lower Left corner
	"┛",	//  [5] - Lower Right corner
	"┳",	//  [6] - Tee down
	"┻",	//  [7] - Tee up
	"┣",	//  [8] - Tee right
	"┫",	//  [9] - Tee left
	"╋"	// [10] - Crossing
). // }}}
LOCAL led IS LIST( // {{{
	"○",	//  [0] - Item NOT selected
	"●"	//  [1] - Item selected
). // }}}

// Button widgets.
LOCAL boxBackButtn IS LIST( // {{{
	frame[0], frame[1],
	frame[2], frame[3],
	frame[5], frame[4]
). // }}}
LOCAL boxLeftButtn IS LIST( // {{{
	frame[0], frame[1],
	frame[4], frame[3],
	frame[2], frame[5]
). // }}}
LOCAL boxRightButtn IS LIST( // {{{
	frame[0], frame[1],
	frame[2], frame[5],
	frame[4], frame[3]
). // }}}
LOCAL boxTitleTag IS LIST( // {{{
	frame[0], frame[1],
	frame[6], frame[6],
	frame[4], frame[5]
). // }}}

// Screen informations ( curr.width, curr.height, max.width, max.height )
GLOBAL SCR		IS LIST(0, 0,
				optsUI["screen:maxwidth"], optsUI["screen:maxheight"]).
GLOBAL DIS		IS LIST(1, 2, 0, 0).	// OriginX, OriginY, W, H.

LOCAL  header		IS LAIKA.
LOCAL  footer		IS "This is footer".

LOCAL  coord		IS LEXICON(
				"button", LEXICON(),
				"led", LEXICON()
			   ).
LOCAL  cleanStack	IS LEXICON().
LOCAL  backStack	IS STACK().

LOCAL  dispStack	IS 0.
GLOBAL UIcurrMenu	IS 0.
GLOBAL UIcurrPage	IS 0.

LOCAL clearLine		IS "".

// > UI PUBLIC CALLS < 
FUNCTION gotoMenu { // {{{
	PARAMETER m, 
		p IS -1.

	IF UIcurrMenu:ISTYPE("Lexicon")
		backStack:PUSH(LIST(UIcurrMenu, UIcurrMenu["page:curr"], UIcurrPage["button:sel"])).

	drawMenu(m, p, 1).
} // }}}

FUNCTION gotoPage { // {{{
	PARAMETER p,
		idx IS -1.

	backStack:PUSH(LIST(UIcurrMenu, UIcurrMenu["page:curr"], UIcurrPage["button:sel"])).
	drawPage(p, 1).
} // }}}

FUNCTION goBack { // {{{
	IF backStack:LENGTH = 0 RETURN.

	LOCAL bk IS backStack:POP().

	drawMenu(bk[0], bk[1], bk[2]).
} // }}}


// > UI FUNCTIONS < 
FUNCTION UIinitMenu { // {{{
	PARAMETER m IS 0,
		name IS "EMPTYMENU",
		button IS LEXICON().

	IF (NOT m:ISTYPE("Lexicon"))
		SET m TO LEXICON().

	IF (m:HASKEY("ready")) AND m["ready"]
		RETURN m.

	IF (NOT m:HASKEY("name")) 	SET m["name"] TO name.
	IF (NOT m:HASKEY("page"))	SET m["page"] TO LEXICON().
	IF (NOT m["page"]:HASKEY(0)) 	SET m["page"][0] TO LEXICON().
	IF (NOT m:HASKEY("page:curr")) 	SET m["page:curr"] TO 0.
	IF (NOT m:HASKEY("disp:stack")) SET m["disp:stack"] TO LIST().
	IF (NOT m:HASKEY("disp:size")) 	SET m["disp:size"] TO LIST(0,0).

	LOCAL p IS m["page"].
	FOR i IN p:KEYS {
		IF (NOT p[i]:HASKEY("button")) SET p[i]["button"] TO button.
		IF (NOT p[i]["button"]:HASKEY(0)) SET p[i]["button"][0] TO LIST(UIback, goBack@).
		IF (NOT p[i]:HASKEY("button:queue")) SET p[i]["button:queue"] TO LIST().
		IF (NOT p[i]:HASKEY("button:sel")) SET p[i]["button:sel"] TO 0.
	}

	SET m["ready"] TO TRUE.
	RETURN m.
} // }}}

FUNCTION UIsetMenu { // {{{
	PARAMETER m.

	IF m:ISTYPE("Lexicon") {
		UIinitMenu(m).
		SET UIcurrMenu TO m.
	}
} // }}}

FUNCTION UIupdate { // {{{
	// Can be reduced with a TELNET:UNSAFE version.
	UNTIL FALSE {
		IF TERMINAL:WIDTH < SCR[2] SET TERMINAL:WIDTH TO SCR[2].
		IF TERMINAL:HEIGHT < SCR[3] SET TERMINAL:HEIGHT TO SCR[3].
		SET SCR[0] TO TERMINAL:WIDTH.
		SET SCR[1] TO TERMINAL:HEIGHT.
		WAIT 0.2.
		IF TERMINAL:WIDTH = SCR[0] AND TERMINAL:HEIGHT = SCR[1]
			BREAK.
	}

	SET DIS[2] TO SCR[0]-DIS[0]*2.
	SET DIS[3] TO SCR[1]-DIS[1]-optsUI["menu:height"].

	cleanStack:CLEAR.
	drawMask().
	drawMenu(UIcurrMenu).
} // }}}

FUNCTION UIaddCall { // {{{
	PARAMETER m,
		p,
		button.

	FOR i IN button:KEYS {
		SET m["page"][p]["button"][i] TO button[i]:COPY.
	}
	RETURN m.
} // }}}

FUNCTION UIaddDisp { // {{{
	PARAMETER m,
		s,
		x, y.

	IF (NOT m:HASKEY("disp:stack"))
		SET m["disp:stack"] TO LIST().

	m["disp:stack"]:ADD( LIST(s, x, y)).

	RETURN m["disp:stack"]:LENGTH -1.
} // }}}


// > DISPLAY FUNCTIONS < 
FUNCTION dPrint { // {{{
	PARAMETER s,
		x, y,
		Di IS FALSE.

	SET s TO s:TOSTRING.
	LOCAL l IS s:LENGTH.
	IF l = 0 RETURN.

	LOCAL dS IS LIST(s, x, y).
	LOCAL tval IS 0.

	IF x:ISTYPE("String") {
		IF x = "l" {
			SET x TO 0.
			LOCAL c IS s.
			UNTIL s:LENGTH > DIS[2]
				SET s TO s +c.
		}
		ELSE IF x = "c"
			SET x TO FLOOR((DIS[2]-l)/2).
		ELSE {
			LOCAL ss IS  x:SUBSTRING(0,1).
			IF ss = ">"
				SET tval TO 0.
			ELSE IF ss = "|"
				SET tval TO -l/2.
			ELSE IF ss = "<"
				SET tval TO -l.
			ELSE IF ss = "!" {
				SET tval TO -l.
				LOCAL fl IS s:FINDLAST(".").
				IF fl <> -1
					SET tval TO -fl.
			} ELSE RETURN.
			SET x TO FLOOR(DIS[2] *x:SUBSTRING(1, x:LENGTH -1):TONUMBER +tval).
		}
	} ELSE IF x < 0 SET x TO DIS[2] +x -l +1.

	IF y < 0 SET y TO DIS[3] +y.
	IF x >= DIS[2] RETURN.
	IF y >= DIS[3] OR y < 0 RETURN.

	IF x >= 0
		SET s TO trunc(s, DIS[2]-x).
	ELSE {
		IF l <= -x RETURN.
		SET s TO s:SUBSTRING(-x, l+x).
		IF l+x > DIS[2]
			SET s TO trunc(s, DIS[2]).
		SET x TO 0.
	}

	PRINT s AT(DIS[0] +x, DIS[1] +y).

	dS:ADD(DIS[0] +x).
	dS:ADD(DIS[1] +y).
	dS:ADD(s).
	IF Di:ISTYPE("Boolean") {
		SET Di TO dispStack:LENGTH.
		dispStack:ADD(dS).
	} ELSE
		SET dispStack[Di] TO dS.
	
	RETURN Di.
} // }}}

FUNCTION dUpdate { // {{{
	PARAMETER idx,
		s.

	LOCAL i IS dispStack[idx].

	IF i[0]:LENGTH > s:LENGTH
		dClear(idx).

	dPrint(s, i[1], i[2], idx).
} // }}}

FUNCTION dClear { // {{{
	PARAMETER idx.

	LOCAL i IS dispStack[idx].
	LOCAL l IS i[5]:LENGTH.
	IF l = 0 RETURN.

	LOCAL c IS clearLine:SUBSTRING(0, l).

	PRINT c AT(i[3], i[4]).

	SET i[0] TO "".
	SET i[5] TO "".
} // }}}

FUNCTION dClearAll { // {{{
	dispStack:CLEAR.
	clearBox(DIS).
} // }}}

FUNCTION dRedraw { // {{{
	LOCAL k IS 0.
	IF UIcurrMenu["disp:size"][0] = SCR[0] AND
		UIcurrMenu["disp:size"][1] = SCR[1] {
		FOR i IN dispStack {
			PRINT i[5] AT(i[3], i[4]).
		}
	} ELSE {
		FOR i IN dispStack {
			dPrint(i[0], i[1], i[2], k).
			SET k TO k +1.
		}
		SET UIcurrMenu["disp:size"] TO LIST(SCR[0], SCR[1]).
	}

	RETURN.
} // }}}


// > STRING HELPER FUNCTIONS <  
LOCAL FUNCTION trunc { // {{{
	PARAMETER s, t.

	RETURN s:substring(0, min(t,s:length)).
} // }}}


// > DRAW LOW-LEVEL PRIVATE FUNCTIONS <  
LOCAL FUNCTION drawMask { // {{{
	LOCAL tval	IS 0.
	LOCAL topt	IS 0.
	LOCAL cy	IS 0.
	LOCAL k		IS 0.

	CLEARSCREEN.
	makeClearLine.

	// DRAW Outer frame
	drawBox(0, 1, SCR[0], SCR[1]-2).		// Outer frame

	// DRAW Header and frames
	drawCenter(header, 0, 0).

	SET topt TO optsUI["header:width"].
	SET tval TO SCR[0]-topt-1.
	PRINT frame[1] AT (topt, 0).
	PRINT frame[7] AT (topt, 1).
	PRINT frame[1] AT (tval, 0).
	PRINT frame[7] AT (tval, 1).

	SET coord["header:left"] TO LIST(0, topt).		// (x, w)
	SET coord["header:right"] TO LIST(tval+1, topt).	// (x, w)

	drawCenter(footer, 0, SCR[1]).

	// DRAW Back button
	SET topt TO optsUI["backButton:width"].
	SET tval TO ROUND((SCR[0]-topt)/2).
	drawBox(tval -1, SCR[1] -4, topt +2, 3, boxBackButtn).
	SET coord["button"][0] TO LIST(tval, SCR[1]-3, topt, 1).
	SET coord["led"][0] TO LIST(tval, SCR[1]-3).
	clearBox(tval, SCR[1]-2, topt, 1).

	drawSep(0, SCR[1]-optsUI["menu:height"], SCR[0]).
	SET topt TO optsUI["sideButton:width"].
	SET tval TO SCR[0]-topt.
	SET k TO 1.
	FOR i IN RANGE(3,-1,1) {
		SET cy TO SCR[1]-(i*3+5).

		drawBox(0, cy, topt+1, 3, boxLeftButtn).
		PRINT " " AT(0, cy+1).
		SET coord["button"][k] TO LIST(0, cy+1, topt, 1).
		SET coord["led"][k] TO LIST(0, cy+1).
		SET k TO k+1.

		drawBox(tval-1, cy, topt+1, 3, boxRightButtn).
		PRINT " " AT(SCR[0], cy+1).
		SET coord["button"][k] TO LIST(tval, cy+1, topt, 1).
		SET coord["led"][k] TO LIST(SCR[0], cy+1).
		SET k TO k+1.
	}
} // }}}

LOCAL FUNCTION drawMenu { // {{{
	PARAMETER menu,
		p IS -1,
		idx IS -1.

	IF (NOT (menu:HASKEY("ready"))) OR (NOT menu["ready"])
		UIinitMenu(menu).

	IF p < 0 SET p TO menu["page:curr"].

	IF menu["name"] <> UIcurrMenu["name"]
		clearBox(DIS).

	SET UIcurrMenu TO menu.
	SET dispStack TO menu["disp:stack"].

	drawNameTag().
	drawPage(p, idx).
	dRedraw().
} // }}}

LOCAL FUNCTION drawPage { // {{{
	PARAMETER p,
		idx IS -1.

	clearButtns.
	SET UIcurrPage TO UIcurrMenu["page"][p].

	SET cleanStack["button"] TO LEXICON().	
	FOR b IN UIcurrPage["button"]:KEYS
		SET cleanStack["button"][b] TO drawButton(b, UIcurrPage["button"][b][0]).

	SET UIcurrPage["button:queue"] TO LIST().
	FOR i IN RANGE(9)
		IF UIcurrPage["button"]:HASKEY(i)
			UIcurrPage["button:queue"]:ADD(i).

	SET UIcurrMenu["page:curr"] TO p.

	ItemSelect(idx).
} // }}}

LOCAL FUNCTION drawBox { // {{{
	PARAMETER x, y, w, h,
		frm IS LIST(frame[0], frame[1], frame[2], frame[3], frame[4], frame[5]).
			//   Horiz      Vert      Top-L     Top-R     Btm-L     Btm-R

	LOCAL top IS frm[2].	// Top Left corner
	LOCAL btm IS frm[4].	// Bottom Left corner
	FOR i IN RANGE(1, w-1) {
		SET top TO top + frm[0].	// Horizontal char
		SET btm TO btm + frm[0].	// Horizontal char
	}
	SET top TO top +frm[3].	// Top Right corner
	SET btm TO btm +frm[5].	// Bottom Right corner

	PRINT top AT(x, y).
	FOR i IN RANGE(1, h-1) {
		PRINT frm[1] AT (x, y+i).	// Vertical char
		PRINT frm[1] AT (x+w-1, y+i).	// Vertical char
	}
	PRINT btm AT(x, y +h -1).

	RETURN LIST(x, y, w, h).
} // }}}

LOCAL FUNCTION drawSep { // {{{
	PARAMETER x, y, w,
		frm IS LIST(frame[0], frame[8], frame[9]).

	LOCAL l IS frm[1].
	FOR i IN RANGE(1, w-1)
		SET l TO l +frm[0].
	SET l TO l +frm[2].
	PRINT l AT(x, y).
} // }}}

LOCAL FUNCTION drawCenter { // {{{
	PARAMETER s,
		x,
		y,
		w IS SCR[0].

	LOCAL dx IS FLOOR((w-s:LENGTH)/2).
	PRINT s AT(x+dx, y).

	RETURN x+dx.
} // }}}

LOCAL FUNCTION drawButton { // {{{
	PARAMETER num, label.

	// Can it be removed?
	IF num <0 OR num >8 RETURN.
	// can we add a local var for coord["button"][num]?
	LOCAL s IS trunc(label, coord["button"][num][2]-2).
	
	IF num = 0 
		SET coord["led"][0][0] TO drawCenter(led[0] +" " +s, coord["button"][num][0],
			coord["button"][num][1], coord["button"][num][2]).
	ELSE IF MOD(num,2) = 1
		PRINT led[0] +" " +s AT(coord["button"][num][0], coord["button"][num][1]).
	ELSE
		PRINT s +" " +led[0] AT(coord["button"][num][0]+(coord["button"][num][2]-(s:LENGTH+2)),
			coord["button"][num][1]).

	RETURN LIST(coord["button"][num][0], coord["button"][num][1], coord["button"][num][2], 1).
} // }}}

LOCAL FUNCTION drawNameTag { // {{{
	clearNameTag.
	LOCAL tval IS 0.
	LOCAL s IS trunc(UIcurrMenu["name"], optsUI["tagName:width"]).
	
	SET tval TO drawCenter(s, 0, SCR[1]-14).
	SET cleanStack["name"] TO drawBox(tval-2, SCR[1]-optsUI["menu:height"],
			s:LENGTH+4, 3, boxTitleTag).

} // }}}


LOCAL FUNCTION ItemSelect { // {{{
	PARAMETER idx.

	IF idx:ISTYPE("String") {
		IF idx = "next"
			SET idx TO UIcurrPage["button:sel"] -1.
		ELSE IF idx = "prev"
			SET idx TO UIcurrPage["button:sel"] +1.
		ELSE
			SET idx TO 0.
	} ELSE IF idx = -1
		SET idx TO UIcurrPage["button:sel"].

	LOCAL tval IS 0.
	LOCAL b IS 0.

	SET b TO coord["led"][UIcurrPage["button:queue"][UIcurrPage["button:sel"]]].
	PRINT led[0] AT(b[0], b[1]).

	SET tval TO UIcurrPage["button:queue"]:LENGTH.
	IF idx < 0 SET idx TO tval -1.
	IF idx >= tval SET idx TO 0.

	SET b TO coord["led"][UIcurrPage["button:queue"][idx]].
	PRINT led[1] AT(b[0], b[1]).

	SET UIcurrPage["button:sel"] TO idx.
	RETURN idx.
} // }}}

LOCAL FUNCTION ItemCall { // {{{
	PARAMETER idx IS -1.

	IF idx = -1
		SET idx TO UIcurrPage["button:sel"].

	SET idx TO UIcurrPage["button:queue"][idx].

	//@ IF (CALL BEEP):
	PRINT CHAR(7).
	//@ ENDIF.

	// At present assumes there are only `UserDelegate` types.
	UIcurrPage["button"][idx][1]:CALL().

} // }}}


// > SCREEN CLEAR FUNCTIONS <  
LOCAL FUNCTION clearNameTag { // {{{
	IF NOT cleanStack:HASKEY("name") RETURN.

	LOCAL x IS cleanStack["name"][0].
	LOCAL y IS cleanStack["name"][1].
	LOCAL w IS cleanStack["name"][2].

	PRINT frame[0] AT(x,y).
	PRINT frame[0] AT(x+w-1,y).

	clearBox(x, y+1, w, 2).
} // }}}

LOCAL FUNCTION clearButtns { // {{{
	// Can it be removed? Do we need this check?
	IF NOT cleanStack:HASKEY("button") RETURN.

	FOR b IN cleanStack["button"]:KEYS
		clearBox(cleanStack["button"][b]).
} // }}}

LOCAL FUNCTION clearBox { // {{{
	PARAMETER x, y IS 0, w IS 1, h IS 1.

	IF x:ISTYPE("List") {
		SET y TO x[1].
		SET w TO x[2].
		SET h TO x[3].
		SET x TO x[0].
	}
 
	LOCAL s IS clearLine:SUBSTRING(0, w).
	FOR i IN RANGE(y, y+h) 
		PRINT s AT(x, i).
} // }}}

LOCAL FUNCTION makeClearLine { // {{{
	LOCAL line IS "        ".
	
	SET clearLine TO "".
	FOR i IN RANGE(ceiling(SCR[0]/8)+1)
		SET clearLine TO clearLine +line.
} // }}}

// vim: fdc=6 fdm=marker :
