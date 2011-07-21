@echo off
set "OBFW=../../obfw.bat"
goto Init

::* Project Name: MineSweeper

::* Author: nsinreal
::* Blog: http://nsinreal.blogspot.com
::* E-Mail: nsinreal+obfw@gmail.com
::* XMPP: xmpp://nsinreal@jabber.ru
::* License: CC-BY-SA 3.0

:: WARNING: there are 30 real "goto" commands
:: This source can damage your mental health.

:: ===========================================================================
:: Display logo/messages/help
:: ===========================================================================

:: Main part of code ^_^
:PrintTheLogo
	echo                                  ~
	echo                                  :77~ ~=~I~
	echo                          ~       :? I~?:=7=      ~?~
	echo                           I7=~ ~I~+7+?:~?7++?=~=?7=
	echo                           :=7 7II77III??,+==~~~=I=~
	echo                           ~:=I?~7?+7II??++~=?+~:~~
	echo                            I777:=I7I??I??++??=~:::~
	echo                           I777 :~+I7III??++?+~~~::~=
	echo                      ~?IIII?777   777II??++=~~~~::=777II=
	echo                       ~~=?I?77777777II???+?==~~:::~7I+~~
	echo                         ~,+?IIII7IIII???++??+~~:::~~:
	echo                         ~???~??IIII???++~::,~::::~=++~
	echo                       ~~~+~I   ??:~+??++=~,:::::~~=?+++~
	echo                      ~:,,I===~~++,=?+====~~~:::~+=+I::::~
	echo                           =+=======:::=~~~~:::I  +??
	echo                            ==~=======~~~~::::~:~+ ?
	echo                             ~=====~~~~~::::~~=,~?=:~
	echo                            :+?==~~~~:+  +~~==+I+~==~         MINESWEEPER
	echo                            =+~:~~==~,~ 7~=+?I?  ~,~=            BY NSINREAL
	echo                           =:      ~:=: ++?~~:       ~
	echo                                    ,  7  , ~~
	echo                                    ~      ~~
	echo.
exit /b

:errorIOCoordinates
	cls
	echo Error I/O: Unknown coordinates
	echo.
	call :PrintTheHelp
	goto GameCycle
exit /b

:errorIOCommand
	cls
	echo Error I/O: Unknown command
	echo.
	call :PrintTheHelp
	goto GameCycle
exit /b

:PrintTheHelp
	echo Avaible commands:
	echo   o [yx] - Open Cell yx
	echo   f [yx] - Create Flag on Cell yx
	echo   h      - Output this help.
	IF EXIST records.log echo   r      - Output all records
	echo   n      - Start new game
	echo   q      - Exit to Windows or console
	echo.

	echo Example: o 12     - open Cell with coordinates y=1, x=2
	echo          f 34     - create Flag on Cell y=3, x=4
	echo          n        - Start new game
	echo          new game - Start new game
	echo.

	pause>nul
exit /b

:: ===========================================================================
:: Records (topscore)
:: ===========================================================================

:ResaveRecordsWithMarker
	if %Place% GTR 15 exit /b

	if "%LastMarker%"=="!" (
		echo   +--------------+-------+--------------------------+------------------------+ >>records.log 2>nul)

	call %obfw% :AddSpacesStr Name 24
	call %obfw% :AddSpacesNum GameStep 5
	call %obfw% :AddSpacesNum Timer.DurationFormatted 12
	call %obfw% :AddSpacesNum DateTime 22

	if "%Marker%"=="!" if not "%LastMarker%"=="nop" (
		echo   +--------------+-------+--------------------------+------------------------+ >>records.log 2>nul)

	echo   ^| %Timer.DurationFormatted% ^| %GameStep% ^| %Name% ^| %DateTime% ^| >>records.log 2>nul

	set "LastMarker=%Marker%"
	set /a Place+=1
exit /b

