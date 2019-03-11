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
