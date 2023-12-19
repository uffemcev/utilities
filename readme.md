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
				<th align="center" width="500px">Источник</th>
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
				<td>one.one.one.one/dns</td>
			</tr>
			<tr>
				<td></td>
				<td>dpi</td>
				<td>GoodbyeDPI режим 5</td>
				<td>github.com/ValdikSS/GoodbyeDPI</td>
			</tr>
			<tr>
				<td></td>
    				<td>sophia</td>
				<td>SophiApp Tweaker portable</td>
				<td>github.com/Sophia-Community/SophiApp</td>
			</tr>
			<tr>
				<td></td>
    				<td>redirect</td>
				<td>MSEdgeRedirect</td>
   				<td>github.com/rcmaehl/MSEdgeRedirect</td>
			</tr>
			<tr>
				<td>Audio</td>
				<td>spotx</td>
				<td>SpotX - modified Spotify app</td>
				<td>github.com/amd64fox/SpotX</td>
			</tr>
			<tr>
				<td></td>
				<td>vencord</td>
				<td>Vencord - modified Discord app</td>				
				<td>github.com/Vendicated/Vencord</td>
			</tr>
			<tr>
				<td>Web</td>
				<td>chrome</td>
				<td>Google Chrome</td>
				<td>google.com/chrome</td>
			</tr>
			<tr>
				<td></td>
				<td>adguard</td>
				<td>AdGuard</td>
				<td>adguard.info</td>
			</tr>
			<tr>
				<td>Games</td>
				<td>steam</td>
				<td>Steam</td>				
				<td>store.steampowered.com</td>
			</tr>
			<tr>
				<td></td>
				<td>signal</td>
				<td>SignalRGB</td>				
				<td>signalrgb.com</td>
			</tr>
			<tr>
				<td>Storage</td>
				<td>qbit</td>
				<td>qBittorrent</td>
				<td>qbittorrent.org</td>
			</tr>
			<tr>
				<td></td>
				<td>gdrive</td>
				<td>Google Drive</td>
				<td>drive.google.com</td>
			</tr>
			<tr>
				<td>Video</td>
				<td>codec</td>
				<td>K-Lite Codec Pack Full</td>
				<td>codecguide.com/download_k-lite_codec_pack_full.htm</td>
			</tr>
			<tr>
				<td>System</td>
				<td>nvidia</td>
				<td>NVCleanstall</td>
				<td>techpowerup.com/nvcleanstall</td>
			</tr>
			<tr>
				<td></td>
				<td>zip</td>
				<td>7-zip</td>
				<td>7-zip.org</td>
			</tr>
			<tr>
				<td></td>
				<td>office</td>
				<td>Office, Word, Excel licensed</td>
				<td>github.com/farag2/Office</td>
			</tr>
			<tr>
				<td>Other</td>
				<td>win</td>
				<td>Win 11 23H2 iso folder</td>
				<td>uupdump.net</td>
			</tr>
			<tr>
				<td></td>
				<td>rufus</td>
				<td>Rufus portable</td>				
				<td>github.com/pbatard/rufus</td>
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
