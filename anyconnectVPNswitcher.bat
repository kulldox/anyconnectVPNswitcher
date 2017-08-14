@ECHO.
@ECHO OFF

@ECHO ==================================================================
@ECHO =====          Cisco AnyConnect VPN Switcher                 =====
@ECHO ==================================================================
@ECHO.

rem *** MISC Initializations ***
set PROFILENAME=""
set PROFILEUSER=
set PROFILEPASS=
set PROFILEBANNER=""
set PRODUCTION=""

rem *** START CONFIGURATION ***
set VPNNAME="Cisco AnyConnect Secure Mobility Agent"
set PAUSETIME=5
set APPPATH="%ProgramFiles(x86)%\Cisco\Cisco AnyConnect Secure Mobility Client\"
set APPVIPPATH="%ProgramFiles(x86)%\Symantec\VIP Access Client\"
set VPNPROFILEBACKUP="C:\bkp\anyconnect\asOfAug72017\AnyConnect-General-Client-mct-custom-Profile.xml"
set VPNPROFILE="%ProgramData%\Cisco\Cisco AnyConnect Secure Mobility Client\Profile\AnyConnect-General-Client-Profile.xml"
set CHECKPROFILE="yes"
setlocal EnableDelayedExpansion

if "%1" == "VPNServer1" (
	rem example of a generic server, that does not have a banner. Banner, is a little popup kind of window that is opened once you connect to the VPN, and it requires you to accept some rules.
	set PROFILENAME="VPNServer1"
	set PROFILEUSER=myUser1
	set PROFILEPASS=myPass1
	set PROFILEBANNER=""
) else if "%1" == "VPNServer2" (
	rem same as above, but with a banner. Banner.
	set PROFILENAME="VPNServer2"
	set PROFILEUSER=myUser2
	set PROFILEPASS=myPass2
	set PROFILEBANNER="y"
) else if "%1" == "VPNServer3" (
	rem this one is a kind of server that is using 2 step authentication. In my case it is the "Symantec VIP Access Client", so you can't fully automate the login. Thus, just open the GUI versions
	set PRODUCTION="production"
	set PROFILENAME="VPNServer3"
	set PROFILEUSER=myUser3
	set PROFILEPASS=myPass3
	set PROFILEBANNER=""
) else if "%1" == "disconnect" (
	rem this is for disconnect purposes
	set PROFILENAME="disconnect"
	set PROFILEUSER=
	set PROFILEPASS=
	set PROFILEBANNER=""
rem *** END CONFIGURATION ***
) else (
	@ECHO ERROR: Unknown option. Exit.
	goto exitScript
)

rem due to problems with paths having spaces failing in the for loops, just CD into the dir
cd %APPPATH%

if %CHECKPROFILE% == "yes" (
	rem some VPNs will overwrite the profile
	@ECHO INFO: Restore the custom profile from %VPNPROFILEBACKUP%
	xcopy /y %VPNPROFILEBACKUP% %VPNPROFILE%
	@ECHO.
)

if %PROFILENAME% NEQ "disconnect" (
	@ECHO INFO: Check if %PROFILENAME% exists, if no, exit
	rem just a hack to save the command output into a variable
	set OUTPUT=""
	vpncli.exe hosts
	for /f "delims=" %%i in ('vpncli.exe hosts ^| find %PROFILENAME%') do ( set "OUTPUT=%%~i" )
	@ECHO "value found !OUTPUT!"
	if "!OUTPUT!" == "" (
		@ECHO "/!\ ERROR: The profile %PROFILENAME% does NOT exist. Exit."
		vpncli.exe hosts
		goto exitScript
	)
)
@ECHO INFO: Disconnect the vpncli.exe application
%APPPATH%vpncli.exe disconnect
@ECHO Wait %PAUSETIME% seconds
TIMEOUT /t %PAUSETIME% /NOBREAK

if %PROFILENAME% == "disconnect" (
	@ECHO INFO: Just disconnect the VPN client
	goto exitScript
)

@ECHO INFO: Check if %VPNNAME% Service is up and running, if yes, stop it
rem just a hack to save the command output into a variable
set OUTPUT=""
for /f  "delims=" %%i in ('NET START ^| find %VPNNAME%') do set "OUTPUT=%%~i"
if NOT "!OUTPUT!" == "" (
	@ECHO INFO: Stopping %VPNNAME% Service, please wait for %PAUSETIME% seconds
	rem runas /user:Administrator NET STOP %VPNNAME%
	NET STOP %VPNNAME%
	TIMEOUT /t %PAUSETIME% /NOBREAK
)

rem loop until the service is up and running
:checkVPNServiceup
@ECHO INFO: Check if %VPNNAME% Service is up and running
rem just a hack to save the command output into a variable
set OUTPUT=""
for /f  "delims=" %%i in ('NET START ^| find %VPNNAME%') do set "OUTPUT=%%~i"
@ECHO "value of OUTPUT: !OUTPUT!"
if "!OUTPUT!" == "" (
	@ECHO INFO: %VPNNAME% Service is not up.
	@ECHO INFO: Starting %VPNNAME% Service
	NET START %VPNNAME%
	TIMEOUT /t %PAUSETIME% /NOBREAK
	goto checkVPNServiceup
)

rem if this is not production, start the vpncli.exe with profile, user and pass
if NOT "%~PRODUCTION%" == "production" (
	@ECHO INFO: Start the vpncli.exe application
	@ECHO INFO: connect %PROFILENAME%^& echo %PROFILEUSER%^&echo %PROFILEPASS%^&echo y
	if %PROFILEBANNER% == "y" (
		(echo connect %PROFILENAME%^& echo %PROFILEUSER%^&echo %PROFILEPASS%^&echo y^&rem.) | %APPPATH%vpncli.exe -s
	)
	rem this is for cases when no banner is used
	if %PROFILEBANNER% == "" (
		(echo connect %PROFILENAME%^& echo %PROFILEUSER%^&echo %PROFILEPASS%^&rem.) | %APPPATH%vpncli.exe -s
	)
)

rem if this is production which is using multiple step authentication, so use GUIs, thus just start the 'Symantec VIP access' and vpnui.exe
if "%~PRODUCTION%" == "production" (
	@ECHO INFO: This is production, start Symantec VIP access
	start "" /D%APPVIPPATH% VIPUIManager.exe
	@ECHO INFO: This is production, just start the GUI version vpnui.exe
	start "" /D%APPPATH% vpnui.exe
	TIMEOUT /t %PAUSETIME% /NOBREAK
)

endlocal

:exitScript
@ECHO INFO: Wait %PAUSETIME% seconds
TIMEOUT /t %PAUSETIME% /NOBREAK

@ECHO "INFO: Done. Have FUN :)"
rem PAUSE
EXIT