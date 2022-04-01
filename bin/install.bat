@echo off

:do_prompt
  choice /C YN /M "IF THE 'rhel8' DISTRO ALREADY EXISTS IT WILL BE REMOVED!!!"
  IF ERRORLEVEL 2 goto do_exit 
  IF ERRORLEVEL 1 goto do_install
  goto do_prompt

:do_install
  wsl --terminate rhel8 >nul 2>&1
  wsl --unregister rhel8 >nul 2>&1
  wsl --import rhel8 %USERPROFILE%\WSL2\systems\rhel8 .\rhel8-wsl-container.tar

  echo rhel8 should now be available in Windows Terminal (may require restart)
  echo Otherwise you may start it manually with `wsl -d rhel8`
  echo Starting rhel8 distro..
  wsl -d rhel8

:do_exit
  echo Exiting...
  pause
  exit /b