:MarkPlayer
	set "LastMarker=nop"
	set /a Place = 0
	move /y records.log records.b.log>nul 2>nul
	FOR /F "tokens=1,2,3,4,5,6 delims=^| " %%a in (records.b.log) do (
		set "Timer.DurationFormatted=%%a"
		set "GameStep=%%b"
		set "Name=%%c"
		set "DateTime=%%d %%e"
		set "Marker=%%f"
		call :ResaveRecordsWithMarker
	)
exit /b

:MarkDelete
	del /s/q records.b.log>nul 2>nul
	findstr /V /C:"+-" < records.log > records.b.log
	move /y records.b.log records.log>nul 2>nul
exit /b

:printRecords
	sort records.log /O records.sorted.log
	move /y records.sorted.log records.log >nul 2>nul

	if "%1"=="true" call :MarkPlayer

	cls
	echo   +--------------------------------------------------------------------------+
	echo   ^|   GameTime   ^| Step  ^|      NickName            ^|       Played at        ^|
	echo   +--------------------------------------------------------------------------+
	more /S records.log
	echo   +--------------------------------------------------------------------------+

	if not "%1"=="true" pause >nul 2>nul

	if "%1"=="true" call :MarkDelete
exit /b

:: ===========================================================================
:: Check win, check fail
:: ===========================================================================

:makeNewGame
	endlocal>nul
	goto Init
exit /b

:CheckUserWantNewGame
	echo.
	set Input=yes
	set /p "Input=Want to start new game? "

	set Input=%Input:~0,1%
	if "%Input%"=="y" goto makeNewGame
exit /b

:: Args: %1 - Field.Fake(x,y); %2 - Field.Real(x,y)
:CheckFlags
	if "%1"=="?" set /a noFlags+=1
	if "%1"=="!" if "%2"=="X" set /a rightFlags+=1
exit /b

:CheckWin
	if %FlagNum% GTR %BombsMax% exit /b

	if "%GameStep%"=="0" exit /b

	set noFlags=0
	set rightFlags=0
	for /L %%x in (1,1,9) do for /L %%y in (1,1,9) do call :CheckFlags %%Field.Fake%%x%%y%% %%Field.Real%%x%%y%%

	set /a sumFlags=%noFlags% + %rightFlags%
	if %rightFlags%==%FlagNum% if %sumFlags%==%BombsMax% call :doWin
exit /b

:doWin
	if not "%Win%"=="1" (
		set Win=1
		for /L %%x in (1,1,9) do for /L %%y in (1,1,9) do call set Field.Fake%%x%%y=%%Field.Real%%x%%y%%
		exit /b
		)

	:: Make record

	set Name=Anon@%USERNAME%
	set /p Name="Your name (without spaces): "
	:: Delete special characters & space
	set Name=%Name:!=%
	set Name=%Name: =%
	set "DateTime=%date% %time%"

	echo   ^|  %Timer.DurationFormatted% ^| %GameStep% ^| %Name% ^| %DateTime% ^! >>records.log 2>nul

	call :printRecords true

	goto CheckUserWantNewGame
exit /B

::  We all die (someday). User died now. He is bad minesweeper. Show real field to him
:doFail
	if not "%Fail%"=="1" (
		set Fail=1
		goto GameCycle
		)

	goto CheckUserWantNewGame
exit /b

:: ===========================================================================
:: Field generating
:: ===========================================================================

:: Create one bomb at (x,y)
:: Args: %1, %2 - coordinates (x,y)
:newBomb
	if not "%1"=="X" (
		set "%2=X"
		set /a BombNum=%BombNum%+1
	)
exit /b

:: 17:00 This procedure makes me cry. Can you understand, what I writed?
:: 19:00 Naming fixed. Now I can understand this. What about you?
:: Args: %1 %2 - don't make bomb here (x,y)
:GenerateBombs
	set DontX=%1
	set DontY=%2
	set BombX=%random:~-2%
	set BombY=%random:~-2%
	set BombX=%BombX:0= %
	set BombY=%BombY:0= %
	set BombX=%BombX: =%
	set BombY=%BombY: =%
	set BombX=%BombX:~0,1%
	set BombY=%BombY:~0,1%
	if "%BombX%"=="0" goto GenerateBombs %DontX% %DontY%
	if "%BombY%"=="0" goto GenerateBombs %DontX% %DontY%
	if "%BombX%"=="%DontX%" goto GenerateBombs %DontX% %DontY%
	if "%BombY%"=="%DontY%" goto GenerateBombs %DontX% %DontY%

	if "%BombNum%" == "%BombsMax%" exit /b

	call :newBomb %%Field.Real%BombX%%BombY%%% Field.Real%BombX%%BombY%

	goto GenerateBombs
