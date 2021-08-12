#! /bin/sh

KillAll AssetID ;

touch /Users/Shared/readyforuser.txt ;
rm -Rf /Applications/AssetID.app ;
osascript -e 'tell app "System Events" to restart'

exit 0
