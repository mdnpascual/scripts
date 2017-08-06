@ECHO OFF
SetLocal EnableDelayedExpansion

//Pipe twitch steams/VODs to VLC
streamlink --player="D:\Program Files (x86)\VideoLAN\VLC\vlc.exe" --player-passthrough hls https://www.twitch.tv/dota2ti best