exit /b

Becouse 'call' doesn't work with if, we must create new procedure
:NewSum
	if "%1"=="X" set /a NearestBombNum+=1
exit /b

:: Count nearest bombs for each cell
:: Args: %1, %2 - coordinaets (x,y), %3 - cell content %4 - cell name
:countBombs
	:: If there is something in cell, exit
	if not "%3"=="?" exit /b

	:: Coordinates of nearest cells
	set /a x1=%1 - 1
	set /a y1=%2 + 1
	set /a x2=%1
	set /a y2=%2 + 1
	set /a x3=%1 + 1
	set /a y3=%2 + 1
	set /a x4=%1 - 1
	set /a y4=%2
	set /a x5=%1 + 1
	set /a y5=%2
	set /a x6=%1 - 1
	set /a y6=%2 - 1
	set /a x7=%1
	set /a y7=%2 - 1
	set /a x8=%1 + 1
	set /a y8=%2 - 1

	set NearestBombNum=0

	:: Check coordinates & count bombs
	:: a GTR b == a > b
	:: a LSS b == a < b
	if %1 GTR 1 if %2 LSS 9 call :NewSum %%Field.Real%x1%%y1%%%
				if %2 LSS 9 call :NewSum %%Field.Real%x2%%y2%%%
	if %1 LSS 9 if %2 LSS 9 call :NewSum %%Field.Real%x3%%y3%%%
	if %1 GTR 1 			call :NewSum %%Field.Real%x4%%y4%%%
	if %1 LSS 9 			call :NewSum %%Field.Real%x5%%y5%%%
	if %1 GTR 1 if %2 GTR 1 call :NewSum %%Field.Real%x6%%y6%%%
				if %2 GTR 1 call :NewSum %%Field.Real%x7%%y7%%%
	if %1 LSS 9 if %2 GTR 1 call :NewSum %%Field.Real%x8%%y8%%%

	set %4=%NearestBombNum%
exit /b

:GenerateField
	for /L %%x in (1,1,9) do for /L %%y in (1,1,9) do call :countBombs %%x %%y %%Field.Real%%x%%y%% Field.Real%%x%%y
exit /b

:: ===========================================================================
:: Open/flag cell
:: ===========================================================================

:clearCell
	if "%3"=="?" exit /b
	if "%3"=="X" exit /b
	set %4=?
exit /b

:clearField
	for /L %%x in (1,1,9) do for /L %%y in (1,1,9) do call :clearCell %%x %%y %%Field.Real%%x%%y%% Field.Real%%x%%y
exit /b

:CheckCellIsOpened
	if "%1"=="?" set NotOpenedBefore=1
exit /b

