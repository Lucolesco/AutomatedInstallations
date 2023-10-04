#!/bin/bash


clear
echo "________________________________"
echo "|    |   |   |   |      \       \ "
echo "|    |   |   |   |    ___|   _   |"
echo "|    |   |___|   |   |   |  | |  |"
echo "|    |____       |   |___|  |_|  |"
echo "|         |     /        \       /"
echo "-__---------------------------__-"

echo "_________________________________________________________"
echo "Bem-vindo ao Instalador Automático do Lucolesco!"
echo "Será instalado o Arch Linux com i3-gaps!"
echo "_________________________________________________________"
sleep 1
echo "Primeiro, iremos particionar o disco."
echo "_________________________________________________________"
sleep 1

echo "Esses são todos os discos atualmente em seu PC:"
echo "_________________________________________________________"
sudo fdisk -l | grep "/dev/"

echo "_________________________________________________________"
echo "Com essas informações, digite qual será o disco escolhido:"
echo "_________________________________________________________"
read disco

partition=""
if echo $disco | grep "nvme";
then
	partition="${disco}p"
else
	partition=${disco}
fi
echo $partition

if cat /sys/firmware/efi/fw_platform_size | (grep "64" || grep "32") 
then
	echo "You're running in UEFI mode."
	echo "_________________________________________________________"
	echo "Formatando as partições..."
	echo "_________________________________________________________"
	sleep 1
	(
	echo o

	echo n
	echo p
	echo 1
	echo 
	echo +1G
	echo t
	echo EF
	
	echo n
	echo p
	echo 2
	echo  
	echo +4G
	echo t
	echo  
	echo 82

	echo n
	echo p
	echo 3
	echo  
	echo 
		
	echo w
	) | fdisk $disco

	mkfs.fat -F 32 "${partition}1"
	mkswap "${partition}2"
	mkfs.ext4 "${partition}3"

	sleep 2
	clear

	echo "_________________________________________________________"
	echo "Montando as partições..."
	echo "_________________________________________________________"

	sleep 1
	
	mount --mkdir "${partition}1" /mnt/boot
	swapon "${partition}2"
	mount "${partition}3" /mnt
	
	sleep 2

	clear
else
	echo "You're running in BIOS mode."
	 
	echo "_________________________________________________________"
	echo "Formatando as partições..."
	echo "_________________________________________________________"
	sleep 1
	(
	echo o
	echo n
	echo p
	echo 1
	echo  
	echo +4G
	echo n
	echo p
	echo 2
	echo  
	echo  
	echo w
	) | fdisk $disco
	mkfs.ext4 "${partition}2"
	mkswap "${partition}1"
	sleep 2
	clear
	
	echo "_________________________________________________________"
	echo "Montando as partições..."
	echo "_________________________________________________________"
	sleep 1
	mount "${partition}2" /mnt
	swapon "${partition}1"
	sleep 2
	clear
fi

echo "_________________________________________________________"
echo "Instalando pacotes essenciais..."
echo "_________________________________________________________"
sleep 1
pacstrap -K /mnt base linux linux-firmware sudo networkmanager pipewire pipewire-pulse grub efibootmgr git lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings
sleep 2
clear

echo "_________________________________________________________"
echo "Gerando FSTAB (configuração do sistema)"
echo "_________________________________________________________"
sleep 1
genfstab -U /mnt >> /mnt/etc/fstab
sleep 2
clear

echo "______________________________________________________________"
echo "Digite qual será a interface gráfica. (digite 'n' para nenhuma"
echo "______________________________________________________________"
read ui

if [ "$ui" = "n" ]; 
then
	echo "A interface gráfica não será instalada."
else
	pacstrap -K /mnt $ui
fi

echo "_________________________________________________________"
echo "Digite a senha do super-usuário (ROOT):"
echo "_________________________________________________________"
passwd -R /mnt
sleep 1
clear

echo "_________________________________________________________"
echo "Digite o nome de usuário:"
echo "_________________________________________________________"
read nome_do_usuario
arch-chroot /mnt useradd -m $nome_do_usuario
sleep 1
clear

echo "_________________________________________________________"
echo "Insira a senha do usuário ${nome_de_usuario}"
echo "_________________________________________________________"
arch-chroot /mnt passwd $nome_do_usuario
sleep 1
clear

echo "_________________________________________________________"
echo "Digite o nome do computador (hostname):"
echo "_________________________________________________________"
read nome_do_computador
sleep 1
clear

echo "_________________________________________________________"
echo "Configurando o usuário..."
echo "_________________________________________________________"
sleep 1

arch-chroot /mnt << END
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
echo 'pt_BR.UTF-8 UTF-8' > /etc/locale.gen
locale-gen
echo LANG=pt_BR.UTF-8 >> /etc/locale.conf
echo KEYMAP=br-abnt2 >> /etc/vconsole.conf

echo $nome_do_computador >> /etc/hostname

useradd -m $nome_do_usuario
echo '${nome_do_usuario} ALL=(ALL:ALL) ALL' >> /etc/sudoers

echo [multilib] >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
END
sleep 2
clear

echo "________________________________________________________"
echo "Instalando o GRUB e configurando-o..."
echo "________________________________________________________"
sleep 1
if cat /sys/firmware/efi/fw_platform_size | (grep "64" || grep "32") 
then
	mkdir /mnt/boot/efi
	mount "${partition}1" /mnt/boot/efi
	arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
else
	arch-chroot /mnt grub-install --target=i386-pc $disco
fi
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
sleep 2
clear

echo "_________________________________________________________"
echo "Ativando serviços do systemd..."
echo "_________________________________________________________"
sleep 1
arch-chroot /mnt systemctl enable lightdm 
arch-chroot /mnt systemctl enable NetworkManager
sleep 2
clear

echo "_________________________________________________________"
echo "Instalação concluída!"
echo "_________________________________________________________"
echo "Digite (reboot) para reiniciar o computador."
echo "_________________________________________________________"
echo "Aproveite!"
echo "_________________________________________________________"
