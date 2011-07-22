@echo off

::* Project Name: Open Batch FrameWork

::* Author: nsinreal
::* Blog: http://nsinreal.blogspot.com
::* E-Mail: nsinreal+obfw@gmail.com
::* XMPP: xmpp://nsinreal@jabber.ru
::* License: CC-BY-SA 3.0

if "%1"=="" exit /b
call :ParseArguments %*
exit /b

:ParseArguments
	REM First argument - label/method
	set obfw.label=%1
	set "obfw.label=:%obfw.label::=%"

	REM All other arguments - method arguments
	set "obfw.args=%2"
	:ParseLoop
	shift
	if not "%2"=="" (
		call set "obfw.args=%obfw.args% %2"
		goto ParseLoop
		)

	call %obfw.label% %obfw.args%
exit /b

:: ===========================================================================
:: String procedurs
:: ===========================================================================

:: Args: %1 - string %2 variableName (for result)
:GetLength
	if "%1"=="" (
		set %2=0
		exit /b
	)
	set "GetLength.Str=%1"
	set GetLength.Length=0
	:GetLengthLoop
		set GetLength.Str=%GetLength.Str:~0,-1%
		set /a GetLength.Length+=1
		if not "%GetLength.Str%"=="" goto GetLengthLoop
	set %2=%GetLength.Length%
exit /b

:: Makes string length equal to %2. This method will add spaces in end
:: Args: %1 - variableName, %2 - size
:AddSpacesStr
	call set "AddSpacesStr.var=%%%1%%"
	set /a AddSpacesStr.size=20
	set /a AddSpacesStr.size=%2
	
	call set "AddSpacesStr.varFst=%%AddSpacesStr.var:~0,%AddSpacesStr.size%%%                                        "
	call set "AddSpacesStr.varSnd=%%AddSpacesStr.varFst:~0,%AddSpacesStr.size%%%"
	
	set "%1=%AddSpacesStr.varFst%"
	if "%AddSpacesStr.varFst%"=="%AddSpacesStr.varSnd%" (
		goto AddSpacesStr %1 %2
	)
	
	call set "%1=%%AddSpacesStr.varFst:~0,%AddSpacesStr.size%%%"
exit /b

:: Makes string length equal to %2. This method will add spaces in start
:: Args: %1 - variableName, %2 - size
:AddSpacesNum
	call set "AddSpacesNum.var=%%%1%%"
	set /a AddSpacesNum.size=20
	set /a AddSpacesNum.size=%2
	
	call set "AddSpacesNum.varFst=                                         %%AddSpacesNum.var:~-%AddSpacesNum.size%%%"
	call set "AddSpacesNum.varSnd=%%AddSpacesNum.varFst:~-%AddSpacesNum.size%%%"
	
	set "%1=%AddSpacesNum.varFst%"
	if "%AddSpacesNum.varFst%"=="%AddSpacesNum.varSnd%" (
		goto AddSpacesNum %1 %2
	)
	
	call set "%1=%%AddSpacesNum.varFst:~-%AddSpacesNum.size%%%"
exit /b

:: %1 - symbol
:checkIsDigit
	set checkIsDigit.Digit=false
	for /L %%i in (0,1,9) do if "%%i"=="%1" set checkIsDigit.Digit=true
exit /b

:: %1 - variableName %2 - symbol
:addStrIfDigit
	call :checkIsDigit %2
	if "%checkIsDigit.Digit%"=="true" call set "%1=%%%1%%%2"
exit /b

:: Args: %1 - variableName
:makeDigitsOnly
	set "makeDigitsOnly.Str="
	:makeDigitsOnlyLoop
		call :addStrIfDigit makeDigitsOnly.Str %%%1:~0,1%%
		call set "%1=%%%1:~1%%"
		call set "makeDigitsOnly.Temp=%%%1%%"
		if not "%makeDigitsOnly.Temp%"=="" goto makeDigitsOnlyLoop
	set %1=%makeDigitsOnly.Str%
exit /b

:: Args: %1 - variableName, %2 - Find, %3 Replace
:replace
	call set %1=%%%1:%2=%3%%
exit /b

:: Args: %1 - variableName
:makeLowerCase
	set "makeLowerCase.Alph.upper=QWERTYUIOPASDFGHJKLZXCVBNM"
	set "makeLowerCase.Alph.lower=qwertyuiopasdfghjklzxcvbnm"
	for /L %%i in (0,1,25) do call :replace %1 %%makeLowerCase.Alph.upper:~%%i,1%% %%makeLowerCase.Alph.lower:~%%i,1%%
