#! /bin/sh

currentUser=$(ls -l /dev/console | awk '{ print $3 }')


#Created after apps install and asset tag association
accountRead=/Users/Shared/readyforuser.txt

# Created when user creates account
cleanup=false


/usr/bin/open /Applications/AssetID.app
KillAll zoom.us

## Verify Admin user is logged in
until [ "$currentUser" = "admin" ] && [ -f "$accountRead" ]
do
  sleep 2
done

#Kill AssetID and Launch BGUSer

KillAll AssetID
  sleep 1
/usr/bin/open /Applications/BGUser.app

readPreference() {
  readyforcleanup=$(defaults read /Users/"$currentUser"/Library/Containers/com.blackglove.BGUser/Data/Library/Preferences/com.blackglove.BGUser.plist hasBeenSet)

if [ "$readyforcleanup" = 1 ]; then
  cleanup=true
else
  echo "waiting for user creation..."
fi
}

until  [ $cleanup = true ]
do
  echo "waiting for user creation..."
sleep 5
readPreference
done

echo "User Found"encodedPass=$(defaults read /Users/"$currentUser"/Library/Containers/com.blackglove.BGUser/Data/Library/Preferences/com.blackglove.BGUser.plist password)

encodedUser=$(defaults read /Users/"$currentUser"/Library/Containers/com.blackglove.BGUser/Data/Library/Preferences/com.blackglove.BGUser.plist username)
encodedFullname=$(defaults read /Users/"$currentUser"/Library/Containers/com.blackglove.BGUser/Data/Library/Preferences/com.blackglove.BGUser.plist fullname)
encodedPass=$(defaults read /Users/"$currentUser"/Library/Containers/com.blackglove.BGUser/Data/Library/Preferences/com.blackglove.BGUser.plist password)
#decode user & password
decodedPass=$(openssl enc -base64 -d <<< "$encodedPass")
decodedUser=$(openssl enc -base64 -d <<< "$encodedUser")
decodedFullName=$(openssl enc -base64 -d <<< "$encodedFullname")


# create account

sysadminctl -addUser "$decodedUser" -adminUser admin -adminPassword Odinson11 -fullName "$decodedFullName" -password "$decodedPass"

#Clean Up

# remove autologin
sudo defaults delete /Library/Preferences/com.apple.loginwindow.plist autoLoginUser
sudo rm  /Library/Preferences/com.apple.loginwindow.plist


#remove BG Assets
rm -Rf /Users/"$currentUser"/Library/Containers/com.blackglove.BGUser/
rm -Rf /Applications/AssetID.app
rm -Rf /Applications/BGUser.app
rm -Rf /Library/BlackGlove/
rm /private/etc/kcpassword
rm /Users/Shared/readyforuser.txt
rm /Users/"$currentUser"/Library/LaunchAgents/com.blackglove.*
rm /Library/LaunchDaemons/com.blackglove.*

mv /Users/Shared/com.apple.SetupAssistant.plist /Users/"$decodedUser"/Library/Preferences/com.apple.SetupAssistant.plist
chown "$decodedUser":staff /Users/"$decodedUser"/Library/Preferences/com.apple.SetupAssistant.plist
sleep 5
osascript -e 'tell app "System Events" to restart'



exit 0
