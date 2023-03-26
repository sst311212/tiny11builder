@echo off
pushd "%~dp0"
chcp 65001 > NUL

set WorkDir=%SystemDrive%\Tiny11_tmp
set InstDir=%WorkDir%\files
set TinyDir=%WorkDir%\scratch

set /p DriveLetter=Please enter image's drive letter:
if not exist "%DriveLetter%:\sources\boot.wim" goto :InvalidDriveLetter
if not exist "%DriveLetter%:\sources\install.wim" goto :InvalidDriveLetter

md "%InstDir%"
echo Copying installation files...
xcopy "%DriveLetter%:\" "%InstDir%" /E /I /H /R /Y /J > NUL
dism /Get-ImageInfo /ImageFile:"%InstDir%\sources\install.wim"
set /p Index=Please enter image's index:

md "%TinyDir%"
echo Mounting install image...
dism /Mount-Image /ImageFile:"%InstDir%\sources\install.wim" /Index:%Index% /MountDir:"%TinyDir%"
call :ShowResult

echo Removing Edge...
call :ForceRemove "%TinyDir%\Program Files (x86)\Microsoft\Edge"
call :ForceRemove "%TinyDir%\Program Files (x86)\Microsoft\EdgeUpdate"
call :ForceRemove "%TinyDir%\Windows\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe"
call :ForceRemove "%TinyDir%\Windows\SystemApps\Microsoft.MicrosoftEdgeDevToolsClient_8wekyb3d8bbwe"
echo Removing Internet Explorer...
call :ForceRemove "%TinyDir%\Program Files\Internet Explorer"
call :ForceRemove "%TinyDir%\Program Files (x86)\Internet Explorer"
echo Removing OneDrive...
call :ForceRemove "%TinyDir%\Windows\System32\OneDriveSetup.exe"
echo Removing Clipchamp...
call :RemoveAppxPackage "%TinyDir%" "Clipchamp.Clipchamp"
echo Removing Cortana...
call :RemoveAppxPackage "%TinyDir%" "Microsoft.549981C3F5F10"
echo Removing News...
call :RemoveAppxPackage "%TinyDir%" "Microsoft.BingNews"
echo Removing Weather...
call :RemoveAppxPackage "%TinyDir%" "Microsoft.BingWeather"
echo Removing Xbox...
call :RemoveAppxPackage "%TinyDir%" "Microsoft.GamingApp"
echo Removing GetHelp...
call :RemoveAppxPackage "%TinyDir%" "Microsoft.GetHelp"
echo Removing GetStarted...
call :RemoveAppxPackage "%TinyDir%" "Microsoft.Getstarted"
echo Removing Office Hub...
call :RemoveAppxPackage "%TinyDir%" "Microsoft.MicrosoftOfficeHub"
echo Removing Solitaire...
call :RemoveAppxPackage "%TinyDir%" "Microsoft.MicrosoftSolitaireCollection"
echo Removing PeopleApp...
call :RemoveAppxPackage "%TinyDir%" "Microsoft.People"
echo Removing PowerAutomate...
call :RemoveAppxPackage "%TinyDir%" "Microsoft.PowerAutomateDesktop"
echo Removing ToDo...
call :RemoveAppxPackage "%TinyDir%" "Microsoft.Todos"
echo Removing Alarms...
call :RemoveAppxPackage "%TinyDir%" "Microsoft.WindowsAlarms"
echo Removing Mail...
call :RemoveAppxPackage "%TinyDir%" "microsoft.windowscommunicationsapps"
echo Removing Feedback Hub...
call :RemoveAppxPackage "%TinyDir%" "Microsoft.WindowsFeedbackHub"
echo Removing Maps...
call :RemoveAppxPackage "%TinyDir%" "Microsoft.WindowsMaps"
echo Removing Sound Recorder...
call :RemoveAppxPackage "%TinyDir%" "Microsoft.WindowsSoundRecorder"
echo Removing XboxTCUI...
call :RemoveAppxPackage "%TinyDir%" "Microsoft.Xbox.TCUI"
echo Removing XboxGamingOverlay...
call :RemoveAppxPackage "%TinyDir%" "Microsoft.XboxGameOverlay"
echo Removing XboxGameOverlay...
call :RemoveAppxPackage "%TinyDir%" "Microsoft.XboxGamingOverlay"
echo Removing XboxSpeechToTextOverlay...
call :RemoveAppxPackage "%TinyDir%" "Microsoft.XboxSpeechToTextOverlay"
echo Removing Your Phone...
call :RemoveAppxPackage "%TinyDir%" "Microsoft.YourPhone"
echo Removing Music...
call :RemoveAppxPackage "%TinyDir%" "Microsoft.ZuneMusic"
echo Removing Video...
call :RemoveAppxPackage "%TinyDir%" "Microsoft.ZuneVideo"
echo Removing Family...
call :RemoveAppxPackage "%TinyDir%" "MicrosoftCorporationII.MicrosoftFamily"
echo Removing QuickAssist...
call :RemoveAppxPackage "%TinyDir%" "MicrosoftCorporationII.QuickAssist"
echo Removing Teams...
call :RemoveAppxPackage "%TinyDir%" "MicrosoftTeams"
echo Removing Widget...
call :RemoveAppxPackage "%TinyDir%" "MicrosoftWindows.Client.WebExperience"
echo Removing Internet Explorer...
call :RemovePackage "%TinyDir%" "InternetExplorer"
echo Removing LA57...
call :RemovePackage "%TinyDir%" "Kernel-LA57"
echo Removing Handwriting...
call :RemovePackage "%TinyDir%" "LanguageFeatures-Handwriting"
echo Removing OCR...
call :RemovePackage "%TinyDir%" "LanguageFeatures-OCR"
echo Removing Speech...
call :RemovePackage "%TinyDir%" "LanguageFeatures-Speech"
echo Removing TTS...
call :RemovePackage "%TinyDir%" "LanguageFeatures-TextToSpeech"
echo Removing Media Player Legacy...
call :RemovePackage "%TinyDir%" "MediaPlayer"
echo Removing Tablet PC Math...
call :RemovePackage "%TinyDir%" "TabletPCMath"
echo Removing Wallpapers...
call :RemovePackage "%TinyDir%" "Wallpaper"
call :ShowResult

