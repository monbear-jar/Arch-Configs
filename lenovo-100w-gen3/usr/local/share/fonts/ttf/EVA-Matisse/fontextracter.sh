classicfont="/usr/local/share/fonts/ttf/EVA-Matisse/EVA-Matisse_Classic.ttf"
standardfont="/usr/local/share/fonts/ttf/EVA-Matisse/EVA-Matisse_Standard.ttf"

classicfontupper="/usr/local/share/fonts/ttf/EVA-Matisse/EVA-MATISSE_CLASSIC.TTF"
standardfontupper="/usr/local/share/fonts/ttf/EVA-Matisse/EVA-MATISSE_STANDARD.TTF"

function setupfonts() {
    link="https://archive.org/download/qjwi3h/qjwi3h.iso"
    wget -O evafonts.iso $link
    7z x -oEVA-ISO-Files evafonts.iso
    wine EVA-ISO-Files/EVAMatisseInstaller.exe
    if [ -d "/usr/local/share/fonts/ttf/EVA-Matisse" ]; then
        sudo cp ~/.wine/drive_c/windows/Fonts/EVA-Matisse_Classic.ttf /usr/local/share/fonts/ttf/EVA-Matisse
        sudo cp ~/.wine/drive_c/windows/Fonts/EVA-Matisse_Standard.ttf /usr/local/share/fonts/ttf/EVA-Matisse
    elif [ ! -d "/usr/local/share/fonts/ttf/EVA-Matisse" ]; then 
        sudo mkdir -p /usr/local/share/fonts/ttf/EVA-Matisse
        sudo cp ~/.wine/drive_c/windows/Fonts/EVA-Matisse_Classic.ttf /usr/local/share/fonts/ttf/EVA-Matisse
        sudo cp ~/.wine/drive_c/windows/Fonts/EVA-Matisse_Standard.ttf /usr/local/share/fonts/ttf/EVA-Matisse
    fi

    sudo chmod 555 /usr/local/share/fonts
    sudo chmod 555 /usr/local/share/fonts/*
    sudo chmod 444 /usr/local/share/fonts/ttf/EVA-Matisse/*
    rm -rf EVA-ISO-Files
    rm evafonts.iso
}

if [[ -f $standardfont && -f $classicfont ]]; then
    echo "Fonts already there!"
    exit
elif [[ -f $standardfontupper && -f $classicfontupper ]]; then
    echo "Fonts already there!"
    exit
elif [[ ! -f $standardfont && ! -f $classicfont ]]; then 
    if [[ ! -f $standardfontupper && ! -f $classicfontupper ]]; then 
        setupfonts
    fi
fi

