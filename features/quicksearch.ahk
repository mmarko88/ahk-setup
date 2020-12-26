toEncode :=	[" ","%", """", "#", "&"
 , "/", ":", ";", "<"
 , "=", ">", "?", "@"
 , "[", "\", "]", "^"
 , "``", "{", "|", "}", "~"]

encodeChars :=	["+","%25", "%22", "%23", "%26"
 , "%2F", "%3A", "%3B", "%3C"
 , "%3D", "%3E", "%3F", "%40"
 , "%5B", "%5C", "%5D", "%5E"
 , "%60", "%7B", "%7C", "%7D", "%7E"]


quickGoogleSearch() {
    global Search
    global toEncode, encodeChars
    Gui, Add, Text, x10 y10 h20, Search Google:
    Gui, Add, Edit, yp+25 wp vSearch w500, %Clipboard%
    Gui, Add, Button, Default yp+50 wp hp w100 ggSearch, &Google It!
    Gui, Add, Button, xp+110 ggCancel, &Cancel
    Gui, Show, AutoSize Center, Quick Search
    Return

    gCancel:
        Gui, Destroy
        return

    gSearch:
        Gui, Submit
        Gui, Destroy
        For i, u in toEncode {		; check/replace loop for unsafe chars
        	StringReplace, Search, Search, %	u, %	encodeChars[i], All
        }

        Run, http://www.google.com/search?q=%Search%		; else use Google search
        Return
}