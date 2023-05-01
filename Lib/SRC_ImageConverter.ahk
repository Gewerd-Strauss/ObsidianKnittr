ConvertSRC_SYNTAX_V4(PathOrContent,bInsertSetupChunk,bRemoveObsidianHTMLErrors) {
    if (FileExist(PathOrContent)) {
        Current_FileEncoding:=A_FileEncoding
        FileEncoding, UTF-8
        FileRead buffer, % PathOrContent
        FileEncoding, % Current_FileEncoding
    }
    else {
        buffer := PathOrContent
    }
    p := 1
    regex = <img src="(?<SRC>.+)" width="(?<WIDTH>\d*)" alt="(?<ALT>.*)" title="(?<TITLE>.*)" \/>
    while (p := RegExMatch(buffer, "iOU)" regex, match, p)) {
        options := ""
        src := DecodeUriComponent(match.src)
        if (match.width) {
            options .= "out.width='" match.width "', "
        }
        if (match.alt) {
            options .= "fig.cap='" Clean(match.alt) "', "
        }
        if (match.title) {
            options .= "fig.title='" Clean(match.title) "', "
        }
        options := RTrim(options, ", ") ;; TODO: src and others may contain faulty strings when converting umlaute
        if InStr(src,"../") {
            src:=StrReplace(src,"../")
        }
        tpl =
        (LTrim

            ``````{r, echo=FALSE, %options%}
            knitr::include_graphics("%src%")
            ``````

        )
        buffer:=RegexReplace(buffer,"<figcaption>" Clean(match.alt) "</figcaption>","") ;; 09.03.2023 - required for removing the new figure syntax.
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
    if bInsertSetupChunk {
        buffer := RegExReplace(buffer, "\n---", "`n" tpl,,1,1) ;; 09.03.2023 - required for removing the new figure syntax
    }
    buffer:=Regexreplace(buffer,"<figure>","") ;; 09.03.2023 - required for removing the new figure syntax
    buffer:=Regexreplace(buffer,"</figure>","") ;; 09.03.2023 - required for removing the new figure syntax
    buffer:=Regexreplace(buffer,"\<figcaption\>.*<\/figcaption\>","") ;; 01.05.2023  bugfix for syntax '![[200 University/04/BE22 Bioinformatics/Task 7 Phylogenetic Tree/GuideTree (actual Phylotree).png|Phylogenetic Tree of the sequences mentioned in [Similar sequences] ]]' - required for removing the new figure syntax
    if (bRemoveObsidianHTMLErrors) {
        matches:=RegexMatchAll(buffer,"m)(((\<|\>)\s*\**obsidian-html error:\**.*)|(Obsidianhtml.*))$")
        for _, match in matches {
            ned:=match[0]
            buffer:=StrReplace(buffer, ned) ;; why does this not work?
            if (Instr(buffer, ned)) {
                if DEBUG {
                    msgbox, % (Instr(buffer, ned))
                }
            }
        }
    }
    if DEBUG {

        Clipboard:=buffer
    }
    return buffer
}

Clean(sText) {
    sText := _Decode(sText, 1)
    sText := StrReplace(sText, "'", "\'")
    return sText
}

DecodeUriComponent(sText) {
    return _Decode(sText, 2)
}

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
; Dependencies: cJSON.ahk (not in this project)
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

