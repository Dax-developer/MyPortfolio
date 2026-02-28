@echo off
echo ==================================================
echo   Portfolio GitHub Push Script (Secure Version)
echo ==================================================
echo.

:: Check if git is installed
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Git is not installed or not in PATH.
    echo Please download and install Git from: https://git-scm.com/
    pause
    exit /b
)

:: Initialize Git if not already
if not exist .git (
    echo [*] Initializing Git repository...
    git init
)

:: Add remote origin if not exists
git remote -v | findstr "origin" >nul
if %errorlevel% neq 0 (
    echo [*] Adding remote origin: https://github.com/Dax-developer/MyPortfolio.git
    git remote add origin https://github.com/Dax-developer/MyPortfolio.git
)

:: Add files safely (respecting .gitignore)
echo [*] Adding files (Secrets are automatically ignored by .gitignore)...
git add .

:: Commit
echo [*] Creating initial commit...
git commit -m "Initial commit: Professional Portfolio with Dynamic Footer and Admin Panel"

:: Push
echo [*] Pushing to GitHub (main branch)...
git branch -M main
git push -u origin main

echo.
echo ==================================================
echo   Done! Your code is now safe on GitHub.
echo ==================================================
pause
