; $Id$
; Copyright 2013, 2018 Siep Kroonenberg
; This file is licensed under the GNU General Public License version 2
; or any later version.
;
; This nsi script is used by tl-update-install-pkg to make
; install-tl-windows.exe.

!include nsDialogs.nsh
!include WinVer.nsh
; !include LogicLib.nsh ; already loaded by either of the above

!include "FileFunc.nsh"

!macro NSD_SetUserData hwnd data
  nsDialogs::SetUserData ${hwnd} ${data}
!macroend
!define NSD_SetUserData `!insertmacro NSD_SetUserData`

!macro NSD_GetUserData hwnd outvar
  nsDialogs::GetUserData ${hwnd}
  Pop ${outvar}
!macroend
!define NSD_GetUserData `!insertmacro NSD_GetUserData`

!include tlsubdir.nsh ; generated by tl-update-install-pkg

Name "TeX Live Installer ${YYYYMMDD}"
OutFile install-tl-windows.exe

Caption "TeX Live installer"
SubCaption 2 ": Unpack directory"
SubCaption 4 ": Unpacking..."

XPStyle on
RequestExecutionLevel user

; With this compressor, 7zip can unpack the exe
SetCompressor /SOLID bzip2

; Controls: installation type
Var Dialog
Var Label
Var RadioSimple
Var RadioUnpack

; Controls: confirmation page
Var Confirm
Var Explain

; values for installation type
Var Radio_Value
Var Radio_Default
Var Radio_Temp

Var Admin_warning
Var Completed_text
CompletedText $Completed_text
Var InstOrUnpack

; parameters to nsis installer are passed along to install-tl-windows.bat
Var PARMS

Page custom tlOptionsPage tlOptionsPageLeave
Page directory dirPre "" dirLeave
Page custom ConfirmPage ConfirmLeave
Page instfiles

Function .onInit

  ${If} ${AtMostWin2003}
    MessageBox MB_OK|MB_ICONSTOP \
      "Windows Vista earliest supported version; aborting..."
    Abort
  ${EndIf}

  InitPluginsDir
  StrCpy $INSTDIR $PLUGINSDIR

  UserInfo::GetAccountType
  Pop $0
  ${If} $0 == "Admin"
    StrCpy $Admin_warning ""
  ${Else} ; failure or no admin permissions
    StrCpy $Admin_warning "Only single-user install possible.$\r$\nFor an all-users installation, abort now and re-run as administrator.$\r$\n"
  ${EndIf}

  StrCpy $Radio_Default "simple"
  StrCpy $Radio_Value $Radio_Default
  ;StrCpy $NextOrUnpack "Next"

FunctionEnd

Function dirPre

  ${If} $Radio_Value != "unpack"
    Abort
  ${EndIf}

FunctionEnd

Function dirLeave

  Push $0

  ${DirState} "$INSTDIR\${INST_TL_NAME}" $0
  ${If} $0 == 1
    MessageBox MB_YESNO \
        "OK to replace contents of $INSTDIR\${INST_TL_NAME}?" \
        IDYES continue
    Abort
    continue:
    RMDir /r "$INSTDIR\${INST_TL_NAME}"
  ${EndIf}

  Pop $0

FunctionEnd

DirText "Directory to unpack the TeX Live installer"

Function tlOptionsPage

 nsDialogs::Create 1018
 Pop $Dialog

 ${If} $Dialog == error
  Abort
 ${EndIf}


 ${NSD_CreateLabel} 0 0 100% 24u $Admin_warning
 Pop $Label

 ${NSD_CreateRadioButton} 0 45u 100% 9u "Install"
 Pop $RadioSimple
 ${NSD_SetUserData} $RadioSimple $Radio_Default ; set to "simple" in .onInit

 ${NSD_CreateRadioButton} 0 75u 100% 9u "Unpack only"
 Pop $RadioUnpack
 ${NSD_SetUserData} $RadioUnpack "unpack"

 Call Value_to_States

 ${NSD_OnClick} $RadioSimple UpdateRadio
 ${NSD_OnClick} $RadioUnpack UpdateRadio

 nsDialogs::Show

FunctionEnd

