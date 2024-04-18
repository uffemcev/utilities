get-ExecutionPolicy
pause
import-module microsoft.powershell.security
if ((get-ExecutionPolicy) -ne 'bypass') {Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force}
get-ExecutionPolicy
pause
