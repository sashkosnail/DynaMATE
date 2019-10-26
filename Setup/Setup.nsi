!define PRODUCT_NAME "DynaMate"
!define PRODUCT_VERSION "1.75"
!define PRODUCT_PUBLISHER "Western University"
!define UNINSTALL_PATH "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!include "UninstallLog.nsh"

;--------------------------------
; Configure UnInstall log to only remove what is installed
;-------------------------------- 
  ;Set the name of the uninstall log
    !define UninstLog "uninstall.log"
    Var UninstLog
  ;The root registry to write to
    !define REG_ROOT "HKLM"
  ;The registry path to write to
    !define REG_APP_PATH "SOFTWARE\${PRODUCT_NAME}"
 
  ;Uninstall log file missing.
    LangString UninstLogMissing 1033 "${UninstLog} not found!$\r$\nUninstallation cannot proceed!"
 
  ;AddItem macro
    !define AddItem "!insertmacro AddItem"
 
  ;BackupFile macro
    !define BackupFile "!insertmacro BackupFile" 
 
  ;BackupFiles macro
    !define BackupFiles "!insertmacro BackupFiles" 
 
  ;Copy files macro
    !define CopyFiles "!insertmacro CopyFiles"
 
  ;CreateDirectory macro
    !define CreateDirectory "!insertmacro CreateDirectory"
 
  ;CreateShortcut macro
    !define CreateShortcut "!insertmacro CreateShortcut"
 
  ;File macro
    !define File "!insertmacro File"
 
  ;Rename macro
    !define Rename "!insertmacro Rename"
 
  ;RestoreFile macro
    !define RestoreFile "!insertmacro RestoreFile"    
 
  ;RestoreFiles macro
    !define RestoreFiles "!insertmacro RestoreFiles"
 
  ;SetOutPath macro
    !define SetOutPath "!insertmacro SetOutPath"
 
  ;WriteRegDWORD macro
    !define WriteRegDWORD "!insertmacro WriteRegDWORD" 
 
  ;WriteRegStr macro
    !define WriteRegStr "!insertmacro WriteRegStr"
 
  ;WriteUninstaller macro
    !define WriteUninstaller "!insertmacro WriteUninstaller"
 
  Section -openlogfile
    CreateDirectory "$INSTDIR"
    IfFileExists "$INSTDIR\${UninstLog}" +3
      FileOpen $UninstLog "$INSTDIR\${UninstLog}" w
    Goto +4
      SetFileAttributes "$INSTDIR\${UninstLog}" NORMAL
      FileOpen $UninstLog "$INSTDIR\${UninstLog}" a
      FileSeek $UninstLog 0 END
  SectionEnd
 
SetCompressor zlib

Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles
 
Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "DynaMate1.75.exe"
InstallDir "$LOCALAPPDATA\DynaMate"
ShowInstDetails show
 
; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
InstallDirRegKey HKLM "Software\${PRODUCT_NAME}" "Install_Dir"

Section -SETTINGS
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
SectionEnd
 
Section -Redist
  SetRebootFlag false
  MessageBox MB_YESNO "Install Labview Runtime? The installer will ask you to reboot. Please say no to this reboot request. We will prompt you after installing all the other applications." /SD IDYES IDNO endLabview
    ExecWait "Redist\LabViewRuntime\setup.exe"
    SetRebootFlag true
    Goto endLabview
  endLabview:
  MessageBox MB_YESNO "Install NI-DAQmx Runtime? The installer will ask you to reboot. Please say no to this reboot request. We will prompt you after installing all the other applications." /SD IDYES IDNO endDAQmx
    ExecWait "Redist\NI-DAQmx Runtime\setup.exe"
    SetRebootFlag true
    Goto endDAQmx
  endDAQmx:
  MessageBox MB_YESNO "Install Matlab Runtime" /SD IDYES IDNO endMatlab
    ExecWait "Redist\MCR_R2017a_win64_installer.exe"
    Goto endMatlab
  endMatlab:
  MessageBox MB_YESNO "Install TDMS Excel Plug-In" /SD IDYES IDNO endTDMSExcell
    ;${File} "Redist\NI-TDM_Excel_Add-In\setup.exe"
    ExecWait "Redist\NI-TDM_Excel_Add-In\setup.exe"
    Goto endTDMSExcell
  endTDMSExcell:
SectionEnd

