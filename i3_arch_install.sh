#!/bin/bash

echo "---------------------------------------------------------"
echo "Bem-vindo ao Instalador Automático do Lucolesco!"
echo "Será instalado o Arch linux com i3-gaps!"
echo "---------------------------------------------------------"
sleep 2
echo "---------------------------------------------------------"
echo "Primeiro, iremos particionar o disco."
echo "---------------------------------------------------------"
sleep 1
echo "\n"
echo "---------------------------------------------------------"
echo "Esses são todos os discos atualmente em seu PC:"
echo "---------------------------------------------------------"
sudo fdisk -l | grep "Dis"
echo "---------------------------------------------------------"
echo "Com essas informações, digite qual será o disco escolhido:"
read disco
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

mkfs.ext4 "${disco}2"
mkswap "${disco}1"
echo "-----------------------------------------------------------"
echo "Montando as partições..."
echo "-----------------------------------------------------------"
sleep 3
mount "${disco}2" /mnt
swapon "${disco}1"
echo "------------------------------------------------------------"
echo "Instalando pacotes essenciais..."
echo "------------------------------------------------------------"
sleep 1
pacstrap -K /mnt base linux linux-firmware firefox networkmanager pipewire pipewire-pulse i3 alacritty grub git gdm
echo "------------------------------------------------------------"
echo "Gerando FSTAB (configuração do sistema)"
echo "------------------------------------------------------------"
sleep 1
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt | (
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
echo 'pt_BR.UTF-8 UTF-8' > /etc/locale.gen
locale-gen
echo LANG=pt_BR.UTF-8 >> /etc/locale.conf
echo KEYMAP=br-abnt2 >> /etc/vconsole.conf
sleep 1
echo "--------------------------------------------------------------"
echo "Digite o nome do seu computador:"
echo "--------------------------------------------------------------"
read nome_do_computador
echo $nome_do_computador >> /etc/hostname
sleep 1
echo "---------------------------------------------------------------"
echo "Digite o nome do usuário:"
echo "---------------------------------------------------------------"
read nome_do_usuario
useradd -m nome_do_usuario
echo "---------------------------------------------------------------"
echo "Digite a senha do usuário \"${nome_do_usuario}\""
echo "---------------------------------------------------------------"
passwd $nome_do_usuario
sleep 1
echo "--------------------------------------------------------------"
echo "Digite a senha do usuário ROOT (super-usuário/administrador):"
echo "--------------------------------------------------------------"
passwd
sleep 1
echo "--------------------------------------------------------------"
echo "Estamos quase terminando... Configurando o boot-loader (GRUB)."
echo "--------------------------------------------------------------"
sleep 2
grub-install --target=i386-pc $disco
grub-mkconfig -o /boot/grub/grub.cfg
echo "--------------------------------------------------------------"
echo "Aplicando customização e configurações finais..."
echo "--------------------------------------------------------------"
cd home/$nome_do_usuario/

git clone https://github.com/Lucolesco/MyDotFiles

cd MyDotFiles/black_white

sudo pacman -Syu && sudo pacman -S eog thunar ttf-font-awesome python nitrogen rofi alacritty python-pipx playerctl python-dbus python-requests
pipx install bumblebee-status

cp -a wallpapers /home/$nome_de_usuario/Documentos/
cp -a .config/* /home/$nome_de_usuario/.config/

systemctl enable NetworkManager
systemctl enable gdm
exit
)

sleep 3
echo "----------------------------------------------------------------"
echo "Instalação concluída. O computador vai reiniciar em breve."
echo "----------------------------------------------------------------"
echo "----------------------------------------------------------------"
echo "Aproveite!"
echo "----------------------------------------------------------------"
sleep 5
reboot







