@echo off
call ./setvar gitremote git config --get remote.origin.url
echo %gitremote%
if %gitremote% == "https://github.com/brycebjork/Combinator_v9.git" (
	echo ------------------------------------------------
	echo --                                            --
	echo --     COMMITTING CHANGES TO MASTER           --
	echo --                                            --
	echo ------------------------------------------------
    ::call ./autocommit
) ELSE (
	echo ------------------------------------------------
	echo --                                            --
	echo --          UPDATING FROM MASTER              --
	echo --                                            --
	echo ------------------------------------------------
    ::call ./update
)