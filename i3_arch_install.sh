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
pacstrap -K /mnt base linux linux-firmware sudo firefox networkmanager pipewire pipewire-pulse i3 i3-gaps alacritty grub git gdm
echo "------------------------------------------------------------"
echo "Gerando FSTAB (configuração do sistema)"
echo "------------------------------------------------------------"
sleep 1
genfstab -U /mnt >> /mnt/etc/fstab

echo "------------------------------------------------------------"
echo "Digite a senha do super-usuário (ROOT):"
echo "------------------------------------------------------------"
passwd -R /mnt
sleep 1

echo "------------------------------------------------------------"
echo "Digite o nome de usuário:"
echo "------------------------------------------------------------"
read nome_do_usuario
sleep 1

echo "------------------------------------------------------------"
echo "Digite o nome do computador (hostname):"
echo "------------------------------------------------------------"
read nome_do_computador
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

grub-install --target=i386-pc $disco
grub-mkconfig -o /boot/grub/grub.cfg

cd home/$nome_do_usuario/
git clone https://github.com/Lucolesco/MyDotFiles
cd MyDotFiles/black_white

echo [multilib] >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf

mkdir /home/$nome_do_usuario/Documentos
mkdir /home/$nome_do_usuario/.config

cp -a wallpapers /home/$nome_do_usuario/Documentos/
cp -a .config/* /home/$nome_do_usuario/.config/
END
sleep 1

pacstrap -C /mnt/etc/pacman.conf -K /mnt eog thunar ttf-font-awesome python nitrogen rofi alacritty python-pipx playerctl python-dbus python-requests 
arch-chroot /mnt << END
pipx install bumblebee-status
END

sleep 1
echo "----------------------------------------------------------------"
echo "Instalação concluída. O computador vai reiniciar em breve."
echo "----------------------------------------------------------------"
echo "Aproveite!"
echo "----------------------------------------------------------------"
sleep 3 