echo Applying Tweaks
call :ApplyTweak install_patches.reg
call :ShowResult

echo Cleaning install image...
dism /Image:"%TinyDir%" /Cleanup-Image /StartComponentCleanup /ResetBase
echo Unmounting install image...
dism /Unmount-Image /MountDir:"%TinyDir%" /Commit
echo Exporting install image...
dism /Export-Image /SourceImageFile:"%InstDir%\sources\install.wim" /SourceIndex:%Index% /DestinationImageFile:"%InstDir%\sources\install2.wim" /Compress:max
del "%InstDir%\sources\install.wim"
ren "%InstDir%\sources\install2.wim" install.wim
call :ShowResult

echo Mounting boot image...
dism /Mount-Image /ImageFile:"%InstDir%\sources\boot.wim" /Index:2 /MountDir:"%TinyDir%"
echo Applying Tweaks
call :ApplyTweak boot_patches.reg
echo Unmounting boot image...
dism /Unmount-Image /MountDir:"%TinyDir%" /Commit
call :ShowResult

echo Creating ISO image...
copy autounattend.xml "%InstDir%\autounattend.xml"
oscdimg.exe -m -o -u2 -udfver102 -bootdata:2#p0,e,b"%InstDir%\boot\etfsboot.com"#pEF,e,b"%InstDir%\efi\microsoft\boot\efisys.bin" "%InstDir%" tiny11.iso
echo Performing Cleanup...
rmdir /S /Q "%WorkDir%"
echo Done!
pause
exit

:InvalidDriveLetter
echo Can not find Windows 11 installation files in specified drive letter.
echo.
echo Please enter the correct drive letter.
timeout 10 /NOBREAK > NUL
exit /B

:ShowResult
echo Done!
timeout 3 /NOBREAK > NUL
cls
exit /B

:ForceRemove
if exist "%~1\" (
  takeown /f "%~1" /R > NUL
  icacls "%~1" /grant Users:F /T /C > NUL
  rmdir /S /Q "%~1"
) else (
  takeown /f "%~1" > NUL
  icacls "%~1" /grant Users:F /C > NUL
  erase /F /Q "%~1"
)
exit /B

:RemoveAppxPackage
for /f "usebackq tokens=3 delims= " %%i in (`dism /Image:"%~1" /Get-ProvisionedAppxPackages ^| findstr PackageName ^| findstr "%~2"`) do (
  if not "%%i"=="" dism /Image:"%~1" /Remove-ProvisionedAppxPackage /PackageName:%%i > NUL
)
exit /B

:RemovePackage
for /f "usebackq tokens=4 delims= " %%i in (`dism /Image:"%~1" /Get-Packages ^| findstr Identity ^| findstr "%~2"`) do (
  if not "%%i"=="" dism /Image:"%~1" /Remove-Package /PackageName:%%i > NUL
)
exit /B

:ApplyTweak
echo Loading Hives...
reg LOAD HKLM\zDEFAULT "%TinyDir%\Windows\System32\config\DEFAULT"
reg LOAD HKLM\zNTUSER "%TinyDir%\Users\Default\NTUSER.DAT"
reg LOAD HKLM\zSOFTWARE "%TinyDir%\Windows\System32\config\SOFTWARE"
reg LOAD HKLM\zSYSTEM "%TinyDir%\Windows\System32\config\SYSTEM"
echo Patching registry...
reg IMPORT "%~1"
echo Unloading Hives...
reg UNLOAD HKLM\zDEFAULT
reg UNLOAD HKLM\zNTUSER
reg UNLOAD HKLM\zSOFTWARE
reg UNLOAD HKLM\zSYSTEM
echo Applying unattend file...
dism /Image:%TinyDir% /Apply-Unattend:autounattend.xml > NUL
exit /B
