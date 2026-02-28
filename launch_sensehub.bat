@echo off
REM Launch Sensehub AutoM/L from Windows (no RStudio needed)
REM Double-click this file, or run from a command prompt.
REM Requires R (4.2+) to be installed and Rscript on your PATH.

cd /d "%~dp0"

where Rscript >nul 2>nul
if errorlevel 1 (
  echo Rscript not found. Please install R from https://cran.r-project.org/
  echo and ensure "Add R to PATH" was checked, or run from RStudio: source("launch_sensehub.R")
  pause
  exit /b 1
)

echo Validating and starting Sensehub...
Rscript -e "source('launch_sensehub.R')"
if errorlevel 1 (
  echo.
  echo Something went wrong. See the messages above or open TROUBLESHOOTING.md
  pause
  exit /b 1
)

pause
