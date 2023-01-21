; #Requires Autohotkey v1.1+

;ProcessTags("C:\Users\Claudius Main\Desktop\TempTemporal\Source for Word-formatting-Template\index.md")
;ConvertSRC_SYNTAX_V4("C:\Users\Claudius Main\Desktop\TempTemporal\ObsidianHTML Special characters in Image titles\index.md")
;ConvertSRC_SYNTAX_V3("C:\Users\Claudius Main\Desktop\TempTemporal\BE22 Report Author1\index.md")
;ConvertSRC_SYNTAX_V2("C:\Users\Claudius Main\Desktop\TempTemporal\ObsidianHTML Special characters in Image titles\index.md")
ConvertSRC_SYNTAX_V4(PathOrContent) {
    if (FileExist(PathOrContent))
        FileRead buffer, % PathOrContent
    else
        buffer := PathOrContent
    p := 1
    ;@ahk-neko-ignore 1 line
    regex = <img src="(?<SRC>.+)"  width="(?<WIDTH>\d*)" alt="(?<ALT>.*)" title="(?<TITLE>.*)" \/>
    while (p := RegExMatch(buffer, "iOU)" regex, match, p)) {
        options := ""
        src := DecodeUriComponent(match.src)
        if (match.width)
            options .= "out.width='" match.width "', "
        if (match.alt)
            options .= "fig.cap='" Clean(match.alt) "', "
        if (match.title)
            options .= "fig.title='" Clean(match.title) "', "
        options := RTrim(options, ", ")
        tpl =
            (LTrim


            ``````{r, echo=FALSE, %options%}
            knitr::include_graphics("%src%")
            ``````


            )
        buffer := StrReplace(buffer, match[0], tpl)
        p += StrLen(tpl)
    }
    buffer:=Regexreplace(buffer, "``````\{r setup(|.|\n)*``````","") ;; get rid of all potential r setup chunks
    tpl =
        (LTrim
        ---
        ``````{r setup, include=FALSE}
        knitr::opts_chunk$set(echo = FALSE)
        ``````

        )
    buffer := RegExReplace(buffer, "\n---", "`n" tpl,,1,1)
    Clipboard:=buffer
    return buffer
}

Clean(sText) {
    sText := _Decode(sText, 1)
    sText := StrReplace(sText, "'", "\'")
    return sText
}

; DecodeEntities(sText) {
;     return _Decode(sText, 1)
; }

; DecodeUriComponent(sText) {
;     return _Decode(sText, 2)
; }




