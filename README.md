## Описание
* Скрипт для автоматической установки компонентов
* Имеются параметры для ручной и авто установки
* Автоматически устанавливаются последнии версии
* Принимаются замечания, предложения и вопросы
* Работоспособность проверена на Windows 11 22H2
* Необходим winget, обычно встроен в Windows 10/11

## Запуск
* Интерактивный выбор компонентов для установки:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; &{iex (iwr https://raw.githubusercontent.com/uffemcev/utilities/main/utilities.ps1); manual}
```
* Автоматическая установка указанных компонентов:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; &{iex (iwr https://raw.githubusercontent.com/uffemcev/utilities/main/utilities.ps1); auto -store -office -chrome}
```
* Автоматическая установка всех компонентов::
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; &{iex (iwr https://raw.githubusercontent.com/uffemcev/utilities/main/utilities.ps1); auto -all}
```

## Компоненты
<details>
<summary>Список</summary>

* store - Обновление приложений в MS store, полезно на свежеустановленной системе для инициализации winget
* office - Office, Word, Excel 365 mondo volume license
* spotx - Spotify мод
* dpi - GoodbyeDPI, по умолчанию активируется режим 5
* directx - DirectX
* vcredist - Microsoft Visual C++ 2015-2022
* chrome - Google Chrome
* discord - Discord
* steam - Steam
* qbit - qBittorrent
* zip - 7zip
* gdrive - Google Drive
* adguard - AdGuard
* blender - Blender
* signal - Signal RGB
* codec - K-Lite Codec Pack Full, ручная установка
* nvidia - NVCleanstall, ручная установка

</details>

## Ссылки
* [GoodbyeDPI](https://github.com/ValdikSS/GoodbyeDPI)
* [MAS](https://github.com/massgravel/Microsoft-Activation-Scripts)
* [SpotX](https://github.com/amd64fox/SpotX)
* [Office](https://github.com/farag2/Office)
