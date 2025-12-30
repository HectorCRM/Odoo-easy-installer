#!/bin/bash

version_desinstalador="1.0"
path=$(pwd)
ARCHIVO_PKGS="$path/pkgs-installed-odoo.txt"


archivo_config="$path/installer.conf"


echo -e "\e[33m"
echo -e "         ██████╗ ██████╗  ██████╗  ██████╗     ███████╗ █████╗ ███████╗██╗   ██╗         ";
echo -e "        ██╔═══██╗██╔══██╗██╔═══██╗██╔═══██╗    ██╔════╝██╔══██╗██╔════╝╚██╗ ██╔╝         ";
echo -e "        ██║   ██║██║  ██║██║   ██║██║   ██║    █████╗  ███████║███████╗ ╚████╔╝          ";
echo -e "        ██║   ██║██║  ██║██║   ██║██║   ██║    ██╔══╝  ██╔══██║╚════██║  ╚██╔╝           ";
echo -e "        ╚██████╔╝██████╔╝╚██████╔╝╚██████╔╝    ███████╗██║  ██║███████║   ██║            ";
echo -e "         ╚═════╝ ╚═════╝  ╚═════╝  ╚═════╝     ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝            ";
echo -e "                                                                                         ";
echo -e "██╗   ██╗███╗   ██╗██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗ ";
echo -e "██║   ██║████╗  ██║██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗";
echo -e "██║   ██║██╔██╗ ██║██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     █████╗  ██████╔╝";
echo -e "██║   ██║██║╚██╗██║██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗";
echo -e "╚██████╔╝██║ ╚████║██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║";
echo -e " ╚═════╝ ╚═╝  ╚═══╝╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝";
echo -e "Versión: $version_desinstalador"
echo -e "By: Héctor Monroy Fuertes"
echo -e "GitHub: https://www.github.com/HectorCRM \e[39m"
echo
echo -e "\e[31m ADVERTENCIA: Esto eliminará Odoo, su usuario en el sistema, sus archivos y servicio! \e[39m"
read -rp "¿Continuar?[s/n]: " confirm 
if [[ $confirm != [sS] ]]; then
	echo "Desinstalación abortada, saliendo..."
	sleep 2
	exit 0
fi

echo -e "\e[33m Comprobando archivo de configuración... \e[39m"
if [ -f "$archivo_config" ]; then
	echo -e "\e[32m Archivo encontrado \e[39m"
	source "$archivo_config"
	sleep 2
else
	 echo -e "\e[31m Archivo de configuración no encontrado, abortando desinstalación... \e[39m"
	 sleep 2
	 exit 1
fi



#Detener y eliminar servicio systemd
echo
echo -e "\e[31m Parando y eliminando servicio Odoo... \e[39m"
sleep 2
sudo systemctl stop odoo || true
sudo systemctl disable odoo || true
sudo rm -f /etc/systemd/system/odoo.service
sudo systemctl daemon-reload
echo
sleep 2

#Eliminar archivos y home de Odoo
read -rp "Eliminar directorio y usuario $usuario_odoo del sistema?[s/n]: " user_del
if [[ $user_del == [sS] ]]; then
	echo -e "\e[31m Eliminando archivos de Odoo... \e[39m"
	sudo rm -rf $home_odoo
	sleep 2
	echo -e "\e[31m Eliminando $usuario_odoo del sistema... \e[39m"
	sleep 2
	sudo userdel odoo || true
	sudo groupdel odoo || true
else
	echo -e "\e[33m Continuando sin eliminar $usuario_odoo del sistema... \e[39m"
fi

#Eliminar usuario de Odoo de PostgreSQL, opcional
read -rp "¿Eliminar usuario Odoo de PostgreSQL?[s/n]: " drop_user_postgres
if [[ $drop_user_postgres == [sS] ]]; then
	echo -e "\e[31m Eliminando Odoo de PostgreSQL... \e[39m"
	sleep 2
	sudo -u postgres dropuser "$usuario_postgres" || true
else
	echo -e "\e[33m Continuando sin eliminar datos de PostgreSQL... \e[39m"
	sleep 2
fi

#Desinstalar paquetes instalados para el funcionamiento de Odoo
if [ ! -f "$ARCHIVO_PKGS" ]; then
	echo -e "\e[31m ¡Archivo con los paquetes instalados durante la instalación de Odoo no localizado! \e[39m"
	sleep 1
	echo -e "\e[31m Desinstalación finalizada sin eliminar paquetes... \e[39m"
	sleep 2
	exit 1
else
	echo -e "\e[32m Archivo localizado! \e[39m"
	sleep 2
	pkgs_list=$(sed 's/\.[^ ]*//g' "$ARCHIVO_PKGS" | xargs)
	pkgs_total=$(echo "$pkgs_list" | wc -w)
	if [[ -n "$pkgs_list" ]]; then
		read -rp " ¿Quieres eliminar todos los paquetes que se instalaron al instalar Odoo?[s/n]: " rm_pkg
		if [[ $rm_pkg == [sS] ]]; then
			echo -e "\e[32m Eliminando paquetes... \e[39m"
			sudo apt-get purge -y $pkgs_list && sudo apt-get autoremove -y
			echo -e "\e[32m Se han eliminado $pkgs_total paquetes \e[39m"
			sleep 2
			echo -e "\e[32m ¡Desinstalación finalizada! \e[39m"
			sleep 2
			exit 0
		else
			echo -e "\e[33m De acuerdo, los paquetes permanecerán en el sistema... \e[39m"
			sleep 2
			exit 0
		fi
	else
		echo -e "\e[31m El archivo esta vacío, finalizando desinstalación... \e[39m"
		sleep 2
		exit 1
	fi
fi

	
	