ConvertSRC_SYNTAX_V3(PathOrContent) { ;; converts % propely, does not recognise and convert double quotes. Hard-fails on single quotes (not escaped)
    if (FileExist(PathOrContent))
        FileRead buffer, % PathOrContent
    else
        buffer := PathOrContent
    p := 1
    ;@ahk-neko-ignore 1 line
    regex = <img src="(?<SRC>[^"]+)"  width="(?<WIDTH>[^"]*)" alt="(?<ALT>[^"]*)" title="(?<TITLE>[^"]*)" \/>
    while (p := RegExMatch(buffer, "iO)" regex, match, p)) {
        options := ""
        src := DecodeUriComponent(match.src)
        if (match.width)
            options .= "out.width='" match.width "', "
        if (match.alt)
            options .= "fig.cap='" DecodeEntities(match.alt) "', "
        if (match.title)
            options .= "fig.title='" DecodeEntities(match.title) "', "
        options := RTrim(options, ", ")
        tpl =
            (LTrim


            ``````{r, echo=FALSE, %options%}
            knitr::include_graphics("%src%")
            ``````

            
            )
        buffer := StrReplace(buffer, match[0], tpl)
        p += StrLen(tpl)
    }
    buffer:=Regexreplace(buffer, "``````\{r setup(|.|\n)*``````","") ;; get rid of all potential r setup chunks
    ;Clipboard:=buffer
    tpl =
        (LTrim
        ---
        ``````{r setup, include=FALSE}
        knitr::opts_chunk$set(echo = FALSE)
        ``````

        )
    buffer := RegExReplace(buffer, "\n---", tpl, , 1, 1)
    Clipboard:=buffer
    return buffer
}

DecodeEntities(sText) {
    return _Decode(sText, 1)
}

DecodeUriComponent(sText) {
    return _Decode(sText, 2)
}

; nMode
; 1 = HTML entity decode
; 2 = decodeURIComponent
_Decode(sText, nMode) {
    static document := ""
    if (document = "") {
        document := ComObjCreate("HTMLFile")
        document.write("<meta http-equiv='X-UA-Compatible' content='IE=Edge'>")
    }
    switch (nMode) {
        case 1:
            document.write(sText)
            txt := document.documentElement.innerText
            document.close()
        case 2:
            txt := document.parentWindow.decodeURIComponent(sText)
        default:
            txt := "Unknown " A_ThisFunc "() mode."
    }
    return txt
}


ConvertSRC_SYNTAX_V2(PathOrContent)
{ ;;  fails on single percentage signs (must be %%), double quotes ("). Converts single quotes (') to double quotes (").
  if (FileExist(PathOrContent))
      FileRead buffer, % PathOrContent
  else
      buffer := PathOrContent
  p := 1
  regex = <img src="(?<SRC>[^"]+)"  width="(?<WIDTH>[^"]*)" alt="(?<ALT>[^"]*)" title="(?<TITLE>[^"]*)" \/>
  while (p := RegExMatch(buffer, "iO)" regex, match, p)){
      options := ""
      src := WinHttpRequest.DecodeUriComponent(match.src)
      ;options .= "fig.src='" src "', " ;; src does not belong in options afaik.
      ;m("t: " match.title,"decoded t: " WinHttpRequest.DecodeUriComponent(match.title), "w: " match.width,"a: " match.alt,"decoded a: " WinHttpRequest.DecodeUriComponent(match.alt))
      if (match.width)
          options .= "out.width='" match.width "', "
      if (match.alt)
          options .= "fig.cap='" strreplace(strreplace(WinHttpRequest.DecodeUriComponent(match.alt),"'",""""),"%","%%") "', "
      if (match.title)
          options .= "fig.title='" strreplace(strreplace(WinHttpRequest.DecodeUriComponent(match.title),"'",""""),"%","%%") "', "
      /* This is undefined
      if (extra)
          options .= "out.extra='" extra "', "
      if (align)
          options .= "fig.align='" align "', "
      */
      options := RTrim(options, ", ")
      tpl =
          (LTrim


          ``````{r, echo=FALSE, %options%}
          knitr::include_graphics("%src%")
          ``````


          )
      buffer := StrReplace(buffer, match[0], tpl)
      p += StrLen(tpl)
  }
  buffer:=Regexreplace(buffer, "``````\{r setup(|.|\n)*``````","") ;; get rid of all potential r setup chunks
  Clipboard:=buffer
  tpl =
      (LTrim
      ---
      ``````{r setup, include=FALSE}
      knitr::opts_chunk$set(echo = FALSE)
      ``````

      )
  buffer := RegExReplace(buffer, "\n---", tpl, , 1, 1)
  Clipboard:=buffer
  return buffer
}
ConvertSRC_SYNTAX_V1(md_Path)
{
    if FileExist(md_Path)
        FileRead, buffer, % md_Path
    else
        buffer:=md_Path
    ;Clipboard:=buffer
    p := 1
    regex = <img src="(?<SRC>[^"]+)"  width="(?<WIDTH>[^"]*)" alt="(?<ALT>[^"]*)" title="(?<TITLE>[^"]*)" \/>
    while (p := RegExMatch(buffer, "iO)" regex, match, p)) {
        align := ""
        cap := match.alt
        HTTPRequest := WinHttpRequest()
        Result:=HTTPRequest.DecodeUri(match.src)
        src := strreplace(match.src,"%20",A_Space)
        src:=Result
        title := match.title
        width := match.width
        options:=""
        if width
            options.="out.width='" width  
        if extra 
            options.=(options!=""?"', ":"") "out.extra='" extra 
        if align
            options.=(options!=""?"', ":"") "fig.align='" align 
        if cap
            options.=(options!=""?"', ":"") "fig.cap='" strreplace(cap,"'","""")
        if title
            options.=(options!=""?"', ":"") "fig.title='" strreplace(title,"'","""")
        if (options!="")
            options:=", " options "'"
        tpl = ;; Yes, the additional spaces in above and below the knitr-block are required, for god knows what reasons.
            (LTrim
            

            ``````{r%options%}
            knitr::include_graphics("%src%")
            ``````


            )
        buffer := StrReplace(buffer, match[0], tpl)
        p += StrLen(tpl)
    }
    tpl=
    (LTrim
    
    ---
    ``````{r setup, include=FALSE}
    knitr::opts_chunk$set(echo = FALSE)
    ``````
    
    )
    buffer1:=Regexreplace(buffer, "``````\{r setup(|.|\n)*``````","") ;; get rid of all potential r setup chunks
    Clipboard:=buffer1
    
    buffer:=RegExReplace(buffer1, "\n---", tpl,,1)
    Clipboard:=buffer
    OutputDebug % buffer
    return buffer
}




; --uID:1752009804
 ; Metadata:
  ; Snippet: WinHttpRequest  ;  (v.2022.11.11.1)
  ; --------------------------------------------------------------
  ; Author: anonymous1184
  ; Source: https://gist.github.com/anonymous1184/e6062286ac7f4c35b612d3a53535cc2a
  ; 
  ; --------------------------------------------------------------
  ; Library: Libs
  ; Section: 11 - Internet/Network
  ; Dependencies: cJSON.ahk
  ; AHK_Version: v1
  ; --------------------------------------------------------------
  ; Keywords: URL decod, URL encod

 ;; Description:
  ;; ; Version: 2022.11.11.1
  ;; ; Usage and examples: https://redd.it/mcjj4s
  ;; ; Testing: http://httpbin.org/ | http://ptsv2.com/
  ;; 

 WinHttpRequest(oOptions:="") {
     static instance := ""
     if (oOptions = false)
         instance := ""
     else if (!instance)
         instance := new WinHttpRequest(oOptions)
     return instance
 }
 

 
 class WinHttpRequest extends WinHttpRequest._Call {
 
     static _doc := ""
 
     ;region: Meta
 
     __New(oOptions:="") {
         if (!IsObject(oOptions))
             oOptions := {}
         this.whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
         ; https://stackoverflow.com/a/59773997/11918484
         if (!oOptions.Proxy)
             this.whr.SetProxy(0)
         else if (oOptions.Proxy = "DIRECT")
             this.whr.SetProxy(1)
         else
             this.whr.SetProxy(2, oOptions.Proxy)
         if (oOptions.HasKey("Revocation")) ; EnableCertificateRevocationCheck
             this.whr.Option[18] := oOptions.Revocation
         if (oOptions.HasKey("SslError")) { ; SslErrorIgnoreFlags
             if (oOptions.SslError = false)
                 oOptions.SslError := 0x3300 ; Ignore all
             else
                 this.whr.Option[18] := true ; Check revocation
             this.whr.Option[4] := oOptions.SslError
         }
         if (!oOptions.HasKey("TLS")) ; SecureProtocols
             this.whr.Option[9] := 0x2800 ; TLS 1.2/1.3
         if (oOptions.HasKey("UA")) ; UserAgentString
             this.whr.Option[0] := oOptions.UA
     }
 
     __Delete() {
         ObjRelease(this.whr), this.whr := ""
     }
     ;endregion
 
     ;region: Static
 
     EncodeUri(sUri) {
         return this._EncodeDecode(sUri, true, false)
     }
 
     EncodeUriComponent(sComponent) {
         return this._EncodeDecode(sComponent, true, true)
     }
 
     DecodeUri(sUri) {
         return this._EncodeDecode(sUri, false, false)
     }
 
     DecodeUriComponent(sComponent) {
         return this._EncodeDecode(sComponent, false, true)
     }
 
     ObjToQuery(oData) {
         if (!IsObject(oData))
             return oData
         out := ""
         for key,val in oData {
             out .= this.EncodeUriComponent(key) "="
             out .= this.EncodeUriComponent(val) "&"
         }
         return RTrim(out, "&")
     }
 
     QueryToObj(sData) {
         if (IsObject(sData))
             return sData
         sData := LTrim(sData, "?")
         obj := {}
         for _,part in StrSplit(sData, "&") {
             pair := StrSplit(part, "=",, 2)
             key := this.DecodeUriComponent(pair[1])
             val := this.DecodeUriComponent(pair[2])
             obj[key] := val
         }
         return obj
     }
     ;endregion
 
     ;region: Public
 
     Request(sMethod, sUrl, mBody:="", oHeaders:=false, oOptions:=false) {
         if (!this.whr)
             throw Exception("Not initialized.", -1)
         sMethod := Format("{:U}", sMethod) ; CONNECT not supported
         if !(sMethod ~= "^(DELETE|GET|HEAD|OPTIONS|PATCH|POST|PUT|TRACE)$")
             throw Exception("Invalid HTTP verb.", -1, sMethod)
         if !(sUrl := Trim(sUrl))
             throw Exception("Empty URL.", -1)
         if (!IsObject(oHeaders))
             oHeaders := {}
         if (!IsObject(oOptions))
             oOptions := {}
         if (sMethod = "POST") {
             this._Post(mBody, oHeaders, !!oOptions.Multipart)
         } else if (sMethod = "GET" && mBody) {
             sUrl := RTrim(sUrl, "&")
             sUrl .= InStr(sUrl, "?") ? "&" : "?"
             sUrl .= this.ObjToQuery(mBody)
             VarSetCapacity(mBody, 0)
         }
         this.whr.Open(sMethod, sUrl, true)
         for key,val in oHeaders
             this.whr.SetRequestHeader(key, val)
         this.whr.Send(mBody)
         this.whr.WaitForResponse()
         if (oOptions.Save) {
             target := RegExReplace(oOptions.Save, "^\h*\*\h*",, forceSave)
             if (this.whr.Status = 200 || forceSave)
                 this._Save(target)
             return this.whr.Status
         }
         out := new this._Response()
         out.Headers := this._Headers()
         out.Status := this.whr.Status
         out.Text := this._Text(oOptions.Encoding)
         return out
     }
     ;endregion
 
     ;region: Private
 
     _EncodeDecode(sText, bEncode, bComponent) {
         if (this._doc = "") {
             this._doc := ComObjCreate("HTMLFile")
             this._doc.write("<meta http-equiv='X-UA-Compatible' content='IE=Edge'>")
         }
         action := (bEncode ? "en" : "de") "codeURI" (bComponent ? "Component" : "")
         return (this._doc.parentWindow)[action](sText)
     }
 
     _Headers() {
         headers := this.whr.GetAllResponseHeaders()
         headers := RTrim(headers, "`r`n")
         out := {}
         for _,line in StrSplit(headers, "`n", "`r") {
             pair := StrSplit(line, ":", " ", 2)
             out[pair[1]] := pair[2]
         }
         return out
     }
 
     _Mime(Extension) {
         mime := {"7z": "application/x-7z-compressed"
             , "gif": "image/gif"
             , "jpg": "image/jpeg"
             , "json": "application/json"
             , "png": "image/png"
             , "zip": "application/zip"}[Extension]
         if (!mime)
             mime := "application/octet-stream"
         return mime
     }
 
     _MultiPart(ByRef mBody) {
         static EOL := "`r`n"
         this._memLen := 0
         this._memPtr := DllCall("LocalAlloc", "UInt",0x0040, "UInt",1)
         boundary := "----------WinHttpRequest-" A_NowUTC A_MSec
         for field,value in mBody
             this._MultiPartAdd(boundary, EOL, field, value)
         this._MultipartStr("--" boundary "--" EOL)
         mBody := ComObjArray(0x11, this._memLen)
         pvData := NumGet(ComObjValue(mBody) + 8 + A_PtrSize)
         DllCall("RtlMoveMemory", "Ptr",pvData, "Ptr",this._memPtr, "Ptr",this._memLen)
         DllCall("LocalFree", "Ptr",this._memPtr)
         return boundary
     }
 
     _MultiPartAdd(sBoundary, EOL, sField, mValue) {
         if (!IsObject(mValue)) {
             str := "--" sBoundary
             str .= EOL
             str .= "Content-Disposition: form-data; name=""" sField """"
             str .= EOL
             str .= EOL
             str .= mValue
             str .= EOL
             this._MultipartStr(str)
             return
         }
         for _,path in mValue {
             SplitPath path, file,, ext
             str := "--" sBoundary
             str .= EOL
             str .= "Content-Disposition: form-data; name=""" sField """; filename=""" file """"
             str .= EOL
             str .= "Content-Type: " this._Mime(ext)
             str .= EOL
             str .= EOL
             this._MultipartStr(str)
             this._MultipartFile(path)
             this._MultipartStr(EOL)
         }
     }
 
     _MultipartFile(sPath) {
         oFile := FileOpen(sPath, 0x0)
         this._memLen += oFile.Length
         this._memPtr := DllCall("LocalReAlloc", "Ptr",this._memPtr, "UInt",this._memLen, "UInt",0x0042)
         oFile.RawRead(this._memPtr + this._memLen - oFile.length, oFile.length)
     }
 
     _MultipartStr(sText) {
         size := StrPut(sText, "UTF-8") - 1
         this._memLen += size
         this._memPtr := DllCall("LocalReAlloc", "Ptr",this._memPtr, "UInt",this._memLen + 1, "UInt",0x0042)
         StrPut(sText, this._memPtr + this._memLen - size, size, "UTF-8")
     }
 
     _Post(ByRef mBody, ByRef oHeaders, bMultipart) {
         isMultipart := 0
         for _,value in mBody
             isMultipart += !!IsObject(value)
         if (isMultipart || bMultipart) {
             mBody := this.QueryToObj(mBody)
             boundary := this._MultiPart(mBody)
             oHeaders["Content-Type"] := "multipart/form-data; boundary=""" boundary """"
         } else {
             mBody := this.ObjToQuery(mBody)
             if (!oHeaders.HasKey("Content-Type"))
                 oHeaders["Content-Type"] := "application/x-www-form-urlencoded"
         }
     }
 
     _Save(sTarget) {
         arr := this.whr.ResponseBody
         pData := NumGet(ComObjValue(arr) + 8 + A_PtrSize)
         length := arr.MaxIndex() + 1
         FileOpen(sTarget, 0x1).RawWrite(pData + 0, length)
     }
 
     _Text(sEncoding) {
         try {
             response := ""
             response := this.whr.ResponseText
         }
         if (!response || sEncoding) {
             arr := this.whr.ResponseBody
             pData := NumGet(ComObjValue(arr) + 8 + A_PtrSize)
             length := arr.MaxIndex() + 1
             response := StrGet(pData, length, sEncoding)
             ObjRelease(arr)
         }
         return response
     }
 
     class _Call {
         __Call(Parameters*) {
             return this.Request(Parameters*)
         }
     }
 
     class _Response {
         Json[] {
             get {
                 return this.Json := Json.Load(this.Text)
             }
         }
     }
 
     ;endregion
 
 }
 

; --uID:1752009804
; --uID:1923497277
 ; Metadata:
  ; Snippet: cJSON.ahk  ;  (v.0.4.1)
  ; --------------------------------------------------------------
  ; Author: G33kDude/Phillip Taylor/GeekDude
  ; License: MIT
  ; LicenseURL:  https://raw.githubusercontent.com/G33kDude/cJson.ahk/main/LICENSE
  ; Source: https://github.com/G33kDude/cJson.ahk
  ; 
  ; --------------------------------------------------------------
  ; Library: Libs
  ; Section: 13 - Objects
  ; Dependencies: /
  ; AHK_Version: v1
  ; --------------------------------------------------------------
  ; Keywords: JSON, C

 ;; Description:
  ;; # cJson.ahk
  ;; 
  ;; The first and only AutoHotkey JSON library to use embedded compiled C for high performance.
  ;; 
  ;; ## Compatibility
  ;; 
  ;; This library is compatible with AutoHotkey v1.1 U64 and U32.
  ;; 
  ;; Now that AHKv2 is out of Alpha, it's likely that its object structures will not change significantly again in the future. Compatibility with AHKv2 will require modification to both the AHK wrapper and the C implementation. Support is planned, but may not be implemented any time soon.
  ;; 
  ;; ## Notes
  ;; 
  ;; ### Data Types
  ;; 
  ;; AutoHotkey does not provide types that uniquely identify all the possible values
  ;; that may be encoded or decoded. To work around this problem, cJson provides
  ;; magic objects that give you greater control over how things are encoded. By
  ;; default, cJson will behave according to the following table:
  ;; 
  ;; | Value         | Encodes as | Decodes as    |
  ;; |---------------|------------|---------------|
  ;; | `true`        | `1`        | `1` *         |
  ;; | `false`       | `0`        | `0` *         |
  ;; | `null`        | N/A        | `""` *        |
  ;; | `0.5` †       | `"0.5"`    | `0.500000`    |
  ;; | `0.5+0` †     | `0.500000` | N/A           |
  ;; | `JSON.True`   | `true`     | N/A           |
  ;; | `JSON.False`  | `false`    | N/A           |
  ;; | `JSON.Null`   | `null`     | N/A           |
  ;; 
  ;; \* To avoid type data loss when decoding `true` and `false`, the class property
  ;;    `JSON.BoolsAsInts` can be set `:= false`. Once set, boolean true and false
  ;;    will decode to `JSON.True` and `JSON.False` respectively. Similarly, for
  ;;    Nulls `JSON.NullsAsStrings` can be set `:= false`. Once set, null will decode
  ;;    to `JSON.Null`.
  ;; 
  ;; † Pure floats, as generated by an expression, will encode as floats. Hybrid
  ;;   floats that contain a string buffer will encode as strings. Floats hard-coded
  ;;   into a script are saved by AHK as hybrid floats. To force encoding as a float,
  ;;   perform some redundant operation like adding zero.
  ;; 
  ;; ### Array Detection
  ;; 
  ;; AutoHotkey makes no internal distinction between indexed-sequential arrays and
  ;; keyed objects. As a result, this distinction must be chosen heuristically by the
  ;; cJson library. If an object contains only sequential integer keys starting at
  ;; `1`, it will be rendered as an array. Otherwise, it will be rendered as an
  ;; object.
  ;; 
  ;; ## Roadmap
  ;; 
  ;; * Allow changing the indent style for pretty print mode.
  ;; * Export differently packaged versions of the library (e.g. JSON, cJson, and
  ;;   Jxon) for better compatibility.
  ;; * Add methods to extract values from the JSON blob without loading the full
  ;;   object into memory.
  ;; * Add methods to replace values in the JSON blob without fully parsing and
  ;;   reformatting the blob.
  ;; * Add a special class to force encoding of indexed arrays as objects.
  ;; * Integrate with a future MCLib-hosted COM-based hash-table style object for
  ;;   even greater performance.
  ;; * AutoHotkey v2 support.
  ;; 
  ;; ---
  ;; 
  ;; ## [Download cJson.ahk](https://github.com/G33kDude/cJson.ahk/releases)

 ;;; Example:
  ;;; ;;EX1: Converting an AHK Object to JSON:
  ;;; 
  ;;; #Include <JSON>
  ;;; 
  ;;; ; Create an object with every supported data type
  ;;; obj := ["abc", 123, {"true": true, "false": false, "null": ""}, [JSON.true, JSON.false, JSON.null]]
  ;;; 
  ;;; ; Convert to JSON
  ;;; MsgBox, % JSON.Dump(obj) ; Expect: ["abc", 123, {"false": 0, "null": "", "true": 1}, [true, false, null]]
  ;;; 
  ;;; ;;EX2: Converting JSON to an AHK Object:
  ;;; 
  ;;; #Include <JSON>
  ;;; 
  ;;; ; Create some JSON
  ;;; str = ["abc", 123, {"true": 1, "false": 0, "null": ""}, [true, false, null]]
  ;;; obj := JSON.Load(str)
  ;;; 
  ;;; MsgBox, % obj[1] ; abc
  ;;; MsgBox, % obj[2] ; 123
  ;;; 
  ;;; MsgBox, % obj[3].true ; 1
  ;;; MsgBox, % obj[3].false ; 0
  ;;; MsgBox, % obj[3].null ; *nothing*
  ;;; 
  ;;; MsgBox, % obj[4, 1] ; 1
  ;;; MsgBox, % obj[4, 2] ; 0
  ;;; MsgBox, % obj[4, 3] ; *nothing*
  ;;; 
  ;;; ; If you set `JSON.BoolsAsInts := false` before calling JSON.Load
  ;;; ;MsgBox, % obj[4, 1] == JSON.True ; 1
  ;;; ;MsgBox, % obj[4, 2] == JSON.False ; 1
  ;;; 
  ;;; ; If you set `JSON.NullsAsStrings := false` before calling JSON.Load
  ;;; ;MsgBox, % obj[4, 3] == JSON.Null ; 1

 class JSON
 {
 	static version := "0.4.1-git-built"
 
 	BoolsAsInts[]
 	{
 		get
 		{
 			this._init()
 			return NumGet(this.lib.bBoolsAsInts, "Int")
 		}
 
 		set
 		{
 			this._init()
 			NumPut(value, this.lib.bBoolsAsInts, "Int")
 			return value
 		}
 	}
 
 	EscapeUnicode[]
 	{
 		get
 		{
 			this._init()
 			return NumGet(this.lib.bEscapeUnicode, "Int")
 		}
 
 		set
 		{
 			this._init()
 			NumPut(value, this.lib.bEscapeUnicode, "Int")
 			return value
 		}
 	}
 
 	_init()
 	{
 		if (this.lib)
 			return
 		this.lib := this._LoadLib()
 
 		; Populate globals
 		NumPut(&this.True, this.lib.objTrue, "UPtr")
 		NumPut(&this.False, this.lib.objFalse, "UPtr")
 		NumPut(&this.Null, this.lib.objNull, "UPtr")
 
 		this.fnGetObj := Func("Object")
 		NumPut(&this.fnGetObj, this.lib.fnGetObj, "UPtr")
 
 		this.fnCastString := Func("Format").Bind("{}")
 		NumPut(&this.fnCastString, this.lib.fnCastString, "UPtr")
 	}
 
 	_LoadLib32Bit() {
 		static CodeBase64 := ""
 		. "FLYQAQAAAAEwVYnlEFOB7LQAkItFFACIhXT///+LRUAIixCh4BYASAAgOcIPhKQAcMdFAvQAFADrOIN9DAAAdCGLRfQF6AEAQA+2GItFDIsAAI1I"
 		. "AotVDIkACmYPvtNmiRAg6w2LRRAAKlABwQAOiRCDRfQAEAViIACEwHW5AMaZiSBFoIlVpAEhRCQmCABGAAYEjQATBCSg6CYcAAACaRQLXlDHACIA"
 		. "DFy4AZfpgK0HAADGRfMAxAgIi1AAkwiLQBAQOcJ1RwATAcdFCuwCuykCHAyLRewAweAEAdCJRbACiwABQAiLVeyDAMIBOdAPlMCIAEXzg0XsAYB9"
 		. "EPMAdAuEIkXsfIrGgkUkAgsHu1sBJpgFu3uCmYlOiRiMTQSAvYGnAHRQx0Wi6Auf6AX5KJ/oAAQjhRgCn8dF5AJ7qQULgUGDauSEaqyDfeSwAA+O"
 		. "qYAPE6EsDaGhhSlSx0XgiyngqilO4AACRQyCKesnUyAgIVUgZcdF3EIgVMdERdiLItgF/Kgi2EcAAkUMgiKDRdyABBiAO0XcfaQPtoB5gPABhMAP"
 		. "hJ/AwIHCeRg5ReR9fOScGItFrMCNALCYiVVKnA2wmAGwZRlEXxfNDxPpgTjKE+nKQgSAIaIcgCEPjZ9C3NQLQOjUBf4oQNQAAkUMRNyhxCyQiVWU"
 		. "zSyQYRaUsRiYbivqC+scwwlgi1UQiVTgCOAEVKQkBIEIYBqVCDqtKAN/Q4ctDIP4AXUek0EBLg76FwBhnAIBKKEDBQYPhV7COqzAmIbkICAAgVXH"
 		. "RdDLKbjQBQcAB98pwynQAAETJQbCKekqJA4QodzFRgzMSwzMBQxfDEYM7swAASUGQwzHphiBsUMMYshLDMgFEl8MRgzIFwABJQZDDGRCDBiNSBAB"
 		. "D7aVg7+siwAoiUwkoSwMjy3N+TD//+kv5BKBLQV1liBCBk8FVsBJ6QRIBYgCdWlAAY1VgCUEVNQUwVzEIho3IhogAItViItFxAHAiI0cAioaD7cT"
 		. "ERoExAEFBgHQD7cAgGaFwHW36ZCiZ2LACyXABRcfJeYKwM8AASUGpmcuHIAVv9RGCgbkAAHjyeQPjEj6RP//ZJ4PhLXiFbzt6xW8P6+IC7wAASUG"
 		. "BMRv4uLhqGH7CAu0/6iIBbQXgAAVA3RUuCABuDtFqBh8pFpxXVNxfV9xA11xkgmLXfzJw5DOkLEaAgBwiFdWkIizUYoMMBQUcQDHQAjRAdjHQAxS"
 		. "DIAECIEEwCEOCJFBwABhH4P4IHQi5dgACnTX2AANdCLJ2AAJdLvYAHsPjIVygjxoBcdFoDIHVkWBj2AAqGMArGEAoYaM8AjQLkAYixWhAJDHRCQg"
 		. "4gFEJCCLIAAAjU2QwDMYjdRNoGAAFFABEEGWcAAf8gtwAOMMQFdxAIkUJED/0IPsJItAY0U+sN8N3w3fDd8N1wB9D6yEVARuEgGFEG9DCQFAg/gi"
 		. "dAq4YCj/xOm/EAqNRYDxYOEHAeAtaf7//4XAdPoX8wGf8AH/Cf8J/wn/CXXVADrFB0LPBZJplAjfVv2SCMQCFcICiIM4CP1jArCyZ4ABTxRPCk8K"
 		. "TwqR1wAsdRIqBelUcBFmkFkWhQl8C18MgCwJQQIxVbCJUAjDqlTDdQLzA1sPhfBFGTYovIVwwUGxIjK5kwB4lgDOfJQA/yj8KI1gkAIiKZ6NEQVf"
 		. "KV8pVimFaBED/EW00KbxAq8VrxWvFa8VYdcAXQ+EtpSP9imlkwNA2B/h+9kfFwr1AdXgi+RjArRhArpQFS8Kby8KLwovCtkfFioFgVzplgGACBkg"
 		. "XcUJegkfIDUXILQWIFJ1AkQ4D4VMYwPvNYB4ReCSA+DDkAOjBAgA6e8FSxRvDbQH/pEgNwVcD4WqF51NKQdxe+CAAYlV4LsCazsuizkGwATbAlzc"
 		. "Aqpd2wIv2wIv3AIv2wKqYtsCCNwCAdsCZtsCqgzcAtPbTW7bAgrcAqql2wJy2wIN3AJ32wIudNsCMR7ZAknbAnUPfIURTT7gA4ADsWVCz+nPwdcw"
 		. "AQADoNyJwuEBOhuIL34w2AA5fyLDAoORAlMBAdCD6DCFAwTpgKk1g/hAfi0B2ADAtwBGfx+LReAPtwAAicKLRQiLAEEAkAHQg+g3AXDgIGaJEOtF"
 		. "BVhmg1D4YH4tCDRmE+hXEQZ0Crj/AADpbQZEAAACQI1QAgAOiQAQg0XcAYN93BADD44WAD6DReAoAusmAypCBCoQjQpKAioIAEmNSAKJGk0AZhIA"
 		. "Ugh9Ig+FAP/8//+LRQyLEkgBJinIAXcMi0AQCIPoBAEp4GbHCgAMeLgAEADp3QUjBBYDSC10JIgGLw8IjrEDig85D4+foYAIx0XYAYInDIArIhSB"
 		. "A8dACIEnx0DmDAEDiSh1FIAWAWiKPjGIEDB1IxMghRXpjhELKTB+dQlJf2frCkcBdlCBd2vaCmtAyAAB2bsKgBn3AOMB0YnKi00IAIsJjXECi10I"
 		. "AIkzD7cxD7/OAInLwfsfAcgRANqDwNCD0v+LAE0MiUEIiVEMSck+fhoJGX6dRXCrEAQAAJCIBi4PhYalTSyGI2YPbsDAAADKZg9iwWYP1mSFUEAQ"
 		. "361BAYAI3VZYwGpBUAUAVNQBVOsAQotV1InQweAAAgHQAcCJRdQBQxVIAotVCIkKAcAbmIPoMImFTIXAD9tDAUXU3vmBErBACN7BhRTIMA7KMCKi"
 		. "SANldBJIA0UPHIVVACANMQMHFHUxVQk00MAA2gA00wA0lVEVNMZF00uBE0AEAY3KF+tAzAYIK3URhgxX0IhNMsRiH8KizEGM61Ani1XMh07DUU4B"
 		. "ENiJRcxYFb3HRSLIwTDHRcRCChOLhFXIqDHIg0XEQBgAxDtFzHzlgH0Q0wB0E0Mv20XIoaMwWAjrEUcCyUYiFeUoKyR0WCBN2JmJAN8Pr/iJ1g+v"
 		. "APEB/vfhjQwWk2FVJFHrHcYGBXVmCibYcApELgMAA3oMAqFqZXQPhasiGsAiGgA3i0XABQcXAAAAD7YAZg++0FEmBTnCdGQqy+1AgwxFwKAexgaE"
 		. "wHW6lA+2wIYAQAF0G6UPJ0N4oidDeOssQwMJABCLFeQWgoWJUAhCoUIBAItABKMCiYAUJP/Qg+wEgxcuT2UPhKqFF7yFF7wF6gyaFw6PF7yAF8YG"
 		. "mhf76I+JF9yHF0IBgxdBAYsXgpKrlG51f8dFIgOA6zSLRbgFEhMX0gcCF+tYrBa4oBZmBvWgFr3nEeDnEUIB4xFBAQnqEesFIguNZfRbMF5fXcNB"
 		. "AgUAIlUAbmtub3duX08AYmplY3RfAA0KCiALIqUBdHJ1ZQAAZmFsc2UAbgh1bGzHBVZhbHUAZV8AMDEyMzQANTY3ODlBQkMAREVGAFWJ5VNAg+xU"
 		. "x0X0ZreLAEAUjVX0iVQkIBTHRCQQIitEJKIMwUONVQzAAgjAAQ8AqaAF4HPDFhjHReSpAgVF6MMA7MMA8IMKcBCJReRgAuPOIgwYqItV9MAIIKQL"
 		. "HOQAghjhAI1N5IlMgw/fwQyBD8QDwjwgEAQnD2De0hCDNgl1MCEQcE7xBUAIi1UQi1JFAgTE62hmAgN1XGECElESu0AWf7lBBTnDGSjRfBWGAT0g"
 		. "AYCJQNCD2P99LvAajTRV4HEPiXAPMR4EJATooQAChcB0EYsETeBGA4kBiVEEAJCLXfzJw5CQAXAVg+xYZsdF7ikTH0XwIBYUARBNDAC6zczMzInI"
 		. "9xDiweoDNkopwYkCyhAHwDCDbfQBgSGA9GaJVEXGsAMJ4gL34pAC6AOJRQAMg30MAHW5jUJVoAH0AcABkAIQDYAJCGIRwwko/v//hpBACLMdYMdF"
 		. "+EIuBhrkRcAKRfjB4AQgAdCJRdgBAUAYwDlF+A+NRPAZAAsKzlEC2PEMRfTGRQDzAIN99AB5B2GQAAH3XfRQHEMM9KC6Z2ZmZkAM6nAJhPgCUnkp"
 		. "2InC/wyog23s8gzs8QymngNAwfkficopoAj0AYEGdaWAffMAdAYOQQMhA8dERaYtHXAnpsAAwA5gAtDGRYbrkCXiJotF5I0hjCDQAdAPtzBn5I3S"
 		. "DMEWAcgDOnWQOQgCQABmhcB1GSUBDGUmAQYQBQHrEKG8AnQDUIS8AnQHg0XkAQDrh5CAfesAD2aEoWbhH1XYMJnRLemSyiQuQBwhFYyj4gChwxTU"
 		. "xkXjgAvcgwvq3IIF1IQL3I8LCAKFC/sjAYoL44ILvAKBC7wCgQtC3IML4wB0D0oL65AYg0X48n1AEFIL8Nf9//9ySLosvz1iABNyQ2Aj6AWBD90A"
 		. "3RpdkC7YswGyDsdF4ONjACIbjUXoUCcwAZEH7KGIED3jQBWhAB1BIXXATCQYjU3YBUFCav8MQeVIFUEhCz8LPwvAATES0QAxBIsAADqJIEmfC3+f"
 		. "C58LnwufC58Lnws2O2Q9wAnmkgrSNjQKV0l8GIM1AStMfW6NRahoSib2kEBUD+s3gUN0IACLVbCLRfABwFSNHPBqDHSWDHGWE12xzg2hIcBs8CAQ"
 		. "wWzw1gEFA2YntzNzPvR60xMA7IN97AB5bYtMTeyPQY9BuDAQBCk60KpOvr4DpkHCBXWjB+ECwQJAQb4tAOtbX88GzwZfVa8GrwalhCPrQj5CEyeN"
 		. "Vb7WVuhnvxO/E7IT6AF8AyYUqWvpNbMqGJIGF3oFUIMimADpyXLcmAXpt5PdKQTkdVaiAxStA1wAVx0JHwYTBmMeBlEZBlxPHwYfBh8GaALpAR4G"
 		. "73vTaBMGCB8GHwYfBmYCYgAAgrEA6Z8CAACLRRAgiwCNUAEAcIkQBOmNAogID7cAZgCD+Ax1VoN9DEAAdBSLRQwAjEgAAotVDIkKZsdgAFwA6w0K"
 		. "3AJMF6ENTGYA6T0OwisJwoIKPGFuAOnbAQ1hFskCEQRhDTxhcgDpKnmOMGeJMAm8MHQAFOkXjjAFgAgPtgUABAAAAITAdCkRBjYfdgyGBX52B0K4"
 		. "ABMA6wW4gAIAoIPgAeszCBQYCBTCE4QFPaAAdw0awBc2bykwjgl1jQkDGw+3AMCLVRCJVCQIAQEKVCQEiQQk6DptgR4rwhHAJ8gRi1UhwAwSZokQ"
 		. "jRxFCAICBC+FwA+FOvwU//9TISJNIZDJwwCQkJBVieVTgwTsJIAQZolF2McARfAnFwAAx0UC+AE/6y0Pt0XYAIPgD4nCi0XwAAHQD7YAZg++ANCL"
 		. "RfhmiVRFQugBB2bB6AQBDoMARfgBg334A36gzcdF9APBDjOCIQAci0X0D7dcRZLoiiOJ2hAybfRAEBD0AHnHAl6LXfwBwic="
 		static Code := false
 		if ((A_PtrSize * 8) != 32) {
 			Throw Exception("_LoadLib32Bit does not support " (A_PtrSize * 8) " bit AHK, please run using 32 bit AHK")
 		}
 		; MCL standalone loader https://github.com/G33kDude/MCLib.ahk
 		; Copyright (c) 2021 G33kDude, CloakerSmoker (CC-BY-4.0)
 		; https://creativecommons.org/licenses/by/4.0/
 		if (!Code) {
 			CompressedSize := VarSetCapacity(DecompressionBuffer, 3935, 0)
 			if !DllCall("Crypt32\CryptStringToBinary", "Str", CodeBase64, "UInt", 0, "UInt", 1, "Ptr", &DecompressionBuffer, "UInt*", CompressedSize, "Ptr", 0, "Ptr", 0, "UInt")
 				throw Exception("Failed to convert MCLib b64 to binary")
 			if !(pCode := DllCall("GlobalAlloc", "UInt", 0, "Ptr", 9092, "Ptr"))
 				throw Exception("Failed to reserve MCLib memory")
 			DecompressedSize := 0
 			if (DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", pCode, "UInt", 9092, "Ptr", &DecompressionBuffer, "UInt", CompressedSize, "UInt*", DecompressedSize, "UInt"))
 				throw Exception("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
 			for k, Offset in [33, 66, 116, 385, 435, 552, 602, 691, 741, 948, 998, 1256, 1283, 1333, 1355, 1382, 1432, 1454, 1481, 1531, 1778, 1828, 1954, 2004, 2043, 2093, 2360, 2371, 3016, 3027, 5351, 5406, 5420, 5465, 5476, 5487, 5540, 5595, 5609, 5654, 5665, 5676, 5725, 5777, 5798, 5809, 5820, 7094, 7105, 7280, 7291, 8610, 8949] {
 				Old := NumGet(pCode + 0, Offset, "Ptr")
 				NumPut(Old + pCode, pCode + 0, Offset, "Ptr")
 			}
 			OldProtect := 0
 			if !DllCall("VirtualProtect", "Ptr", pCode, "Ptr", 9092, "UInt", 0x40, "UInt*", OldProtect, "UInt")
 				Throw Exception("Failed to mark MCLib memory as executable")
 			Exports := {}
 			for ExportName, ExportOffset in {"bBoolsAsInts": 0, "bEscapeUnicode": 4, "dumps": 8, "fnCastString": 2184, "fnGetObj": 2188, "loads": 2192, "objFalse": 5852, "objNull": 5856, "objTrue": 5860} {
 				Exports[ExportName] := pCode + ExportOffset
 			}
 			Code := Exports
 		}
 		return Code
 	}
 	_LoadLib64Bit() {
 		static CodeBase64 := ""
 		. "xrUMAQALAA3wVUiJ5RBIgezAAChIiU0AEEiJVRhMiUUAIESJyIhFKEggi0UQSIsABAWVAh0APosASDnCD0SEvABWx0X8AXrrAEdIg30YAHQtAItF"
 		. "/EiYSI0VQo0ATkQPtgQAZkUCGAFgjUgCSItVABhIiQpmQQ++QNBmiRDrDwAbICCLAI1QAQEIiRDQg0X8AQU/TQA/AT4QhMB1pQJ9iUWgEEiLTSAC"
 		. "Q41FoABJichIicHoRhYjAI4CeRkQaMcAIgoADmW4gVfpFgkAMADGRfuAZYFsUDBJgwNAIABsdVsADAEox0X0Amw1hBAYiwRF9IBMweAFSAGa0IBG"
 		. "sIALgAFQEIALGIPAAQANAImUwIgARfuDRfQBgH2Q+wB0EwEZY9AILRR8sgNWLIIPCEG4wlsBMQZBuHsBuw9gBESJj1+AfSgAdFBkx0XwjLvwgpsm"
 		. "mhyxu/DAXcMP5hvHXcjHRezCSqUGAidEQQLsSUGog33sAA8sjsqBL5hhLJQxZsfUReiMMeiCIV+AIa8xluiAMcMPH4gx6y+ZJkIglCZ5x0XkgiZo"
 		. "KMdF4Mwo4MIYvhpt8SjgwCjDD37AD8UogwRF5MAFMDtF5H0IkA+2wJDwAYTAuA+E6EDpQVwGkTBBmdyNiZxbUL1AAajgB+FoSpjoaJjkaP4fJQoc"
 		. "mTQK6f5DVIkK6epgAo3qEzjiE0Fsx0XcrCay3KIeihm/Jq8m3KAjXeMHSuAHCIOFGpCIGpAthBophhrWJCwsDesbp2YK5AlkCb0gewk6UC4Dv04t"
 		. "NItAGIP4AU51YTCAEAoQXB4gcReGA2Iw4wQGD4Wf4EMzYwVhswkYoAHgl2nH1EXYbC/YYicXAAR/L01tL9hgL+MH1xdnL+m0iwJpD21AA2QP1GwP"
 		. "utRiB6AABH8PbQ/UYA9V4wdgaQ8Pag8BZw/QtWwP0GIHKn8PcA/QYA8p4wfqFmgPk2JyMI00SAFACk1B48AQAExDgAZBColMJCDBNa1g+P//6WjE"
 		. "M8I1Bax1H2QFLDtiITs9SQUQAg+Fg6NtqEiNoJVw////4QSKYJoox0XMIhxIIxwuSIiLlXjAA4tFzAAVYAHATI0EABttHEHoD7cQUxzMkAAKBFBd"
 		. "AA+3AGaFwHWeVOmqUjzIHBXIEhHdbhUfFR8V7QbIEBXzA5338ANbPCoRb6AO7zMPTtoFDuzQBahI8XYPjET5RP//8VwPhN3iDMTl7AzE4gjwFO8M"
 		. "7wwNB/bEAAfzA7DwA1dzMZRyY+sBkskGvMIChs8GzwbOBha8wAbzA0bIBoNFwIFwAcA7RTB8kKyFOl2khX2vha+FqJFIgeLEAQxdw5AKAOyiDgAK"
 		. "VcCjMEEsjawkgBVCpI2zpJURJEiLhQthAKAbFLUASMdACNvyEZAJhaICAQpQAArTAAcRUXUBMSmD+CB01REtAQp0wi0BDXSvES0BCXScLQF7D4WO"
 		. "KcJUrweiB8dFUMIQKMdFWHQAYHIAiwWOA+E4AT9BowX1/tAAEMdEJEBTAkQkOAGCAI1VMEiJVCSqMIAAUIEAKJABICG3VEG58QFBkha6ogKJUMFB"
 		. "/9LwFzhQbGh/zxDPEM8QzxDPEM8QJwF9WA+EwvJHaQGF8IesgV4Bg/gidAq4IBDw/+lmEYEOoblgB8IeAOj3/f//hcB0+iIDAkUBAu8M7wzvDO8M"
 		. "l+8M7wwkAToVCsQQDwi3CAhSKMcLOsMLtAOIsgNJsDKLjQMsRWjESQL/YA1/Go8Njw2PDY8Njw0nAZgsdR1vB2MH6cLQC+dAkIwd1Qy6D58QnBCw"
 		. "OQIJtjmLVWhIiVAaCLPSfcoDkwVbD4W+ZUJ4PwX0M/LJcAD4dADTUkIQM8P7+TO10QD/M+yNVdDF8zPw/zP/M+AZwtjwM3DHhay07R8aPx8aHxof"
 		. "Gh8aHxonAV0PNoRh45803kdQKCfH+pkpJxUOMQLiJouVcQz1UA1wRCftMBgvDS8NLw0BJAH+tQAKdMJIi4XAAAAAAEiLAA+3AEBmg/gNdK8NkAlE"
 		. "dJwNSCx1JAdISAiNUAIFGokQg4UCrAAQAemq/v//gpANbl10Crj/AAC46T4NASoTggAJyAAJMGbHAAkBIwELSIuAVXBIiVAIuAALGADpAQo8A1ki"
 		. "D4WMEwUaUwUXiYWgAgkdBFiVggaALQc7CADpRFkEDTGFwHWEXYKCDA8/XA+F9gMhP7mEVnU0AAmCPIETiQJC5YA8IpYg6ccKL4Q6FCOqXBcjgBAj"
 		. "L5QRL5cRKjmQEWKUEQiXEfICVY8RZpQRDJcRq5ARblWUEQqXEWSQEXKUEQ11lxEdkBF0lBFCuJMR1sIBjxF1D4WFigWOmcHEFQAAx4WcAcvByw47"
 		. "gwyBBoARweAEiUeB/UIKT1MvfkJNAjkcfy/HB2IHxwMB0INk6DDpCemuo2sqCEBEfj9NAkZ/LJoKN6mJCutczQdgLwpmPAqmVyoKhHm1CNcpg0Io"
 		. "CAGDvcEAAw+OuIlAmkiDIggC6zrjB8J16QcQSI1K5wchitUjPkggPo0DExJQLmCXLJD7QAtFkkgmBynIBkiCFuMCQAhIg+hOBMs8dRcjpdcHbzEt"
 		. "xHQubj4PjgyKp+Q+iA+P9eCgx4WYwSDLh6YADxQGqMdAICCwDDx1IuMGoSTfooMGMHUPITjTCk1+cA4wD46JwdACOX9260yGKAC9AInQSMHgAkgB"
 		. "gNBIAcBJicBpDCkgNYuVYwwKoAdID6C/wEwBwGAP0AUISyPFTGYfbg5+jiVMUwgGAAAO4S4PheYD2BtIPmYP78DySIwPKsEUYQLyDxHgQBUGMQXA"
 		. "M5TEM+tsixKVYQGJ0MAbAdAB7MCJQgP4G5jAOwIG8AUNcADScAASBGYPKMgQ8g9eyjYHEEAIsPIPWME8CFwQFw8kTI5q6h9jAWV0ngJFuA+F+I9N"
 		. "/RCzAhRXImP/Ef8RxoWTDyoBKiFNkwEBTwdDB+syPQMr3HUf3gQfLUsRE68hhCEKOrI1jFRa6zqLlduxAMYbQZ8pnBtEER4xA4NfB18HfqDHhYiE"
 		. "IojHhYRVBxyLlVEBSygj4QCDAgIBi2IAOyEyBnzWgL2iD3Qq61kh4BfJUCONUQMQIxoilOsolwJIgxoPKvIFePIPWb0k+R3BpdU6i0FSREiYSA+v"
 		. "OTjr8jg6AwV1vwawBqEDvwalugYMtyIDAFNToQ98oPh0D4XfkhOAlROMUouyAJAJjRXSEAOAD7YEEGYPvkEK6ZgDOcIlr0taBZ1moQQL8BYWBYAU"
 		. "BYTAdZcAD7YFUuT//4T4wHQdyQqoUtI/FRFkhcwVDgMHV0sF/CI2Q1AIiwXu0QCJwf/SBVMPq/+G+GYPhdMJUQ9FfCIPTItFfN3SCeewAv8O+w5b"
 		. "/zz3DmhFfAG1BJu0BJAOoLmQDmjjnw5MYZ4OBKMGbZgO8lQHkw7kggGWDsFBLzP4bg+FpZIOeKESBkmLRXjSCQOfDmWXDgeSDut0bw5lDnhbYA6D"
 		. "BLoxJ2MOo+wLVSv4yOMLQ+oLNeoL6wUhUgdIgcQwsAldwz6QBwCkKQ8ADwACACJVAG5rbm93bl9PAGJqZWN0XwANCgoQCSLVAHRydWUAAGZhbHNl"
 		. "AG4IdWxs5wJWYWx1AGVfADAxMjM0ADU2Nzg5QUJDAERFRgBVSInlAEiDxIBIiU0QAEiJVRhMiUUgaMdF/ANTRcBREVsoAEiNTRhIjVX8AEiJVCQo"
 		. "x0QkEiDxAUG5MSxJicgDcRJgAk0Q/9BIx0RF4NIAx0XodADwwbQEIEiJReDgAFOJAaIFTItQMItF/IpIEAVA0wJEJDiFAOIwggCNVeBGB8BXQAcH"
 		. "ogdiFXGWTRBB/9Lz0QWE73UeogaBl8IYYAYT5ADRGOtgpwIDdVODtQEBDIBIOdB9QG4V1AK68Bp/Qhs50H9l4FNF8Q/YSXCIUwfooUE2hcB0D6AB"
 		. "2LDuBVADUjAGEJBIg+xmgBge8xXsYPEV5BVmo7IREAWJRfigFhSABACLTRiJyrjNzATMzDBTwkjB6CAgicLB6gMmXinBAInKidCDwDCDzLQAbfwB"
 		. "icKLRfwASJhmiVRFwIsARRiJwrjNzMwAzEgPr8JIwegAIMHoA4lFGIMAfRgAdalIjVUDAIQArEgBwEgB0ABIi1UgSYnQSACJwkiLTRDoAQD+//+Q"
 		. "SIPEYAhdw5AGAFVIieUASIPscEiJTRAASIlVGEyJRSAQx0X8AAAA6a4CAAAASItFEEiLRFAYA1bB4AUBV4k0RdABD2MAYQEdQDAASDnCD42aAQBg"
 		. "AGbHRbgCNAAaQAEAUEXwxkXvAEhAg33wAHkIAAoBAEj3XfDHRegUgwBfAJTwSLpnZgMAgEiJyEj36kgArgDB+AJJichJwWD4P0wpwAG8gQngBgIB"
 		. "PABrKcFIicoAidCDwDCDbegVgo3og42QmCdIwflSPwAbSCmBXfACR3WAgIB97wB0EIEigYMhx0RFkC0AgKEGkIIHhKGJRcDGRSDnAMdF4IGJi0Uy"
 		. "4IAMjRQBcQEPD7cKEAQJDAEJGEgByAAPtwBmOcJ1b4EPFQBmhcB1HokLi4AXhQsGgDIB6zqTGgR0IlMNdAqDReAQAelm/0B2gH3nkAAPhPYCVkUg"
 		. "wH6JwC4QuMBkAOkBQAFlCmw4AWyMysMKhWrIqMZF38A52MM52IYb/sjFOYIE0DmNCsU5xwXLOb7fwjlRDcE5UQ3BOdjGORDfAHQSzTjrIIMsRfwA"
 		. "cgg5IAI5O/0M//+ApEA6g8RwXWLDwruB7JABBIS8SGvEdsAB6MQB8MEBwLLgAgUCwPIPEADyD6IRQIXHRcCECMjEAXrQwgGNgGdAioADASNIAIsF"
 		. "hOb//0iLoABMi1AwQAN2QQMQx0QkQAMNRCQ4hQICiwAfiVQkMMHtlQECKEAGIAEQQbnBBwpBwi26QgWJwUH/sNJIgcQBF/B3QOl3fwAXABmgeKNs"
 		. "gSEACOReD0yJm39veW+4MOAHKRzQgyyTv2+pbw+Feg9gOWEIIwhgb8AtAOkegF8T34IfE9qCx0XsCSEu61DgARgAdDYLi6oAC+xCAUyNBAIzYlRg"
 		. "K41IQAFhOQpBQQBlZokQ6w/hU4sQAI1QAQEBiRCDWEXsARQJR2OO5VRAWyc85Dsg6TsDExyvD2aAxwAiAOleBEOAKcgP6UpjAhAhDYP4KCJ1ZmMI"
 		. "GXIIXADT7hdcDuYDTw7SYwJEDk5cXw5fDsgF6XNQDl8dSg4IXw5fDsYFYgDp2gBQDuxk5EMODF8OXw5hxgVmAOmNwwsqB3l9KgcKLwcvBy8HLwfi"
 		. "Am5IAOkaLwfpBioHDR8vBy8HLwcvB+ICcgDptqcwTy0HkzMBJAcJLwcPLwcvBy8H4gJ0AOk0BS8H6aFXD7YFmdZA//+EwHQr1wcfRHYNxwB+dgcT"
 		. "ZwVB4jqD4AHrNqkCGoWpAhTFAD2gAHd9A31ABnxfDV8NXg3vAuECdbPvAtQHD7dRUPFyGCBUUInB6IZxCDTDBB43zwRgAGADEo9MAQhFEANxT0IN"
 		. "hcAPhab736BtXwnYQT4EQaggJE71TQtgWdVriQBrjQVC8wdwBVBZxKjrMg+3RXAQg+AP0qzAWlBTtrAAZg++kqiSXugRAjBmwegEEQTRgIN9gPwD"
 		. "fsjHRfhwOwgA6z9TCiWLRfjASJhED7dE4HwOC5hEicJfD+BbbfjQBDD4AHm7JVr1Cw=="
 		static Code := false
 		if ((A_PtrSize * 8) != 64) {
 			Throw Exception("_LoadLib64Bit does not support " (A_PtrSize * 8) " bit AHK, please run using 64 bit AHK")
 		}
 		; MCL standalone loader https://github.com/G33kDude/MCLib.ahk
 		; Copyright (c) 2021 G33kDude, CloakerSmoker (CC-BY-4.0)
 		; https://creativecommons.org/licenses/by/4.0/
 		if (!Code) {
 			CompressedSize := VarSetCapacity(DecompressionBuffer, 4249, 0)
 			if !DllCall("Crypt32\CryptStringToBinary", "Str", CodeBase64, "UInt", 0, "UInt", 1, "Ptr", &DecompressionBuffer, "UInt*", CompressedSize, "Ptr", 0, "Ptr", 0, "UInt")
 				throw Exception("Failed to convert MCLib b64 to binary")
 			if !(pCode := DllCall("GlobalAlloc", "UInt", 0, "Ptr", 11168, "Ptr"))
 				throw Exception("Failed to reserve MCLib memory")
 			DecompressedSize := 0
 			if (DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", pCode, "UInt", 11168, "Ptr", &DecompressionBuffer, "UInt", CompressedSize, "UInt*", DecompressedSize, "UInt"))
 				throw Exception("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
 			OldProtect := 0
 			if !DllCall("VirtualProtect", "Ptr", pCode, "Ptr", 11168, "UInt", 0x40, "UInt*", OldProtect, "UInt")
 				Throw Exception("Failed to mark MCLib memory as executable")
 			Exports := {}
 			for ExportName, ExportOffset in {"bBoolsAsInts": 0, "bEscapeUnicode": 16, "dumps": 32, "fnCastString": 2624, "fnGetObj": 2640, "loads": 2656, "objFalse": 7632, "objNull": 7648, "objTrue": 7664} {
 				Exports[ExportName] := pCode + ExportOffset
 			}
 			Code := Exports
 		}
 		return Code
 	}
 	_LoadLib() {
 		return A_PtrSize = 4 ? this._LoadLib32Bit() : this._LoadLib64Bit()
 	}
 
 	Dump(obj, pretty := 0)
 	{
 		this._init()
 		if (!IsObject(obj))
 			throw Exception("Input must be object")
 		size := 0
 		DllCall(this.lib.dumps, "Ptr", &obj, "Ptr", 0, "Int*", size
 		, "Int", !!pretty, "Int", 0, "CDecl Ptr")
 		VarSetCapacity(buf, size*2+2, 0)
 		DllCall(this.lib.dumps, "Ptr", &obj, "Ptr*", &buf, "Int*", size
 		, "Int", !!pretty, "Int", 0, "CDecl Ptr")
 		return StrGet(&buf, size, "UTF-16")
 	}
 
 	Load(ByRef json)
 	{
 		this._init()
 
 		_json := " " json ; Prefix with a space to provide room for BSTR prefixes
 		VarSetCapacity(pJson, A_PtrSize)
 		NumPut(&_json, &pJson, 0, "Ptr")
 
 		VarSetCapacity(pResult, 24)
 
 		if (r := DllCall(this.lib.loads, "Ptr", &pJson, "Ptr", &pResult , "CDecl Int")) || ErrorLevel
 		{
 			throw Exception("Failed to parse JSON (" r "," ErrorLevel ")", -1
 			, Format("Unexpected character at position {}: '{}'"
 			, (NumGet(pJson)-&_json)//2, Chr(NumGet(NumGet(pJson), "short"))))
 		}
 
 		result := ComObject(0x400C, &pResult)[]
 		if (IsObject(result))
 			ObjRelease(&result)
 		return result
 	}
 
 	True[]
 	{
 		get
 		{
 			static _ := {"value": true, "name": "true"}
 			return _
 		}
 	}
 
 	False[]
 	{
 		get
 		{
 			static _ := {"value": false, "name": "false"}
 			return _
 		}
 	}
 
 	Null[]
 	{
 		get
 		{
 			static _ := {"value": "", "name": "null"}
 			return _
 		}
 	}
 }
 
 


 ; License:

  ; MIT License
  ; 
  ; Copyright (c) 2021 Philip Taylor
  ; 
  ; Permission is hereby granted, free of charge, to any person obtaining a copy
  ; of this software and associated documentation files (the "Software"), to deal
  ; in the Software without restriction, including without limitation the rights
  ; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  ; copies of the Software, and to permit persons to whom the Software is
  ; furnished to do so, subject to the following conditions:
  ; 
  ; The above copyright notice and this permission notice shall be included in all
  ; copies or substantial portions of the Software.
  ; 
  ; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  ; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  ; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  ; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  ; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  ; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  ; SOFTWARE.
  ; 

; --uID:1923497277

