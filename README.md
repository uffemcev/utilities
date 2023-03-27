Скрипт понимает только нолики, единички и enter:
enter - ввод / пропуск
0 - нет
1 - да
	
Для работы встроенного функционала winget на свежей системе необходимо обновить его в ms store вручную или через параметр -store
	
Ручной выбор компонентов для установки:
powershell -command "Set-ExecutionPolicy Bypass -Scope Process -Force; &{iex (iwr https://raw.githubusercontent.com/uffemcev/utilities/main/utilities.ps1); manual}"
powershell -command "Set-ExecutionPolicy Bypass -Scope Process -Force; &{. .\utilities.ps1; manual}"
&{iex (iwr https://raw.githubusercontent.com/uffemcev/utilities/main/utilities.ps1); manual}
&{. .\utilities.ps1; manual}
	
Автоматическая установка указанных компонентов:
powershell -command "Set-ExecutionPolicy Bypass -Scope Process -Force; &{iex (iwr https://raw.githubusercontent.com/uffemcev/utilities/main/utilities.ps1); auto -store -office -chrome}"
powershell -command "Set-ExecutionPolicy Bypass -Scope Process -Force; &{. .\utilities.ps1; auto -store -office -chrome}"
&{iex (iwr https://raw.githubusercontent.com/uffemcev/utilities/main/utilities.ps1); auto -store -office -chrome}
&{. .\utilities.ps1; auto -store -office -chrome}
	
Автоматическая установка всех компонентов:
powershell -command "Set-ExecutionPolicy Bypass -Scope Process -Force; &{iex (iwr https://raw.githubusercontent.com/uffemcev/utilities/main/utilities.ps1); auto -all}"
powershell -command "Set-ExecutionPolicy Bypass -Scope Process -Force; &{. .\utilities.ps1; auto -all}"
&{iex (iwr https://raw.githubusercontent.com/uffemcev/utilities/main/utilities.ps1); auto -all}
&{. .\utilities.ps1; auto -all}
