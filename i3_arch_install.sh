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
echo "---------------------------------------------------------"
(
echo o
echo n
echo p
echo 1
echo 
echo +1G
echo n
echo p
echo 2
echo 
echo w
) | fdisk $disco
