## Описание
Скрипт для автоматической установки компонентов и программ. Имеются параметры для интерактивной и автоматической установки. По возможности устанавливаются последние версии программ в тихом режиме. Работоспособность скрипта проверена на Windows 11 22H2.

<details>
	<summary>Компоненты</summary>
	<table>
		<thead>
			<tr>
				<th align="center">Компонент</th>
				<th align="center" width="400px">Описание</th>
				<th align="center">Компонент</th>
				<th align="center" width="400px">Описание</th>
			</tr>
		</thead>
		<tbody>
			<tr>
				<td>all</td>
				<td>Установить всё</td>
				<td>zip</td>
				<td>7-zip</td>
			</tr>
			<tr>
				<td>dns</td>
				<td>Cloudflare DNS-over-HTTPS</td>
				<td>gdrive</td>
				<td>Google Drive</td>
			</tr>
			<tr>
				<td>update</td>
				<td>Обновление всех приложений на пк</td>
				<td>adguard</td>
				<td>AdGuard</td>
			</tr>
			<tr>
				<td>office</td>
				<td>Office, Word, Excel 365 mondo volume license</td>
				<td>blender</td>
				<td>Blender</td>
			</tr>
			<tr>
				<td>spotx</td>
				<td>Spotify мод</td>
				<td>open</td>
				<td>OpenRGB + uffemcev rgb</td>
			</tr>
			<tr>
				<td>dpi</td>
				<td>GoodbyeDPI, режим 5 + обновление blacklist</td>
				<td>codec</td>
				<td>K-Lite Codec Pack Full, ручная установка</td>
			</tr>
			<tr>
				<td>chrome</td>
				<td>Google Chrome</td>
				<td>nvidia</td>
				<td>NVCleanstall, ручная установка</td>
			</tr>
			<tr>
				<td>discord</td>
				<td>Discord</td>
				<td>steam</td>
				<td>Steam</td>
			</tr>
			<tr>
				<td>qbit</td>
				<td>qBittorrent</td>
				<td>sophia</td>
				<td>SophiApp Tweaker portable</td>
			</tr>
			<tr>
				<td>win</td>
				<td>Windows 11 22H2 iso folder</td>
				<td>rufus</td>
				<td>Rufus portable</td>
			</tr>
		</tbody>
	</table>
</details>

## Запуск
Интерактивный выбор компонентов для установки:
```
&([ScriptBlock]::Create((irm uffemcev.github.io/utilities/script.ps1)))
```
Автоматическая установка указанных компонентов:
```
&([ScriptBlock]::Create((irm uffemcev.github.io/utilities/script.ps1))) store office chrome
```

## Ссылки
* [Rufus](https://github.com/pbatard/rufus)
* [SophiApp](https://github.com/Sophia-Community/SophiApp)
* [uffemcev rgb](https://github.com/uffemcev/rgb)
* [Winget installer](https://github.com/asheroto/winget-installer)
* [GoodbyeDPI](https://github.com/ValdikSS/GoodbyeDPI)
* [MAS](https://github.com/massgravel/Microsoft-Activation-Scripts)
* [SpotX](https://github.com/amd64fox/SpotX)
* [Office](https://github.com/farag2/Office)