exit /b

:: Args: %1 - variableName
:makeUpperCase
	set "makeUpperCase.Alph.upper=QWERTYUIOPASDFGHJKLZXCVBNM"
	set "makeUpperCase.Alph.lower=qwertyuiopasdfghjklzxcvbnm"
	for /L %%i in (0,1,25) do call :replace %1 %%makeUpperCase.Alph.lower:~%%i,1%% %%makeUpperCase.Alph.upper:~%%i,1%%
exit /b

:: Args: %1 - variableName
:deleteDoubleLetter
	set "deleteDoubleLetter.Alph.upper=QWERTYUIOPASDFGHJKLZXCVBNM"
	set "deleteDoubleLetter.Alph.lower=qwertyuiopasdfghjklzxcvbnm"
	for /L %%i in (0,1,25) do call :replace %1 %%deleteDoubleLetter.Alph.lower:~%%i,1%%%%deleteDoubleLetter.Alph.lower:~%%i,1%% %%deleteDoubleLetter.Alph.lower:~%%i,1%%
	for /L %%i in (0,1,25) do call :replace %1 %%deleteDoubleLetter.Alph.upper:~%%i,1%%%%deleteDoubleLetter.Alph.upper:~%%i,1%% %%deleteDoubleLetter.Alph.upper:~%%i,1%%
exit /b

:DeleteSpaces
	call set DeleteSpaces.Str.Value.Init=%%%1%%
	call set DeleteSpaces.Str.Value=%%%1:     =%%
	call set DeleteSpaces.Str.Value=%%%1:    =%%
	call set DeleteSpaces.Str.Value=%%%1:   =%%
	call set DeleteSpaces.Str.Value=%%%1:  =%%
	call set DeleteSpaces.Str.Value=%%%1: =%%
	set %1=%DeleteSpaces.Str.Value%
	if not "%DeleteSpaces.Str.Value.Init%"=="%DeleteSpaces.Str.Value%" goto DeleteSpaces %1
exit /b

:: Args: %1 - variableName
:deleteDoubleSpaces
	call set deleteDoubleSpaces.Str.Value.Init=%%%1%%
	call set deleteDoubleSpaces.Str.Value=%%%1:     = %%
	call set deleteDoubleSpaces.Str.Value=%%%1:    = %%
	call set deleteDoubleSpaces.Str.Value=%%%1:   = %%
	call set deleteDoubleSpaces.Str.Value=%%%1:  = %%
	set %1=%deleteDoubleSpaces.Str.Value%
	if not "%deleteDoubleSpaces.Str.Value.Init%"=="%deleteDoubleSpaces.Str.Value%" goto deleteDoubleSpaces %1
exit /b

:: Args: %1 - variableName
:deletePunctuationMarks
	call set %1=%%%1:;= %%
	call set %1=%%%1::= %%
	call set %1=%%%1:(= %%
	call set %1=%%%1:)= %%
	call set %1=%%%1:?= %%
	call set %1=%%%1:!= %%
	call set %1=%%%1:,= %%
	call set %1=%%%1:.= %%
exit /b

:: Firstly delete punctuanion marks, double spaces & double letters
:: Args: %1 - input variableName, %2 - variableName, %3 word
:FindWord
	:: Add spaces in start & end
	call set "%1= %%%1%% "

	call set "FindWord.Str=%%%1%%"
	call set "FindWord.Replaced=%%%1: %3 =%%"

	:: Delete added spaces
	call set "%1=%%%1:~1%%"
	call set "%1=%%%1:~0,-1%%"

	if not "%FindWord.Str%"=="%FindWord.Replaced%" set %2=True
exit /b

:: Firstly delete punctuanion marks, double spaces & double letters
:: Args: %1 - input variableName, %2 - variableName, %3, %4, ... - words
:FindWords
	set FindWords.input.variableName=%1
	set FindWords.variableName=%2
	set "%2=No results"
	:FindWordsLoop
		call set FindWords.variableName.value=%%%2%%
		if not "%FindWords.variableName.value%"=="False" if not "%3"=="" (
			call :FindWord %FindWords.input.variableName% %FindWords.variableName% %3
			shift
			goto FindWordsLoop
		)