Function tlOptionsPageLeave

  Call Value_to_States
  ${If} $Radio_Value == "unpack"
    StrCpy $INSTDIR "$DESKTOP"
    StrCpy $Completed_text \
      "Done unpacking; next run install-tl-windows.bat."
    StrCpy $InstOrUnpack "Unpack"
    ;StrCpy $NextOrUnpack "Next"
  ${Else}
    StrCpy $Completed_text "Completed"
    StrCpy $InstOrUnpack "Install"
    ;StrCpy $NextOrUnpack "Unpack"
  ${EndIf}

FunctionEnd

Function Value_to_States

  ${NSD_Uncheck} $RadioSimple
  ${NSD_Uncheck} $RadioUnpack
  ${NSD_GetUserData} $RadioSimple $Radio_Temp
  ${If} $Radio_Temp == $Radio_Value
    ${NSD_Check} $RadioSimple
  ${EndIf}
  ${NSD_GetUserData} $RadioUnpack $Radio_Temp
  ${If} $Radio_Temp == $Radio_Value
    ${NSD_Check} $RadioUnpack
  ${EndIf}

FunctionEnd

Function UpdateRadio

  Pop $1
  ${NSD_GetUserData} $1 $Radio_Value

FunctionEnd

Function ConfirmPage

  ;${If} $Radio_Value == "unpack"
  ;  Abort
  ;${EndIf}

  nsDialogs::Create 1018
  Pop $Confirm

  ${If} $Confirm == error
   Abort
  ${EndIf}

  ${If} $Radio_Value == "unpack"
    ${NSD_CreateLabel} 0 30% 100% 80u \
      "The main installer will be unpacked into $INSTDIR\${INST_TL_NAME}.$\r$\n$\r$\nStart the main installer with install-tl-windows.bat."
  ${Else}
    ${NSD_CreateLabel} 0 30% 100% 80u \
      "Click 'Install' to start the main installer,$\r$\nwhich lets you select components and an installation directory.$\r$\n$\r$\nUnpacking the main installer may take a few moments..."
  ${EndIf}
  Pop $Explain

  nsDialogs::Show

FunctionEnd

Function ConfirmLeave

FunctionEnd

Section

  ${GetParameters} $PARMS
  ${If} $PARMS != ""
    DetailPrint $PARMS
  ${EndIf}

  ; Detailprint $Radio_Value
  ${If} $Radio_Value == "unpack"
    SetOutPath $INSTDIR
  ${Else}
    ; nsis uses $PLUGINSDIR for temporary files which will be
    ; automatically cleared afterwards
    SetOutPath $PLUGINSDIR
  ${EndIf}

  CreateDirectory $INSTDIR\${INST_TL_NAME}

  ; Quick interface testing:
  ; File /oname=${INST_TL_NAME}\README ${INST_TL_NAME}\README
  ; production code:
  File /r ${INST_TL_NAME}

  ${If} $Radio_Value == "simple"
    ; create a copy of install-tl-windows.bat which exits with an exit code
    Push $0
    File /oname=${INST_TL_NAME}\inst_mod.bat ${INST_TL_NAME}\install-tl-windows.bat
    FileOpen $0 ${INST_TL_NAME}\inst_mod.bat a
    FileSeek $0 0 END
    FileWrite $0 "if errorlevel 1 (exit 1) else (exit 0)"
    FileClose $0
    Pop $0
    DetailPrint "Starting the main installer:"
    DetailPrint '"$INSTDIR\${INST_TL_NAME}\inst_mod.bat" $PARMS'
    nsExec::ExecToLog '"$INSTDIR\${INST_TL_NAME}\inst_mod.bat" $PARMS'
    Pop $0
    ${If} $0 == "error"
      MessageBox MB_ICONSTOP|MB_OK "Error; see details"
    ${ElseIf} $0 == "timeout"
      MessageBox MB_ICONSTOP|MB_OK "Timeout"
    ${ElseIf} $0 <> 0
      MessageBox MB_ICONSTOP|MB_OK "Error; for better info, unpack,$\r$\nthen run install-tl-windows.bat."
    ; ${Else}
      ; MessageBox MB_ICONSTOP|MB_OK "No error"
    ${EndIf}
  ${EndIf}
SectionEnd
