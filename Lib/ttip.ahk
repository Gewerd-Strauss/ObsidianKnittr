; --uID:2340782430
 ; Metadata:
  ; Snippet: ttip  ;  (v.0.2.1)
  ; --------------------------------------------------------------
  ; Author: Gewerd Strauss
  ; License: WTFPL
  ; --------------------------------------------------------------
  ; Library: Personal Library
  ; Section: 21 - ToolTips
  ; Dependencies: /
  ; AHK_Version: v1
  ; --------------------------------------------------------------
  ; Keywords: TOOLTIP

 ;; Description:
  ;; small tooltip handler
  ;; 
  ;; /*
  ;; 		
  ;; 		Modes:  
  ;; 	                 -1: do not show ttip - useful when you want to temporarily disable it, without having to remove the call every time, but without having to change text every time.
  ;; 		1: remove tt after "to" milliseconds 
  ;; 		2: remove tt after "to" milliseconds, but show again after "to2" milliseconds. Then repeat 
  ;; 		3: not sure anymore what the plan was lol - remove 
  ;; 		4: shows tooltip slightly offset from current mouse, does not repeat
  ;; 		5: keep that tt until the function is called again  
  ;; 
  ;; 		CoordMode:
  ;; 		-1: Default: currently set behaviour
  ;; 		1: Screen
  ;; 		2: Window
  ;; 
  ;; 		to: 
  ;; 		Timeout in milliseconds
  ;; 		
  ;; 		xp/yp: 
  ;; 		xPosition and yPosition of tooltip. 
  ;; 		"NaN": offset by +50/+50 relative to mouse
  ;; 		IF mode=4, 
  ;; 		----  Function uses tooltip 20 by default, use parameter
  ;; 		"currTip" to select a tooltip between 1 and 20. Tooltips are removed and handled
  ;; 		separately from each other, hence a removal of ttip20 will not remove tt14 
  ;; 
  ;; 		---
  ;; 		v.0.2.1
  ;; 		- added Obj2Str-Conversion via "ttip_Obj2Str()"
  ;; 		v.0.1.1 
  ;; 		- Initial build, 	no changelog yet
  ;; 	
  ;; 	*/

  ttip(text:="TTIP: Test",mode:=1,to:=4000,xp:="NaN",yp:="NaN",CoordMode:=-1,to2:=1750,Times:=20,currTip:=20)
  {
  
  	cCoordModeTT:=A_CoordModeToolTip
 	if (mode=-1)
 		return
  	if (text="") || (text=-1)
  		gosub, llTTIP_RemoveTTIP
  	if IsObject(text)
  		text:=ttip_Obj2Str(text)
  	static ttip_text
  	static lastcall_tip
  	static currTip2
  	global ttOnOff
  	currTip2:=currTip
  	cMode:=(CoordMode=1?"Screen":(CoordMode=2?"Window":cCoordModeTT))
  	CoordMode, % cMode
  	tooltip,
  
  	
  	ttip_text:=text
  	lUnevenTimers:=false 
  	MouseGetPos,xp1,yp1
  	if (mode=4) ; set text offset from cursor
  	{
  		yp:=yp1+15
  		xp:=xp1
  	}	
  	else
  	{
  		if (xp="NaN")
  			xp:=xp1 + 50
  		if (yp="NaN")
  			yp:=yp1 + 50
  	}
  	tooltip, % ttip_text,xp,yp,% currTip
  	if (mode=1) ; remove after given time
  	{
  		SetTimer, llTTIP_RemoveTTIP, % "-" to
  	}
  	else if (mode=2) ; remove, but repeatedly show every "to"
  	{
  		; gosub,  A
  		global to_1:=to
  		global to2_1:=to2
  		global tTimes:=Times
  		Settimer,lTTIP_SwitchOnOff,-100
  	}
  	else if (mode=3)
  	{
  		lUnevenTimers:=true
  		SetTimer, llTTIP_RepeatedShow, %  to
  	}
  	else if (mode=5) ; keep until function called again
  	{
  		
  	}
  	CoordMode, % cCoordModeTT
  	return text
  	lTTIP_SwitchOnOff:
  	ttOnOff++
  	if mod(ttOnOff,2)	
  	{
  		gosub, llTTIP_RemoveTTIP
  		sleep, % to_1
  	}
  	else
  	{
  		tooltip, % ttip_text,xp,yp,% currTip
  		sleep, % to2_1
  	}
  	if (ttOnOff>=ttimes)
  	{
  		Settimer, lTTIP_SwitchOnOff, off
  		gosub, llTTIP_RemoveTTIP
  		return
  	}
  	Settimer, lTTIP_SwitchOnOff, -100
  	return
  
  	llTTIP_RepeatedShow:
  	ToolTip, % ttip_text,,, % currTip2
  	if lUnevenTimers
  		sleep, % to2
  	Else
  		sleep, % to
  	return
  	llTTIP_RemoveTTIP:
  	ToolTip,,,,currTip2
  	return
  }
  
  ttip_Obj2Str(Obj,FullPath:=1,BottomBlank:=0){
  	static String,Blank
  	if(FullPath=1)
  		String:=FullPath:=Blank:=""
  	if(IsObject(Obj)){
  		for a,b in Obj{
  			if(IsObject(b))
  				ttip_Obj2Str(b,FullPath "." a,BottomBlank)
  			else{
  				if(BottomBlank=0)
  					String.=FullPath "." a " = " b "`n"
  				else if(b!="")
  					String.=FullPath "." a " = " b "`n"
  				else
  					Blank.=FullPath "." a " =`n"
  			}
  	}}
  	return String Blank
  }


; --uID:2340782430
