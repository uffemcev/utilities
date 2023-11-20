## Описание
Скрипт для автоматической установки компонентов и программ. Имеются параметры для интерактивной и автоматической установки. По возможности устанавливаются последние версии программ в тихом режиме. Работоспособность скрипта проверена на Windows 11 22H2.

<details>
	<summary>Компоненты</summary>
	<table>
		<thead>
			<tr>
				<th align="center">Тег</th>
				<th align="center">Имя</th>
				<th align="center" width="400px">Описание</th>
				<th align="center">Имя</th>
				<th align="center" width="400px">Описание</th>
			</tr>
		</thead>
		<tbody>
			<tr>
				<td>All</td>
				<td>all</td>
				<td>Установить всё</td>
				<td></td>
				<td></td>
			</tr>
			<tr><td></td><td></td><td></td><td></td><td></td></tr>
			<tr>
				<td>Tweaks</td>
				<td>dns</td>
				<td>Cloudflare DNS-over-HTTPS</td>
				<td>sophia</td>
				<td>SophiApp Tweaker portable</td>
			</tr>
			<tr><td></td><td></td><td></td><td></td><td></td></tr>
			<tr>
				<td>Programs</td>
				<td>gdrive</td>
				<td>Google Drive</td>
				<td>adguard</td>
				<td>AdGuard</td>
			</tr>
			<tr></tr>
			<tr>
				<td></td>
				<td>office</td>
				<td>Office, Word, Excel 365 licensed</td>
				<td>qbit</td>
				<td>qBittorrent</td>
			</tr>
			<tr></tr>
			<tr>
				<td></td>
				<td>spotx</td>
				<td>SpotX</td>
				<td>signal</td>
				<td>SignalRGB</td>
			</tr>
			<tr></tr>
			<tr>
				<td></td>
				<td>zip</td>
				<td>7-zip</td>
				<td>steam</td>
				<td>Steam</td>
			</tr>
			<tr></tr>
			<tr>
				<td></td>
				<td>dpi</td>
				<td>GoodbyeDPI, режим 5</td>
				<td>codec</td>
				<td>K-Lite Codec Pack Full</td>
			</tr>
			<tr></tr>
			<tr>
				<td></td>
				<td>chrome</td>
				<td>Google Chrome</td>
				<td>discord</td>
				<td>Discord</td>
			</tr>
			<tr><td></td><td></td><td></td><td></td><td></td></tr>
			<tr>
				<td>Drivers</td>
				<td>nvidia</td>
				<td>NVCleanstall</td>
				<td></td>
				<td></td>
			</tr>
			<tr><td></td><td></td><td></td><td></td><td></td></tr>
			<tr>
				<td>Other</td>
				<td>win</td>
				<td>Win 11 23H2 iso folder</td>
				<td>rufus</td>
				<td>Rufus portable</td>
			</tr>
		</tbody>
	</table>
</details>

## Запуск
Интерактивный выбор компонентов для установки:
```powershell
&([ScriptBlock]::Create((irm uffemcev.github.io/utilities/script.ps1)))
```
Автоматическая установка указанных компонентов:
```powershell
&([ScriptBlock]::Create((irm uffemcev.github.io/utilities/script.ps1))) drivers office chrome
```

## Ссылки
* [Rufus](https://github.com/pbatard/rufus)
* [SophiApp](https://github.com/Sophia-Community/SophiApp)
* [Winget install](https://github.com/asheroto/winget-install)
* [GoodbyeDPI](https://github.com/ValdikSS/GoodbyeDPI)
* [MAS](https://github.com/massgravel/Microsoft-Activation-Scripts)
* [SpotX](https://github.com/amd64fox/SpotX)
* [Office](https://github.com/farag2/Office)
