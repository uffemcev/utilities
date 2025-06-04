## Описание

![image](https://github.com/user-attachments/assets/0c8c9d6b-9225-439d-b3b6-314bacea2e86)

Скрипт для установки компонентов и программ.

Присутствует удобный консольный интерфейс, группировка по категориям, поиск по словам, параметры для автоматической установки. По возможности устанавливаются последние версии программ в тихом режиме. Cкрипт проверен на Windows 11 23H2.

<details>
	<summary>Компоненты</summary>
	<table>
		<thead>
			<tr>
				<th align="center">Тег</th>
				<th align="center">Имя</th>
				<th align="center">Компонент</th>
			</tr>
		</thead>
		<tbody>
			<tr>
				<td>all</td>
				<td>all</td>
				<td>Установить всё</td>
			</tr>
			<tr>
				<td>tweaks</td>
    				<td>sophia</td>
				<td><a href="https://github.com/Sophia-Community/SophiApp">SophiApp Tweaker portable</a></td>
			</tr>
			<tr>
				<td></td>
    				<td>redirect</td>
				<td><a href="https://github.com/rcmaehl/MSEdgeRedirect">MSEdgeRedirect</a></td>
			</tr>
			<tr>
				<td>audio</td>
				<td>spotx</td>
				<td><a href="https://github.com/SpotX-Official/SpotX">SpotX - modified Spotify app</a></td>
			</tr>
			<tr>
				<td>web</td>
				<td>chrome</td>
				<td><a href="https://www.google.com/chrome/">Google Chrome</a></td>
			</tr>
			<tr>
				<td></td>
				<td>adguard</td>
				<td><a href="https://adguard.info/ru/welcome.html">AdGuard</a></td>
			</tr>
			<tr>
				<td>games</td>
				<td>steam</td>
				<td><a href="https://store.steampowered.com/">Steam</a></td>
			</tr>
			<tr>
				<td></td>
				<td>discord</td>
				<td><a href="https://discord.com/">Discord</a></td>
			</tr>
			<tr>
				<td></td>
				<td>signal</td>
				<td><a href="https://signalrgb.com/">SignalRGB</a></td>				
			</tr>
			<tr>
				<td>storage</td>
				<td>qbit</td>
				<td><a href="https://www.qbittorrent.org/">qBittorrent</a></td>
			</tr>
			<tr>
				<td></td>
				<td>gdrive</td>
				<td><a href="https://drive.google.com/">Google Drive</a></td>
			</tr>
			<tr>
				<td>video</td>
				<td>codec</td>
				<td><a href="https://codecguide.com/download_kl.htm">K-Lite Codec Pack Full</a></td>
			</tr>
			<tr>
				<td>system</td>
				<td>nvcleanstall</td>
				<td><a href="https://www.techpowerup.com/download/techpowerup-nvcleanstall/">NVCleanstall</a></td>
			</tr>		
			<tr>
				<td></td>
				<td>zip</td>
				<td><a href="https://7-zip.org/">7-zip</a></td>
			</tr>
			<tr>
				<td></td>
				<td>office</td>
				<td><a href="https://github.com/farag2/Install-Office">Office, Word, Excel licensed</a></td>
			</tr>
			<tr>
				<td>other</td>
				<td>win</td>
				<td><a href="https://uupdump.net/">Win 11 24H2 iso</a></td>
			</tr>
			<tr>
				<td></td>
				<td>rufus</td>
				<td><a href="https://github.com/pbatard/rufus">Rufus portable</a></td>
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

## Поддержка
* uffemcev.ton
