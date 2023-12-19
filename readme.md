## Описание
Скрипт для установки компонентов и программ. Присутствует удобный интерфейс, группировка по категориям, параметры для интерактивной/автоматической установки. По возможности устанавливаются последние версии программ в тихом режиме. Работоспособность скрипта проверена на Windows 11 23H2.

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
				<td>Cloudflare DOH</td>
				<td>dpi</td>
				<td>GoodbyeDPI режим 5 https://github.com/ValdikSS/GoodbyeDPI</td>
			</tr>
			<tr></tr>
			<tr>
				<td></td>
    				<td>sophia</td>
				<td>SophiApp Tweaker portable https://github.com/Sophia-Community/SophiApp</td>
				<td>redirect</td>
				<td>MSEdgeRedirect https://github.com/rcmaehl/MSEdgeRedirect</td>
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
				<td>Office, Word, Excel licensed https://github.com/farag2/Office</td>
				<td>qbit</td>
				<td>qBittorrent</td>
			</tr>
			<tr></tr>
			<tr>
				<td></td>
				<td>spotx</td>
				<td>SpotX - modified Spotify app https://github.com/amd64fox/SpotX</td>
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
				<td>codec</td>
				<td>K-Lite Codec Pack Full</td>
				<td>vencord</td>
				<td>Vencord - modified Discord app https://github.com/Vendicated/Vencord</td>
			</tr>
			<tr></tr>
			<tr>
				<td></td>
				<td>chrome</td>
				<td>Google Chrome</td>
				<td></td>
				<td></td>
			</tr>
			<tr><td></td><td></td><td></td><td></td><td></td></tr>
			<tr>
				<td>System</td>
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
				<td>Rufus portable https://github.com/pbatard/rufus</td>
			</tr>
		</tbody>
	</table>
</details>

## Запуск
Интерактивный выбор компонентов для установки:
```powershell
&([ScriptBlock]::Create((irm uffemcev.github.io/utilities/script.ps1)))
```
Автоматическая установка компонентов по тегам и именам:
```powershell
&([ScriptBlock]::Create((irm uffemcev.github.io/utilities/script.ps1))) system other office chrome
```

## Ссылки
* [Winget install](https://github.com/asheroto/winget-install)
* [MAS](https://github.com/massgravel/Microsoft-Activation-Scripts)