Section DynaMate
  SetOutPath $INSTDIR
  ${File} "DynaMate.exe"
  ${File} "DYNAMateProcess.exe"
  ${File} "DynaMate.aliases"
  ${File} "Settings.xml"
  ${File} "splash.png"
  ${File} "DynaMate Manual.pdf"
  ${File} "*.cfg"
  ${File} "*.csv"
  ${File} "*.dll"
  ${File} "*.ini"
  ${File} "*.ico" 


  ; Write the installation path into the registry
  ${WriteRegStr} HKLM SOFTWARE\${PRODUCT_NAME} "Install_Dir" "$INSTDIR"
  
  ; Write the uninstall keys for Windows
  ${WriteRegStr} HKLM ${UNINSTALL_PATH} "DisplayName" "${PRODUCT_NAME} ${PRODUCT_VERSION}"
  ${WriteRegStr} HKLM ${UNINSTALL_PATH} "UninstallString" "$INSTDIR\uninstall.exe"
  ${WriteRegDWORD} HKLM ${UNINSTALL_PATH} "NoModify" 1
  ${WriteRegDWORD} HKLM ${UNINSTALL_PATH} "NoRepair" 1
  ${WriteUninstaller} "$INSTDIR\uninstall.exe"
SectionEnd

; Optional section (can be disabled by the user)
Section "Start Menu Shortcuts"

  ${CreateDirectory} "$STARTMENU\${PRODUCT_NAME}"
  ${CreateShortcut} "$STARTMENU\${PRODUCT_NAME}\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  ${CreateShortcut} "$STARTMENU\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk" "$INSTDIR\${PRODUCT_NAME}.exe" "" "$INSTDIR\${PRODUCT_NAME}.exe" 0
  ${CreateShortcut} "$STARTMENU\${PRODUCT_NAME}\${PRODUCT_NAME}Process.lnk" "$INSTDIR\${PRODUCT_NAME}Process.exe" "" "$INSTDIR\${PRODUCT_NAME}Process.exe" 0
  ${CreateShortcut} "$STARTMENU\${PRODUCT_NAME}\${PRODUCT_NAME} Manual.lnk" "$INSTDIR\${PRODUCT_NAME} Manual.pdf" "" "$INSTDIR\${PRODUCT_NAME} Manual.pdf" 0
  
SectionEnd

Section Reboot
IfRebootFlag 0 SKIP
MessageBox MB_YESNO|MB_ICONQUESTION "Do you wish to reboot the system?" IDNO SKIP
  Reboot
SKIP:
SectionEnd

;--------------------------------
; Uninstaller
;--------------------------------
Section Uninstall
  ;Can't uninstall if uninstall log is missing!
  IfFileExists "$INSTDIR\${UninstLog}" +3
    MessageBox MB_OK|MB_ICONSTOP "$(UninstLogMissing)"
      Abort
 
  Push $R0
  Push $R1
  Push $R2
  SetFileAttributes "$INSTDIR\${UninstLog}" NORMAL
  FileOpen $UninstLog "$INSTDIR\${UninstLog}" r
  StrCpy $R1 -1
 
  GetLineCount:
    ClearErrors
    FileRead $UninstLog $R0
    IntOp $R1 $R1 + 1
    StrCpy $R0 $R0 -2
    Push $R0   
    IfErrors 0 GetLineCount
 
  Pop $R0
 
  LoopRead:
    StrCmp $R1 0 LoopDone
    Pop $R0
 
    IfFileExists "$R0\*.*" 0 +3
      RMDir $R0  #is dir
    Goto +9
    IfFileExists $R0 0 +3
      Delete $R0 #is file
    Goto +6
    StrCmp $R0 "${REG_ROOT} ${REG_APP_PATH}" 0 +3
      DeleteRegKey ${REG_ROOT} "${REG_APP_PATH}" #is Reg Element
    Goto +3
    StrCmp $R0 "${REG_ROOT} ${UNINSTALL_PATH}" 0 +2
      DeleteRegKey ${REG_ROOT} "${UNINSTALL_PATH}" #is Reg Element
 
    IntOp $R1 $R1 - 1
    Goto LoopRead
  LoopDone:
  FileClose $UninstLog
  Delete "$INSTDIR\${UninstLog}"
  RMDir "$INSTDIR"
  Pop $R2
  Pop $R1
  Pop $R0
 
  ;Remove registry keys
    ;DeleteRegKey ${REG_ROOT} "${REG_APP_PATH}"
    ;DeleteRegKey ${REG_ROOT} "${UNINSTALL_PATH}"
SectionEnd