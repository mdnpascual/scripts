@ECHO OFF
SetLocal EnableDelayedExpansion

//Pipe twitch steams/VODs to VLC
streamlink --player="D:\Program Files (x86)\VideoLAN\VLC\vlc.exe" --player-passthrough hls https://www.twitch.tv/dota2ti best

//Steam folder backup
//Copy new files only
robocopy <sourcepath> <destination path> /E /XO /XN

//Copy new and updated files
robocopy <sourcepath> <destination path> /E /XO

Find what: (([^\n]*\n){x})[^\n]*\n - replace every nth line if you replace a by x - 1 
Replace with: $1
Use if whole group: $0

//Find Duplicates (Sorted)
Find What: ^(.*)(\n\1)+$
Replace with: $1

//Filter Lines only with word
Find What: (?!.*[WORDTOFINDHERE])^.*$
Replace with: [empty]

//Game keys regexes
Only keys:
Find what: ..*\t
Replace with: [empty]
Save to file:
Find what: (\t)(.+)
Replace With: \r\n$2\r\n

// COPY ONLY NEW FILES
xcopy %SourceDir% %TargetDir% /i /d /y /e

//Gtuner Combo to XY Values
Find what: (([^\n]*\n){2})[^\n]*\n 
Replace with: $1
Find what: (.+STICK_1_X, )(.+)(\)\;\n)(.+STICK_1_Y, )(.+)(\)\;\n) 
Replace with: $2 $5\n

//Powershell admin
Start-Process powershell -Verb runAs

//Deploying firebase hosting

  // IF NODE.JS IS NOT YET INSTALLED
  npm install -g firebase-tools

firebase login
firebase init
firebase list
firebase deploy --project <Project_ID>

// UTorrent sequential downloading
Press shift+F2 (hold them for the next step)
Go to Options -> Preferences -> Advanced
See uTorrent settings with opened parameters bt.sequential_download

Butterflow command line:
./butterflow -v -vs 1920:1080 -sw -r 4x input.mp4

Remove kijiji ads with stylish:
div.top-feature, div.third-party {display:none!important}