:OpenCell
:: %1, %2 - coordinats (x,y), %3 - cell content (real field) %4 - cell content (fake field)
	:: Some checks
	if "%3"==""  exit /b
	if "%3"=="X" exit /b

	:: Open this cell
	call set Field.Fake%1%2=%%Field.Real%1%2%%

	:: If there are no bombs near, try to open automatically all nearest cells. Else - leave
	if not "%3" == "0" exit /b

	set /a NextX=%1
	set /a NextY=%2 + 1
	set NotOpenedBefore=0
	call :CheckCellIsOpened %%Field.Fake%NextX%%NextY%%%
	if %NotOpenedBefore%==1 call :OpenCell %NextX% %NextY% %%Field.Real%NextX%%NextY%%% %%Field.Fake%NextX%%NextY%%%

	set /a NextX=%1
	set /a NextY=%2 - 1
	set NotOpenedBefore=0
	call :CheckCellIsOpened %%Field.Fake%NextX%%NextY%%%
	if %NotOpenedBefore%==1 call :OpenCell %NextX% %NextY% %%Field.Real%NextX%%NextY%%% %%Field.Fake%NextX%%NextY%%%

	set /a NextX=%1 - 1
	set /a NextY=%2
	set NotOpenedBefore=0
	call :CheckCellIsOpened %%Field.Fake%NextX%%NextY%%%
	if %NotOpenedBefore%==1 call :OpenCell %NextX% %NextY% %%Field.Real%NextX%%NextY%%% %%Field.Fake%NextX%%NextY%%%

	set /a NextX=%1 + 1
	set /a NextY=%2
	set NotOpenedBefore=0
	call :CheckCellIsOpened %%Field.Fake%NextX%%NextY%%%
	if %NotOpenedBefore%==1 call :OpenCell %NextX% %NextY%	%%Field.Real%NextX%%NextY%%% %%Field.Fake%NextX%%NextY%%%

	set /a NextX=%1 + 1
	set /a NextY=%2 + 1
	set NotOpenedBefore=0
	call :CheckCellIsOpened %%Field.Fake%NextX%%NextY%%% %%Field.Real%NextX%%NextY%%%
	if %NotOpenedBefore%==1 call :OpenCell %NextX% %NextY%	%%Field.Real%NextX%%NextY%%% %%Field.Fake%NextX%%NextY%%%

	set /a NextX=%1 + 1
	set /a NextY=%2 - 1
	set NotOpenedBefore=0
	call :CheckCellIsOpened %%Field.Fake%NextX%%NextY%%% %%Field.Real%NextX%%NextY%%%
	if %NotOpenedBefore%==1 call :OpenCell %NextX% %NextY%	%%Field.Real%NextX%%NextY%%% %%Field.Fake%NextX%%NextY%%%

	set /a NextX=%1 - 1
	set /a NextY=%2 + 1
	set NotOpenedBefore=0
	call :CheckCellIsOpened %%Field.Fake%NextX%%NextY%%% %%Field.Real%NextX%%NextY%%%
	if %NotOpenedBefore%==1 call :OpenCell %NextX% %NextY%	%%Field.Real%NextX%%NextY%%% %%Field.Fake%NextX%%NextY%%%

	set /a NextX=%1 - 1
	set /a NextY=%2 - 1
	set NotOpenedBefore=0
	call :CheckCellIsOpened %%Field.Fake%NextX%%NextY%%% %%Field.Real%NextX%%NextY%%%
	if %NotOpenedBefore%==1 call :OpenCell %NextX% %NextY%	%%Field.Real%NextX%%NextY%%% %%Field.Fake%NextX%%NextY%%%
exit /b

:: Args: %1, %2 - coordinates (x,y), %3 - cell content (real field) %4 - cell content (fake field)
:SecureOpenCell
	:: Increase GameStep
	set /a GameStep+=1
	:: Run timer at first gamestep
	if "%GameStep%"=="1" call %obfw% :TimerStart

	if not "%4"=="?" (
		echo Cell x=%1 y=%2 already opened
		pause>nul
		exit /b
	)
	:: Bomb is here :: No death at first step
	if "%3"=="X" if not "%GameStep%"=="1" (
		call set Fail=1
		for /L %%x in (1,1,9) do for /L %%y in (1,1,9) do call set Field.Fake%%x%%y=%%Field.Real%%x%%y%%
		exit /b
	)

	:: No death at first step
	if "%GameStep%"=="1" if "%3"=="X" (
		call set Field.Real%1%2=?
		call set /a BombNum-=1
		call :clearField
		call :GenerateBombs %1 %2
		call :GenerateField
		call :OpenCell %1 %2 %%Field.Real%1%2%% %%Field.Fake%1%2%%
	)

	:: Now we can open cell
	call :OpenCell %1 %2 %3 %4
exit /b

