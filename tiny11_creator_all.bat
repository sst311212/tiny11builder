@echo off
chcp 65001 > NUL
setlocal EnableExtensions EnableDelayedExpansion

title tiny11 builder alpha
echo Welcome to the tiny11 image creator!
timeout /t 3 /nobreak > nul
cls

set DriveLetter=
set /p DriveLetter=Please enter the drive letter for the Windows 11 image: 
set "DriveLetter=%DriveLetter%:"
echo.
if not exist "%DriveLetter%\sources\boot.wim" (
	echo.Can't find Windows OS Installation files in the specified Drive Letter..
	echo.
	echo.Please enter the correct DVD Drive Letter..
	goto :Stop
)

if not exist "%DriveLetter%\sources\install.wim" (
	echo.Can't find Windows OS Installation files in the specified Drive Letter..
	echo.
	echo.Please enter the correct DVD Drive Letter..
	goto :Stop
)
md c:\tiny11
echo Copying Windows image...
xcopy.exe /E /I /H /R /Y /J %DriveLetter% c:\tiny11 >nul
echo Copy complete!
sleep 2
cls
echo Getting image information:
dism /Get-WimInfo /wimfile:c:\tiny11\sources\install.wim
set index=
set /p index=Please enter the image index:
set "index=%index%"
echo Mounting Windows image. This may take a while.
echo.
md c:\scratchdir
dism /mount-image /imagefile:c:\tiny11\sources\install.wim /index:%index% /mountdir:c:\scratchdir
echo Mounting complete! Performing removal of applications...
echo Removing Clipchamp...
call :RemoveAppxPackage "c:\scratchdir" "Clipchamp.Clipchamp"
echo Removing Cortana...
call :RemoveAppxPackage "c:\scratchdir" "Microsoft.549981C3F5F10"
echo Removing News...
call :RemoveAppxPackage "c:\scratchdir" "Microsoft.BingNews"
echo Removing Weather...
call :RemoveAppxPackage "c:\scratchdir" "Microsoft.BingWeather"
echo Removing Xbox...
call :RemoveAppxPackage "c:\scratchdir" "Microsoft.GamingApp"
echo Removing GetHelp...
call :RemoveAppxPackage "c:\scratchdir" "Microsoft.GetHelp"
echo Removing GetStarted...
call :RemoveAppxPackage "c:\scratchdir" "Microsoft.Getstarted"
echo Removing Office Hub...
call :RemoveAppxPackage "c:\scratchdir" "Microsoft.MicrosoftOfficeHub"
echo Removing Solitaire...
call :RemoveAppxPackage "c:\scratchdir" "Microsoft.MicrosoftSolitaireCollection"
echo Removing PeopleApp...
call :RemoveAppxPackage "c:\scratchdir" "Microsoft.People"
echo Removing PowerAutomate...
call :RemoveAppxPackage "c:\scratchdir" "Microsoft.PowerAutomateDesktop"
echo Removing ToDo...
call :RemoveAppxPackage "c:\scratchdir" "Microsoft.Todos"
echo Removing Alarms...
call :RemoveAppxPackage "c:\scratchdir" "Microsoft.WindowsAlarms"
echo Removing Mail...
call :RemoveAppxPackage "c:\scratchdir" "microsoft.windowscommunicationsapps"
echo Removing Feedback Hub...
call :RemoveAppxPackage "c:\scratchdir" "Microsoft.WindowsFeedbackHub"
echo Removing Maps...
call :RemoveAppxPackage "c:\scratchdir" "Microsoft.WindowsMaps"
echo Removing Sound Recorder...
call :RemoveAppxPackage "c:\scratchdir" "Microsoft.WindowsSoundRecorder"
echo Removing XboxTCUI...
call :RemoveAppxPackage "c:\scratchdir" "Microsoft.Xbox.TCUI"
echo Removing XboxGamingOverlay...
call :RemoveAppxPackage "c:\scratchdir" "Microsoft.XboxGameOverlay"
echo Removing XboxGameOverlay...
call :RemoveAppxPackage "c:\scratchdir" "Microsoft.XboxGamingOverlay"
echo Removing XboxSpeechToTextOverlay...
call :RemoveAppxPackage "c:\scratchdir" "Microsoft.XboxSpeechToTextOverlay"
echo Removing Your Phone...
call :RemoveAppxPackage "c:\scratchdir" "Microsoft.YourPhone"
echo Removing Music...
call :RemoveAppxPackage "c:\scratchdir" "Microsoft.ZuneMusic"
echo Removing Video...
call :RemoveAppxPackage "c:\scratchdir" "Microsoft.ZuneVideo"
echo Removing Family...
call :RemoveAppxPackage "c:\scratchdir" "MicrosoftCorporationII.MicrosoftFamily"
echo Removing QuickAssist...
call :RemoveAppxPackage "c:\scratchdir" "MicrosoftCorporationII.QuickAssist"
echo Removing Teams...
call :RemoveAppxPackage "c:\scratchdir" "MicrosoftTeams"
echo Removing Widget...
call :RemoveAppxPackage "c:\scratchdir" "MicrosoftWindows.Client.WebExperience"

