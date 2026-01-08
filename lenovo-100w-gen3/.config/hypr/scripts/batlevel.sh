batlevel="$(cat /sys/class/power_supply/BAT0/capacity)"
status="$(cat /sys/class/power_supply/BAT0/status)"

declare -A batlevels=( ["100"]="󰁹" ["90"]="󰂂" ["80"]="󰂀" ["70"]="󰂀" ["60"]="󰁿" ["50"]="󰁾" ["40"]="󰁽" ["30"]="󰁼" ["20"]="󰁻" ["10"]="󰂎" )

if [[ $status == "Discharging" ]]; then 
    echo "${batlevels[$(($batlevel/10))0]}$batlevel%"
elif [[ $status == "Charging" ]]; then
    echo "󰉁 $batlevel%"
fi