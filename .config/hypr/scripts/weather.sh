until [[ $internetdown == "0" ]]; do
    if ping -c 1 1.1.1.1 &> /dev/null; then
        weatherinfo="$(curl -s https://api.weather.gov/gridpoints/JAX/66,65/forecast | tee >(printf "$(jaq '.properties.periods[0].shortForecast' | tr -d '"')") > >(printf "$(jaq '.properties.periods[0].temperature')F "))"
        echo $weatherinfo
        internetdown="0"
    else
        internetdown="1"
    fi
done