:: Args: %1, %2 - coordinats (x,y), %3 - cell content (fake field)
:FlagCell
	:: Check user fail
	if not "%3"=="?" if not "%3"=="!" (
		echo Cell %2 %1 already opened
		pause>nul
		exit /b
	)

	:: Add/delete flag from field
	if not "%3"=="!" (
		set /a FlagNum+=1
		call set Field.Fake%%1%%2=^!
		) else (
		set /a FlagNum-=1
		call set Field.Fake%%1%%2=?
	)
exit /b

:: ===========================================================================
:: Game here
:: ===========================================================================

:InputCycle
	:: User can just press enter and %Input% will be equal to last input 
	:: (or to "" if this input is first). To fix it, we write fake input 0 00
	set "Input=0 00"
	set /p "Input=Input: "
	:: Destroy double spaces
	set "Input=%Input: =%"
	set "Input.Action=%Input:~0,1%"

	:: Leave the game
	if "%Input.Action%"=="q" (
		echo Good Bye.
		exit /b
	)
	:: Or print help
	if "%Input.Action%"=="h" (
		cls
		call :PrintTheHelp
		goto GameCycle
	)
	:: Or print records
	if "%Input.Action%"=="r" (
		if EXIST records.log (
			call :printRecords false
			goto GameCycle
		) else (
			goto errorIOCommand
		)
	)
	:: Or make new game
	if "%Input.Action%"=="n" (
		endlocal>nul
		goto Init
	)

	:: Magic is here
	set Input.X=0
	set Input.Y=0
	for /L %%i in (1,1,9) do if "%%i"=="%Input:~0,1%" set Input.X=%%i
	if %Input.X%==0 (
		for /L %%i in (1,1,9) do if "%%i"=="%Input:~1,1%" set Input.X=%%i
		for /L %%i in (1,1,9) do if "%%i"=="%Input:~2,1%" set Input.Y=%%i
		) else (
		for /L %%i in (1,1,9) do if "%%i"=="%Input:~1,1%" set Input.Y=%%i
		:: If user haven't writed Input.Action, but writed coordinates, open the cell
		set Input.Action=o
	)

	:: User is idiot
	:: This code seems like LISP.
	if not "%Input.Action%"=="q" (
		if not "%Input.Action%"=="h" (
			if not "%Input.Action%"=="o" (
				if not "%Input.Action%"=="f" (
					if not "%Input.Action%"=="n" (
						if not "%Input.Action%"=="r" (
							goto errorIOCommand ))))))

	:: User is twice idiot
	if "%Input.X%"=="0" (
		goto errorIOCoordinates
		goto GameCycle
	)
	if "%Input.Y%"=="0" (
		goto errorIOCoordinates
		goto GameCycle
	)

	if not "%Win%"=="1" call %obfw% :TimerNow
	if "%Input.Action%"=="o" (
			call :SecureOpenCell %Input.X% %Input.Y% %%Field.Real%Input.X%%Input.Y%%% %%Field.Fake%Input.X%%Input.Y%%%
			goto GameCycle
	)
	if "%Input.Action%"=="f" (
			call :FlagCell %Input.X% %Input.Y% %%Field.Fake%Input.X%%Input.Y%%%
			goto GameCycle
	)
exit /b