echo Removing of system apps complete! Now proceeding to removal of system packages...
timeout /t 1 /nobreak > nul
cls
echo Removing Internet Explorer...
call :RemovePackage "c:\scratchdir" "InternetExplorer"
echo Removing LA57:
call :RemovePackage "c:\scratchdir" "Kernel-LA57"
echo Removing Handwriting:
call :RemovePackage "c:\scratchdir" "LanguageFeatures-Handwriting"
echo Removing OCR:
call :RemovePackage "c:\scratchdir" "LanguageFeatures-OCR"
echo Removing Speech:
call :RemovePackage "c:\scratchdir" "LanguageFeatures-Speech"
echo Removing TTS:
call :RemovePackage "c:\scratchdir" "LanguageFeatures-TextToSpeech"
echo Removing Media Player Legacy:
call :RemovePackage "c:\scratchdir" "MediaPlayer"
echo Removing Tablet PC Math:
call :RemovePackage "c:\scratchdir" "TabletPCMath"
echo Removing Wallpapers:
call :RemovePackage "c:\scratchdir" "Wallpaper"

echo Removing Edge:
rd "C:\scratchdir\Program Files (x86)\Microsoft\Edge" /s /q
rd "C:\scratchdir\Program Files (x86)\Microsoft\EdgeUpdate" /s /q
echo Removing OneDrive:
takeown /f C:\scratchdir\Windows\System32\OneDriveSetup.exe
icacls C:\scratchdir\Windows\System32\OneDriveSetup.exe /grant Administrators:F /T /C
del /f /q /s "C:\scratchdir\Windows\System32\OneDriveSetup.exe"
echo Removal complete!
timeout /t 2 /nobreak > nul
cls
echo Loading registry...
reg load HKLM\zCOMPONENTS "c:\scratchdir\Windows\System32\config\COMPONENTS" >nul
reg load HKLM\zDEFAULT "c:\scratchdir\Windows\System32\config\default" >nul
reg load HKLM\zNTUSER "c:\scratchdir\Users\Default\ntuser.dat" >nul
reg load HKLM\zSOFTWARE "c:\scratchdir\Windows\System32\config\SOFTWARE" >nul
reg load HKLM\zSYSTEM "c:\scratchdir\Windows\System32\config\SYSTEM" >nul
echo Bypassing system requirements(on the system image):
			Reg add "HKLM\zDEFAULT\Control Panel\UnsupportedHardwareNotificationCache" /v "SV1" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zDEFAULT\Control Panel\UnsupportedHardwareNotificationCache" /v "SV2" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zNTUSER\Control Panel\UnsupportedHardwareNotificationCache" /v "SV1" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zNTUSER\Control Panel\UnsupportedHardwareNotificationCache" /v "SV2" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassCPUCheck" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassRAMCheck" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassSecureBootCheck" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassStorageCheck" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassTPMCheck" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\MoSetup" /v "AllowUpgradesWithUnsupportedTPMOrCPU" /t REG_DWORD /d "1" /f >nul 2>&1