exit /b

:: ===========================================================================
:: Timer here
:: ===========================================================================

:: Args: %1 - variableName %2 - Digit
:ReplaceTimeDigit
	call set %1=%%%1: %2=0%2%%
exit /b

:: Replace " 0" to "00", " 1"->"01", etc
:: Args: %1 - variableName
:ReplaceTimeDigits
	for /L %%i IN (0,1,9) do call :ReplaceTimeDigit %1 %%i
exit /b

:: Args: %1 - variableName
:ConvertTime
	call set Timer.TempTime=%%%1%%
	call :ReplaceTimeDigits Timer.TempTime
	call set /A Timer.TempTime=(1%Timer.TempTime:~0,2%-100)*360000 + (1%Timer.TempTime:~3,2%-100)*6000 + (1%Timer.TempTime:~6,2%-100)*100 + (1%Timer.TempTime:~9,2%-100)
	set %1=%Timer.TempTime%
	set %1.Converted=1
exit /b

:: Args: %1 - centiseconds
:ConvertCentiSeconds
	:: break the centiseconds down to hours, minutes, seconds and the remaining centiseconds
	call set /A Timer.Duration=%1
	set /A Timer.DurationH=%Timer.Duration% / 360000 >nul
	set /A Timer.DurationM=(%Timer.Duration% - %Timer.DurationH%*360000) / 6000 >nul
	set /A Timer.DurationS=(%Timer.Duration% - %Timer.DurationH%*360000 - %Timer.DurationM%*6000) / 100 >nul
	set /A Timer.DurationHS=(%Timer.Duration% - %Timer.DurationH%*360000 - %Timer.DurationM%*6000 - %Timer.DurationS%*100) >nul

	:: some formatting
	if %Timer.DurationH% LSS 10 set Timer.DurationH=0%Timer.DurationH%
	if %Timer.DurationM% LSS 10 set Timer.DurationM=0%Timer.DurationM%
	if %Timer.DurationS% LSS 10 set Timer.DurationS=0%Timer.DurationS%
	if %Timer.DurationHS% LSS 10 set Timer.DurationHS=0%Timer.DurationHS%

	set Timer.DurationFormatted=%Timer.DurationH%:%Timer.DurationM%:%Timer.DurationS%,%Timer.DurationHS%
exit /b

:: Args: %1 - timerID
:TimerReset
	set "Timer.%1.Started="
	set "Timer.%1.Started.Converted="
exit /b

:: Args: %1 - timerID
:TimerStart
	set "Timer.%1.Started=%Time%"
	set Timer.%1.Started.Converted=0
exit /b

:: Args: %1 - timerID
:TimerNow
	set Timer.TimerId=%1

	:: Make Timer = Timer.%Timer.TimerId%
	call set Timer.Started=%%Timer.%Timer.TimerId%.Started%%
	call set Timer.Started.Converted=%%Timer.%Timer.TimerId%.Started.Converted%%

	if "%Timer.Started%"=="" (
		set "Timer.%Timer.TimerId%.Duration=0"
		set "Timer.%Timer.TimerId%.DurationFormatted=00:00:00.00"
		exit /b
	)

	set "Timer.%Timer.TimerId%.TimeNow=%Time%"
	call :ReplaceTimeDigits Timer.%Timer.TimerId%.TimeNow

	call :ConvertTime Timer.%Timer.TimerId%.TimeNow
	if not "%Timer.Started.Converted%"=="1" call :ConvertTime Timer.%Timer.TimerId%.Started

	:: Make Timer = Timer.%Timer.TimerId%. Again
	call set Timer.TimeNow=%%Timer.%Timer.TimerId%.TimeNow%%
	call set Timer.Started=%%Timer.%Timer.TimerId%.Started%%

	:: calculating the Duration is easy
	set /A Timer.Duration=%Timer.TimeNow%-%Timer.Started%

	:: we might have measured the Time inbetween days
	if %Timer.TimeNow% LSS %Timer.Started% set /A Timer.Duration+=24*60*60*100
	
	call :ConvertCentiSeconds %Timer.Duration%

	:: Make Timer.%Timer.TimerId% = Timer
	set Timer.%Timer.TimerId%.DurationFormatted=%Timer.DurationFormatted%
	set Timer.%Timer.TimerId%.Duration=%Timer.Duration%
exit /b