#!/usr/bin/env zsh

zmodload zsh/zutil
zparseopts -D -E -F -- -cold=cold || exit 1

optColdBoot='-no-snapshot-load'
if [ -z $cold ]; then
	optColdBoot=''
fi

autoload colors; colors


# Restarting docker services
# /usr/bin/docker compose -f /home/flappeh/Kerja/Projects/PiWalletBot/pi-tele-bot/docker/docker-compose.yml up -d --force-recreate

# Changing android directory
echo "$fg[green]\n# Making sure owner of .android directory"
sudo chown -R $USER:$USER /home/$USER/.android
echo "$fg[blue]\n# Exporting Xvfb display"
Xvfb :1 -screen 0 1280x1024x24 &
export DISPLAY=:1


#-----
echo "$fg[green]\n# Searching for AVDs$reset_color"

avds=$(emulator -list-avds | grep avd33)
echo "$fg[yellow]👇 Found:"
echo "$fg[blue]$avds$reset_color"
avd=$(sudo -u flappeh echo $avds | head -1)

# Remove avd locks
echo "$fg[green]\n# Removing all locks"
sudo rm -rf /home/$USER/.android/avd/$avd.avd/*.lock

echo "$fg[green]\n# Starting '$avd'$reset_color"
emulator @$avd -netdelay none -netspeed full -no-snapshot-load -dns-server 8.8.8.8 -gpu auto -cores 4 -memory 1568 -no-audio -no-window -accel on $optColdBoot  &

waitSeconds=45
if [ -z $cold ]; then
	waitSeconds=10
fi
# Countdown
while [ $waitSeconds -gt 0 ]; do
   echo -ne "Countdown: $waitSeconds\033[0K\r"
   sleep 1
   : $((waitSeconds--))
done

#-----
pipe="/tmp/emupipe"
echo "$fg[green]\n# Creating named pipe '$pipe'$reset_color"

echo "$fg[yellow]--Removing any existing$reset_color"
rm -f $pipe
echo "$fg[yellow]--Creating new pipe$reset_color"
mkfifo $pipe

#----
listenPort=15555
forwardPort=5555
echo "$fg[green]\n# Forwarding port $fg[magenta]$listenPort$fg[green] to $fg[magenta]$forwardPort$reset_color"

ip=$(ip -4 a show eno1 | grep -Po 'inet \K[0-9.]+')
echo "$fg[yellow]--$fg[gray]From the VM run $fg[cyan]adb connect $ip:$listenPort'$reset_color"

echo "$fg[green]\nListening...(keep terminal open)$reset_color"

nc -kl $listenPort 0<$pipe | nc 127.0.0.1 $forwardPort > $pipe