echo Disabling Teams:
Reg add "HKLM\zSOFTWARE\Microsoft\Windows\CurrentVersion\Communications" /v "ConfigureChatAutoInstall" /t REG_DWORD /d "0" /f >nul 2>&1
echo Disabling Sponsored Apps:
Reg add "HKLM\zNTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "OemPreInstalledAppsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zNTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zNTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zSOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSOFTWARE\Microsoft\PolicyManager\current\device\Start" /v "ConfigureStartPins" /t REG_SZ /d "{\"pinnedList\": [{}]}" /f >nul 2>&1
echo Enabling Local Accounts on OOBE:
Reg add "HKLM\zSOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "BypassNRO" /t REG_DWORD /d "1" /f >nul 2>&1
copy /y %~dp0autounattend.xml c:\scratchdir\Windows\System32\Sysprep\autounattend.xml
echo Disabling Reserved Storage:
Reg add "HKLM\zSOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager" /v "ShippedWithReserves" /t REG_DWORD /d "0" /f >nul 2>&1
echo Disabling Chat icon:
Reg add "HKLM\zSOFTWARE\Policies\Microsoft\Windows\Windows Chat" /v "ChatIcon" /t REG_DWORD /d "3" /f >nul 2>&1
Reg add "HKLM\zNTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarMn" /t REG_DWORD /d "0" /f >nul 2>&1
echo Tweaking complete!
echo Unmounting Registry...
reg unload HKLM\zCOMPONENTS >nul 2>&1
reg unload HKLM\zDRIVERS >nul 2>&1
reg unload HKLM\zDEFAULT >nul 2>&1
reg unload HKLM\zNTUSER >nul 2>&1
reg unload HKLM\zSCHEMA >nul 2>&1
reg unload HKLM\zSOFTWARE >nul 2>&1
reg unload HKLM\zSYSTEM >nul 2>&1
echo Cleaning up image...
dism /image:c:\scratchdir /Cleanup-Image /StartComponentCleanup /ResetBase
echo Cleanup complete.
echo Unmounting image...
dism /unmount-image /mountdir:c:\scratchdir /commit
echo Exporting image...
Dism /Export-Image /SourceImageFile:c:\tiny11\sources\install.wim /SourceIndex:%index% /DestinationImageFile:c:\tiny11\sources\install2.wim /compress:max
del c:\tiny11\sources\install.wim
ren c:\tiny11\sources\install2.wim install.wim
echo Windows image completed. Continuing with boot.wim.
timeout /t 2 /nobreak > nul
cls
echo Mounting boot image:
dism /mount-image /imagefile:c:\tiny11\sources\boot.wim /index:2 /mountdir:c:\scratchdir
echo Loading registry...
reg load HKLM\zCOMPONENTS "c:\scratchdir\Windows\System32\config\COMPONENTS" >nul
reg load HKLM\zDEFAULT "c:\scratchdir\Windows\System32\config\default" >nul
reg load HKLM\zNTUSER "c:\scratchdir\Users\Default\ntuser.dat" >nul
reg load HKLM\zSOFTWARE "c:\scratchdir\Windows\System32\config\SOFTWARE" >nul
reg load HKLM\zSYSTEM "c:\scratchdir\Windows\System32\config\SYSTEM" >nul
echo Bypassing system requirements(on the setup image):
			Reg add "HKLM\zDEFAULT\Control Panel\UnsupportedHardwareNotificationCache" /v "SV1" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zDEFAULT\Control Panel\UnsupportedHardwareNotificationCache" /v "SV2" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zNTUSER\Control Panel\UnsupportedHardwareNotificationCache" /v "SV1" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zNTUSER\Control Panel\UnsupportedHardwareNotificationCache" /v "SV2" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassCPUCheck" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassRAMCheck" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassSecureBootCheck" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassStorageCheck" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassTPMCheck" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\MoSetup" /v "AllowUpgradesWithUnsupportedTPMOrCPU" /t REG_DWORD /d "1" /f >nul 2>&1
echo Tweaking complete! 
echo Unmounting Registry...
reg unload HKLM\zCOMPONENTS >nul 2>&1
reg unload HKLM\zDRIVERS >nul 2>&1
reg unload HKLM\zDEFAULT >nul 2>&1
reg unload HKLM\zNTUSER >nul 2>&1
reg unload HKLM\zSCHEMA >nul 2>&1
reg unload HKLM\zSOFTWARE >nul 2>&1
reg unload HKLM\zSYSTEM >nul 2>&1
echo Unmounting image...
dism /unmount-image /mountdir:c:\scratchdir /commit 
cls
echo the tiny11 image is now completed. Proceeding with the making of the ISO...
echo Copying unattended file for bypassing MS account on OOBE...
copy /y %~dp0autounattend.xml c:\tiny11\autounattend.xml
echo.
echo Creating ISO image...
%~dp0oscdimg.exe -m -o -u2 -udfver102 -bootdata:2#p0,e,bc:\tiny11\boot\etfsboot.com#pEF,e,bc:\tiny11\efi\microsoft\boot\efisys.bin c:\tiny11 %~dp0tiny11.iso
echo Creation completed! Press any key to exit the script...
pause 
echo Performing Cleanup...
rd c:\tiny11 /s /q 
rd c:\scratchdir /s /q 
exit

:RemoveAppxPackage
for /f "usebackq tokens=3 delims= " %%i in (`dism /Image:"%~1" /Get-ProvisionedAppxPackages ^| findstr PackageName ^| findstr "%~2"`) do (
  if not "%%i"=="" dism /Image:"%~1" /Remove-ProvisionedAppxPackage /PackageName:%%i
)
exit /b

:RemovePackage
for /f "usebackq tokens=4 delims= " %%i in (`dism /Image:"%~1" /Get-Packages ^| findstr Identity ^| findstr "%~2"`) do (
  if not "%%i"=="" dism /Image:"%~1" /Remove-Package /PackageName:%%i
)
exit /b