:GameCycle
	:: Try to make no delay when display field: 1) Write data in variable 2) Clear screen 3) Print variable 4) ??? 5) PROFIT
	set "Output.Line0=:yx  1  2  3  4  5  6  7  8  9  xy:"
	set "Output.Line10=:yx  1  2  3  4  5  6  7  8  9  xy:"
	for /L %%y in (1,1,9) do call set "Output.Line%%y=:%%y:  %%Field.Fake%%y1%%  %%Field.Fake%%y2%%  %%Field.Fake%%y3%%  %%Field.Fake%%y4%%  %%Field.Fake%%y5%%  %%Field.Fake%%y6%%  %%Field.Fake%%y7%%  %%Field.Fake%%y8%%  %%Field.Fake%%y9%%  :%%y:"

	:: Let's try to make better UI. Replace "0"->" " (zero to space) and "?"->"." (question mark to dot)
	for /L %%y in (1,1,9) do call set "Output.Line%%y=%%Output.Line%%y:0= %%"
	for /L %%y in (1,1,9) do call set "Output.Line%%y=%%Output.Line%%y:?=.%%"

	:: Print FlagNum
	if %FlagNum% GTR %BombsMax% (
		set "Output.Line0=%Output.Line0%  !!! Flags: %FlagNum%/%BombNum%"
		) else (
		set "Output.Line0=%Output.Line0%      Flags: %FlagNum%/%BombNum%"
		)

	:: Run timer
	if not "%Win%"=="1" call %obfw% :TimerNow
	call set Output.Line1=%Output.Line1%      Time: %Timer.DurationFormatted%

	:: Print GameStep
	set "Output.Line2=%Output.Line2%      GameStep: %GameStep%"

	:: Print help at right side
	if not "%Fail%"=="1" if not "%Win%"=="1" (
		set "Output.Line4=%Output.Line4%      Avaible commands:"
		set "Output.Line5=%Output.Line5%      o [yx] - Open cell yx"
		set "Output.Line6=%Output.Line6%      f [yx] - Create Flag on cell yx"
		set "Output.Line7=%Output.Line7%      n      - Start new game"
		set "Output.Line8=%Output.Line8%      q      - Exit to Windows or console"
		set "Output.Line9=%Output.Line9%      h      - Display this help."
		set "Output.Line10=%Output.Line10%      r      - Display all records"
		)

	:: Check win or fail
	if "%Fail%"=="1" (
		set Output.Line4=%Output.Line4%      Bomb!!! U Failed.
		set Output.Line5=%Output.Line5%      Format C: completed
	)
	if "%Win%"=="1" (
		set Output.Line4=%Output.Line4%      Win!!! Win!!! Win!!! Win!!! Win!!!
		set Output.Line5=%Output.Line5%      Win!!! Win!!! Win!!! Win!!! Win!!!
		set Output.Line6=%Output.Line6%      Win!!! Win!!! Win!!! Win!!! Win!!!
		set Output.Line7=%Output.Line7%      Win!!! Win!!! Win!!! Win!!! Win!!!
		set Output.Line8=%Output.Line8%      Win!!! Win!!! Win!!! Win!!! Win!!!
		set Output.Line9=%Output.Line9%      Win!!! Win!!! Win!!! Win!!! Win!!!
		set Output.Line10=%Output.Line10%      Win!!! Win!!! Win!!! Win!!! Win!!!
	)

	cls
	echo %Output.Line0%
	echo :---------------------------------:
	for /L %%y in (1,1,8) do (
		call echo %%Output.Line%%y%%
		echo :-:                             :-:
	)
	echo %Output.Line9%
	echo :---------------------------------:
	echo %Output.Line10%
	echo.

	:: If we winned or failed call doFail || doWin
	if "%Fail%"=="1" goto doFail
	if "%Win%"=="1" goto doWin

	if not "%Fail%"=="1" if not "%Win%"=="1" call :CheckWin

	:: Get user input
	if not "%Fail%"=="1" if not "%Win%"=="1" goto InputCycle

	goto GameCycle
exit /b

:Init
	:: RTFM: cmd.exe -> setlocal /?
	:: setlocal>nul
	color 07 >nul
	title Minesweeper by nsinreal
	cls

	:: Field characteristics
	call :PrintTheLogo
	echo Generating field. Please, wait...
	set BombsMax=17
	set BombNum=0
	set FlagNum=0

	:: Game just started. No fail, no win
	set Fail=0
	set Win=0
	set GameStep=0
	:: Reset timer
	set "Timer.Started="

	:: Try to create field
	for /L %%x in (1,1,9) do for /L %%y in (1,1,9) do set Field.Fake%%x%%y=?
	for /L %%x in (1,1,9) do for /L %%y in (1,1,9) do set Field.Real%%x%%y=?
	call :GenerateBombs
	call :GenerateField

	:: Let's play
	goto GameCycle
exit /b
