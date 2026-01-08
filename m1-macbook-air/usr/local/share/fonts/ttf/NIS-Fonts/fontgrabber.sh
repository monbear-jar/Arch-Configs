regular="/usr/local/share/fonts/ttf/NIS-Fonts/NIS-JTC-Win-M9.ttf"
condensed="/usr/local/share/fonts/ttf/NIS-Fonts/NIS-JTC-Win-M9-Condensed.ttf"

if [[ -f $condensed && -f $regular ]]; then
    echo "Fonts already there!"
    exit
elif [[ ! -f $condensed && ! -f $regular ]]; then 
    if [ -d "/usr/local/share/fonts/ttf/NIS-Fonts" ]; then
        wget https://archive.org/download/NISFonts/NIS-JTC-Win-M9-Condensed.ttf
        wget https://archive.org/download/NISFonts/NIS-JTC-Win-M9.ttf
        python fontfixer.py

        sudo cp NIS-JTC-Win-M9.ttf $regular
        echo "Copied NIS-JTC-Win-M9.ttf to $regular"

        sudo cp NIS-JTC-Win-M9-Condensed.ttf $condensed
        echo "Copied NIS-JTC-Win-M9-Condensed.ttf to $condensed"
    elif [ ! -d "/usr/local/share/fonts/ttf/NIS-Fonts" ]; then 
        sudo mkdir -p "/usr/local/share/fonts/ttf/NIS-Fonts"

        wget https://archive.org/download/NISFonts/NIS-JTC-Win-M9-Condensed.ttf
        wget https://archive.org/download/NISFonts/NIS-JTC-Win-M9.ttf
        python fontfixer.py

        sudo cp NIS-JTC-Win-M9.ttf $regular
        echo "Copied NIS-JTC-Win-M9.ttf to $regular"

        sudo cp NIS-JTC-Win-M9-Condensed.ttf $condensed
        echo "Copied NIS-JTC-Win-M9-Condensed.ttf to $condensed"
    fi

    echo "Setting up permissions..."

    sudo chmod 555 /usr/local/share/fonts
    sudo chmod 555 /usr/local/share/fonts/*
    sudo chmod 444 /usr/local/share/fonts/ttf/NIS-Fonts/*

    echo "Setup permissions"
fi

echo "Done!"

