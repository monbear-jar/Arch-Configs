installconfig () {
    sudo pacman -Syu hyprlock hypridle fontforge python
    echo "Linking hypr files into config directory..."
    readarray -d '' array < <(find . -name hypr*.conf -print0)

    for file in "${array[@]}"; do
        filelink="$(pwd | tr -d '\n')"
        filelink+="${file:1}"
        ln -s "${filelink}" "${HOME}${file:1}"
    done

    sudo mkdir -p /usr/local/share/images
    sudo cp ./usr/local/share/images/theendofevangelion.jpg /usr/local/share/images

    echo "Copying wofi files into config directory..."

    workingDir= "$(pwd | tr -d '\n')"

    mkdir -p $HOME/.config/wofi
    cp $workingDir/wofi/* $HOME/.config/wofi

    echo "Setting up fonts..."

    sudo mkdir -p /usr/local/share/fonts/otf/Urbaniva/
    sudo cp ./usr/local/share/fonts/otf/Urbaniva/UrbanivaRegular-LV7gg.otf /usr/local/share/fonts/otf/Urbaniva

    sh ./usr/local/share/fonts/ttf/NIS-Fonts/fontgrabber.sh
    sh ./usr/local/share/fonts/ttf/EVA-Matisse/fontextracter.sh

    echo "Configured"
}

installpowersaver () {
    sudo pacman -Syu tlp
    echo "Setting up powersaving..."

    sed -i "s/monbear/$USER/" ./etc/systemd/system/powersave.service
    sudo cp ./etc/systemd/system/powersave.service /etc/systemd/system/powersave.service
    sudo cp ./etc/udev/rules.d/99-powersave.rules /etc/udev/rules.d/99-powersave.rules
    sudo udevadm control --reload-rules && sudo udevadm trigger
    sudo systemctl enable tlp.service && sudo systemctl start tlp.service

    echo "Setup powersaving!"
}

installevalockscreen () {
    sudo pacman -Syu hyprlock fontforge python
    echo "Setting up fonts..."

    sh ./usr/local/share/fonts/ttf/NIS-Fonts/fontgrabber.sh
    sh ./usr/local/share/fonts/ttf/EVA-Matisse/fontextracter.sh

    echo "Linking hyprlock conf..."
    filelink="$(pwd | tr -d '\n')"
    ln -s $filelink/hypr/hyprlock.conf $HOME/.config/hypr/hyprlock.conf

    sudo mkdir -p /usr/local/share/images
    sudo cp ./usr/local/share/images/theendofevangelion.jpg /usr/local/share/images

    echo "Setup EVA lockscreen!"
}

fixtrackpad () {
    sudo pacman -Syu acpica cpio
    cd /tmp

    echo "Grabbing and decompiling DSDT file..."
    sudo cat /sys/firmware/acpi/tables/DSDT > dsdt.aml
    iasl -d dsdt.aml

    echo "Replacing text..."
    sed -i -z 's/If ((^^^PCI0.LPC0.H_EC.ECRD (RefOf (^^^PCI0.LPC0.H_EC.TPTY)) == 0x02))/Else/2' dsdt.dsl
    sed -i -z 's:CDAT://CDAT:8' dsdt.dsl
    echo "Compiling DSDT file..."
    iasl -sa dsdt.dsl

    echo "Setting up CPIO table..."
    mkdir -p ~/kernel/firmware/acpi
    cd ~ && cp /tmp/dsdt.aml ~/kernel/firmware/acpi
    find kernel | cpio -H newc --create > acpi_override
    sudo cp acpi_override /boot

    echo "Configurating GRUB..."
    sudo sed -i '8iGRUB_EARLY_INITRD_LINUX_CUSTOM="acpi_override"' /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg

    echo -e "\nYou need to restart for the trackpad fix to apply. Would you like to do that now? (Y/n)"
    read answer

    if [[ "${answer,,}" == 'y' ]]; then
        sudo reboot
    elif [[ "${answer,,}" == 'n' ]]; then
        exit
    elif [[ "${answer,,}" == '' ]]; then
        sudo reboot
    fi
}

bold () {
    formattedtext="${1:0:1}. \033[1m${1:0:1}\033[0m${1:1}"
    echo -e "${formattedtext}"
}
echo -e "What would you like to install?\n1. Config files\n2. Power config\n3. Only install EVA lockscreen + fonts\n4. Fix trackpad only"
bold "All"
bold "Exit"
echo -e "\nType the options you want below(ex. 'A', '1', '12'):"
read answer

listoptions=('1','2','3','4','A','E')

answerarray=()
for (( i = 0; i < "${#answer}"; i++)); do
    char="${answer:i:1}"
    if [[ " ${listoptions[*]} " =~ ${char} ]]; then
        answerarray+=("${char}")
    elif [[ ! " ${listoptions[*]} " =~ ${char} ]]; then
        echo "Improper value! Option must be in list."
        exit
    fi
done

for i in "${answerarray[@]}"; do
    case $i in
        "1")
            installconfig
        ;;
        "2")
            installpowersaver
        ;;
        "3")
            installevalockscreen
        ;;
        "4")
            fixtrackpad
        ;;
        "A")
            installconfig
            installpowersaver
            fixtrackpad
        ;;
        "E")
            exit
        ;;
    esac
done
