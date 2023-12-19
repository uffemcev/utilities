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
				<th align="center" width="500px">Ссылка</th>
			</tr>
		</thead>
		<tbody>
			<tr>
				<td>All</td>
				<td>all</td>
				<td>Установить всё</td>
				<td></td>
			</tr>
			<tr>
				<td>Tweaks</td>
				<td>dns</td>
				<td>Cloudflare DOH</td>
				<td>https://one.one.one.one/dns</td>
			</tr>
			<tr>
				<td></td>
				<td>dpi</td>
				<td>GoodbyeDPI режим 5</td>
				<td>https://github.com/ValdikSS/GoodbyeDPI</td>
			</tr>
			<tr>
				<td></td>
    				<td>sophia</td>
				<td>SophiApp Tweaker portable</td>
				<td>https://github.com/Sophia-Community/SophiApp</td>
			</tr>
			<tr>
				<td></td>
    				<td>redirect</td>
				<td>MSEdgeRedirect</td>
   				<td>https://github.com/rcmaehl/MSEdgeRedirect</td>
			</tr>
			<tr>
				<td>Programs</td>
				<td>gdrive</td>
				<td>Google Drive</td>
				<td>https://drive.google.com</td>
			</tr>
			<tr>
				<td></td>
				<td>adguard</td>
				<td>AdGuard</td>
				<td>https://adguard.info</td>
			</tr>
			<tr>
				<td></td>
				<td>office</td>
				<td>Office, Word, Excel licensed</td>
				<td>https://github.com/farag2/Office</td>
			</tr>
			<tr>
				<td></td>
				<td>qbit</td>
				<td>qBittorrent</td>
				<td>https://www.qbittorrent.org</td>
			</tr>
			<tr>
				<td></td>
				<td>spotx</td>
				<td>SpotX - modified Spotify app</td>
				<td>https://github.com/amd64fox/SpotX</td>
			</tr>
			<tr>
				<td></td>
				<td>signal</td>
				<td>SignalRGB</td>				
				<td>https://signalrgb.com</td>
			</tr>
			<tr>
				<td></td>
				<td>zip</td>
				<td>7-zip</td>
				<td>https://www.7-zip.org</td>
			</tr>
			<tr>
				<td></td>
				<td>steam</td>
				<td>Steam</td>				
				<td>https://store.steampowered.com</td>
			</tr>
			<tr>
				<td></td>
				<td>codec</td>
				<td>K-Lite Codec Pack Full</td>
				<td>https://codecguide.com/download_k-lite_codec_pack_full.htm</td>
			</tr>
			<tr>
				<td></td>
				<td>vencord</td>
				<td>Vencord - modified Discord app</td>				
				<td>https://github.com/Vendicated/Vencord</td>
			</tr>
			<tr>
				<td></td>
				<td>chrome</td>
				<td>Google Chrome</td>
				<td>https://www.google.com/chrome</td>
			</tr>
			<tr>
				<td>System</td>
				<td>nvidia</td>
				<td>NVCleanstall</td>
				<td>https://www.techpowerup.com/nvcleanstall</td>
			</tr>
			<tr>
				<td>Other</td>
				<td>win</td>
				<td>Win 11 23H2 iso folder</td>
				<td>https://uupdump.net</td>
			</tr>
			<tr>
				<td></td>
				<td>rufus</td>
				<td>Rufus portable</td>				
				<td>https://github.com/pbatard/rufus</td>
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
