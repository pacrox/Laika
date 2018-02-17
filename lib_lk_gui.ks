// GUI-Library for LAIKA.
// 
// This code has been optimized for smaller-size compilation.
//
// Code portions derived from KSLib by TDW86.

GLOBAL GUIChoices 	IS LIST().
GLOBAL GUICurrChoice 	IS -1.

GLOBAL GUIMenuName 	IS "".
GLOBAL GUIMenuButtons 	IS LIST().
GLOBAL GUIMenuBack 	IS "".

// PUBLIC FUNCTIONS.
FUNCTION GUI_setChoice {
	PARAMETER c.

	// If we actually have a previous choice.
	IF GUICurrChoice > -1 {
		LOCAL l IS GUIChoices[GUICurrChoice].
		PRINT "○" AT(l[1],l[2]).
	}

	// Roll values if they exceeds the range.
	IF c < 0 {SET c TO GUIChoices:LENGTH-1.}
	if c >= GUIChoices:LENGTH {SET c TO 0.}

	// TAG current choice.
	LOCAL s is GUIChoices[c].
	PRINT "●" AT(s[1], s[2]).

	SET GUICurrChoice TO c.
}

FUNCTION GUI_redrawMenuScreen {
	GUI_drawMenuScreen(GUIMenuName, GUIMenuBack, GUIMenuButtons).
	GUI_setChoice(GUICurrChoice).
}

FUNCTION GUI_drawMenuScreen {
	PARAMETER n, 	// Name of the current menu.
		bk, 	// Name of back menu.
		l. 	// List of button labels.

	//if l:empty{
	//	print "error: list_of_names should not be empty". print 1/0.
	//}

	// Reset the MenuInfos global-vars.
	GUIChoices:CLEAR.
	SET GUICurrChoice TO -1.

	SET GUIMenuName TO n.
	SET GUIMenuBack TO bk.
	SET GUIMenuButtons TO l.
	
	LOCAL tb IS l:LENGTH.	// Total number of buttons.
	LOCAL w IS SCR[0]. 		// Width of screen.
	// Set box width as pair number.
	IF MOD(w,2) <> 0 {
		SET w TO w-1.
	}

	// Clear screen and write title.
	CLEARSCREEN.
	LOCAL sl IS (w-LAIKA:LENGTH)/2.
	PRINT LAIKA AT(sl,0).

	// Draw the main box.
	drawBox(0, 1, w, SCR[1]-2).

	// Draw Back button and add it to Choices
	LOCAL b   IS "○ НАЗАД ".	// Back-Button string.
	LOCAL bw IS "          ". 	// White spaces for Back-Button.
	SET sl TO (w-b:LENGTH)/2.
	rawBox(sl-2, SCR[1]-4, b:LENGTH+4, 3, "━", "┃", "┏", "┓", "┛", "┗").
	PRINT b AT(sl,SCR[1]-3).
	PRINT bw AT(sl-1,SCR[1]-2).
	GUIChoices:ADD(LIST("BACK", sl, SCR[1]-3, -1)).

	LOCAL bw IS 15.		   // Width of the widget-buttons
	LOCAL hl IS CEILING(tb/2). // Half of buttons number.
	LOCAL i IS hl-1.
	LOCAL ty IS SCR[1]-(i*3+5)-1.

	// Draw the horizontal separator.
	drawSep(0, ty, w).

	// Draw the Menu name tag.
	SET sl TO (w-n:LENGTH)/2.
	rawBox(sl-2, ty, n:LENGTH+4, 3, "━", "┃", "┳", "┳", "┗", "┛").
	PRINT n AT(sl,ty+1).

	// Draw left-side Buttons and adds them to Choices.
	LOCAL k IS 0.
	UNTIL i < 0 {
		SET ty TO SCR[1]-(i*3+5).
		rawBox(0, ty, bw, 3, "━", "┃", "┗", "┓", "┏", "┛").
		PRINT " " AT(0, ty+1).
		IF l[k]:LENGTH > 0 {
			PRINT "○ "+l[k] AT(0, ty+1).
			GUIChoices:ADD(LIST(l[k], 0, ty+1, k)).
		}
		SET i TO i-1.
		SET k TO k+1.
	}

	// Draw right-side Buttons and add them to Choices.
	SET i TO hl-1.
	UNTIL i < 0 {
		SET ty TO SCR[1]-(i*3+5).
		rawBox(w-bw, ty, bw, 3, "━", "┃", "┏", "┛", "┗", "┓").
		PRINT " " AT(w-1, ty+1).
		IF k < tb {
			IF l[k]:LENGTH > 0 {
				PRINT l[k]+" ○" AT(w-2-l[k]:LENGTH, ty+1).
				GUIChoices:ADD(LIST(l[k], w-1, ty+1, k)).
			} 
		}
		SET k TO k+1.
		SET i TO i-1.
	}

	// Draw Help bottom-line.
	PRINT  "⑦ След.  ⑧ Пред." AT(1, SCR[1]).
	LOCAL hR IS "⑨ Поступать".
	PRINT hR AT((w-hR:LENGTH)-3, SCR[1]).
}

// LOW LEVEL FUNCTIONS.
FUNCTION rawBox {
	PARAMETER x, y, w, h,
		Hc,	// Horizontal char.
		Vc,	// Vertical char.
		TLc,	// TopLeft corner char.
		TRc,	// TopRight corner char.
		BLc,	// BottomLeft corner char.
		BRc.	// BottomRight corner char.

	LOCAL sT IS TLc. // Top string line.
	LOCAL sB IS BLc. // Bottom string line.
	LOCAL i IS 1.
	UNTIL i > w-2 {
		SET sT TO sT + Hc.
		SET sB TO sB + Hc.
		SET i TO i + 1.
	}
	SET sT TO sT + TRc.
	SET sB TO sB + BRc.
	PRINT sT AT(x, y).
	PRINT sB AT(x, y + h - 1).

	SET i TO 1.
	UNTIL i >= h - 1 {
		PRINT Vc AT(x , y + i).
		PRINT Vc AT(x + w - 1, y + i).
		SET i TO i + 1.
	}
}

FUNCTION rawSep {
	PARAMETER x, y, w,
		Hc,	// Horizontal char.
		Lc,	// Left side char.
		Rc.	// Right side char.

	LOCAL s IS Lc.	// String line.
	LOCAL i IS 1.
	UNTIL i > w-2 {
		SET s TO s + Hc.
		SET i TO i + 1.
	}
	SET s TO s + Rc.
	PRINT s AT(x, y).
}

FUNCTION drawBox {
	PARAMETER x, y, w, h.
	rawBox(x, y, w, h, "━", "┃", "┏", "┓", "┗", "┛").
}

FUNCTION drawSep {
	PARAMETER x, y, w.
	rawSep(x, y, w, "━", "┣", "┫").
}

// vim: fdc=6 fdm=syntax :
