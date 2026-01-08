weatherinfo="$(curl -s https://api.weather.gov/gridpoints/JAX/66,65/forecast | tee >(echo "$(jaq '.properties.periods[0].shortForecast' | tr -d '"')") > >(echo "$(jaq '.properties.periods[0].temperature')F"))"
echo $weatherinfo
