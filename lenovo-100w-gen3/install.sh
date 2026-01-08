installconfig () {
    sudo pacman -Syu hyprlock hypridle fontforge python
    echo "Linking hypr files into config directory..."

    readarray -d '' array < <(find . -name hypr*.conf -print0)

    if [ ! -d "~/.config/hypr/backup" ]; then
        mkdir ~/.config/hypr/backup
    fi

    for file in "${array[@]}"; do
        filelink="${HOME}${file:1}"
        if [ -f $filelink ]; then
            mv $filelink ~/.config/hypr/backup
        elif [ -L $filelink ]; then
            rm $filelink
        fi
    done

    for file in "${array[@]}"; do
        filelink="$(pwd | tr -d '\n')"
        filelink+="${file:1}"
        ln -s "${filelink}" "${HOME}${file:1}"
    done

    ln -s "$(pwd | tr -d '\n')/.config/hypr/scripts" "${HOME}/.config/hypr/scripts"

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

    if [ ! -d "~/.config/hypr/backup" ]; then
        mkdir ~/.config/hypr/backup
    fi

    file="${HOME}${file:1}"
    if [ -f $file ]; then
        mv $file ~/.config/hypr/backup
    elif [ -L $file ]; then
        rm $file
    fi

    filelink="$(pwd | tr -d '\n')"
    ln -s $filelink/.config/hypr/hyprlock.conf $HOME/.config/hypr/hyprlock.conf

    sudo mkdir -p /usr/local/share/images
    sudo cp ./usr/local/share/images/theendofevangelion.jpg /usr/local/share/images

    echo "Setup EVA lockscreen!"
}

fixtrackpad () {
    if grep 'GRUB_EARLY_INITRD_LINUX_CUSTOM="acpi_override"' /etc/default/grub; then
        echo "Fix already installed!"
    elif ! grep 'GRUB_EARLY_INITRD_LINUX_CUSTOM="acpi_override"' /etc/default/grub; then
        sudo pacman -Syu acpica cpio
        cd /tmp

        echo "Grabbing and decompiling DSDT file..."
        sudo cat /sys/firmware/acpi/tables/DSDT > dsdt.aml
        iasl -d dsdt.aml

        stringcount="$(grep -c 'If ((^^^PCI0.LPC0.H_EC.ECRD (RefOf (^^^PCI0.LPC0.H_EC.TPTY)) == 0x02))' /tmp/dsdt.dsl)"

        if [ $stringcount -lt "2" ]; then
            echo "Already patched!"
        elif [ $stringcount = "2" ]; then
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
            sudo sed -i '$a\GRUB_EARLY_INITRD_LINUX_CUSTOM="acpi_override"' /etc/default/grub
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
        fi
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
            if [ -L "${HOME}/.config/hypr/hyprland.conf" ]; then
                echo "Links already exists!"
            elif [ -f "${HOME}/.config/hypr/hyprland.conf" ] || [ ! -f "${HOME}/.config/hypr/hyprland.conf"]; then 
                echo "This will install/overwrite your current hypr confs. Are you sure you want to install this? (y/N)"
                read answer
                if [[ "${answer,,}" == 'y' ]]; then
                    installconfig
                elif [[ "${answer,,}" == 'n' ]] || [[ "${answer,,}" == '' ]]; then
                    echo "Skipping config install..."
                fi
            fi
        ;;
        "2")
            if [ -f "/etc/udev/rules.d/99-powersave.rules" ]; then
                echo "Powersave already exists!"
            elif [ ! -f "/etc/udev/rules.d/99-powersave.rules" ]; then 
                echo "This will install a powersave feature. Are you sure you want to install this? (y/N)"
                read answer
                if [[ "${answer,,}" == 'y' ]]; then
                    installpowersaver
                elif [[ "${answer,,}" == 'n' ]] || [[ "${answer,,}" == '' ]]; then
                    echo "Skipping powersave install..."
                fi
            fi
        ;;
        "3")
            if [ -L "${HOME}/.config/hypr/hyprlock.conf" ]; then
                echo "Lockscreen conf already exists!"
            elif [ -f "${HOME}/.config/hypr/hyprlock.conf" ]; then 
                echo "This will install the EVA lockscreen. Are you sure you want to install this? (y/N)"
                read answer
                if [[ "${answer,,}" == 'y' ]]; then
                    installevalockscreen
                elif [[ "${answer,,}" == 'n' ]] || [[ "${answer,,}" == '' ]]; then
                    echo "Skipping powersave install..."
                fi
            fi
        ;;
        "4")
            if grep 'GRUB_EARLY_INITRD_LINUX_CUSTOM="acpi_override"' /etc/default/grub; then
                echo "Fix already installed!"
            elif ! grep 'GRUB_EARLY_INITRD_LINUX_CUSTOM="acpi_override"' /etc/default/grub; then
                echo "This will install the trackpad fix. Are you sure you want to install it? (y/N)"
                read answer
                if [[ "${answer,,}" == 'y' ]]; then
                    fixtrackpad
                elif [[ "${answer,,}" == 'n' ]] || [[ "${answer,,}" == '' ]]; then
                    echo "Skipping trackpad fix..."
                fi
            fi
        ;;
        "A")
            echo "This will install EVERYTHING. Are you sure? (y/N)"
            read answer
            if [[ "${answer,,}" == 'y' ]]; then
                installconfig
                installpowersaver
                fixtrackpad
            elif [[ "${answer,,}" == 'n' ]] || [[ "${answer,,}" == '' ]]; then
                echo "Skipping install of everything..."
            fi
        ;;
        "E")
            exit
        ;;
    esac
done
