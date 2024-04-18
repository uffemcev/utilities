get-ExecutionPolicy
pause
import-module microsoft.powershell.security
pause
#import-module -Name 'Microsoft.PowerShell.Security' -RequiredVersion 3.0.0.0
if ((get-ExecutionPolicy) -ne 'bypass') {Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force}
get-ExecutionPolicy
pause
