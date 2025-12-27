#!/bin/bash

SECONDS=0

#Interrumpir instalación en caso de error
set -euo pipefail

#Variables editables
puerto_odoo=8069
version_instalador="1.0"
usuario_odoo="odoo"
home_odoo="/opt/odoo"
usuario_postgres="odoo"

echo -e "\e[33m Instalador Odoo \e[39m"
echo -e "\e[33m Versión: $version_instalador \e[39m"
echo -e "\e[33m By: Héctor Monroy Fuertes \e[39m"
echo -e "\e[33m GitHub: https://www.github.com/HectorCRM \e[39m"
echo "********************************************************"
echo 
echo "Comprobando conexión a internet..."

if ping -c 1 -W 2 github.com > /dev/null; then
	echo -e "\e[32m Conexión correcta \e[39m"
else 
	while ! ping -c 1 -W 2 github.com > /dev/null; do
		echo -e "\e[31m No hay conexión a internet o www.github.com no funciona. \e[39m"
		echo -e "\e[31m Revisa la conexión a internet. \e[39m"
		read -rp "¿Intentar de nuevo?[s/n]: " reintento
	
		if [[ $reintento == [sS] ]]; then
			echo "Reintentado la conexión..."
			sleep 2
		else 
			echo -e "\e[31m Abortando instalación... \e[39m"
			sleep 2
			exit 1
		fi
	done
	echo -e "\e[32m Conexión reestablecida con éxito. \e[39m"
fi


while true;
do
	IFS= read -rp "¿Qué versión de Odoo deseas instalar?:" version_odoo
	if [ -z "$version_odoo" ]; then
		echo -e "\e[31m No puedes dejar en blanco la versión, el instalador no sabrá que versión de Odoo clonar de GitHub. \e[39m"
	elif ! [[ $version_odoo =~ ^[0-9]+\.[0-9]+$ ]]; then
		echo -e "\e[31m Formato para versión inválido. Debe ser similar a '17.0' (numero+.+numero) \e[39m"
	else
		echo -e "\e[33m Versión elegida: $version_odoo \e[39m"
		sleep 2
		echo
		break
	fi
done

echo -e "Para que Odoo funcione es necesario instalar Postgresql, el cual se instalará automáticamente más adelante. El usuario por defecto será\e[33m odoo\e[39m(puedes modificarlo manualmente editando el script)."
echo -e "\e[33m A continuación se pedirá una contraseña para el usuario de Postgresql. \e[39m"
echo

while true;
do
	IFS= read -rp "Introduce la contraseña: " pass1
	echo
	IFS= read -rp "Introdúcela de nuevo: " pass2
	echo

	if [ "$pass1" = "$pass2" ]; then
		if [ -z "$pass1" ]; then
			echo -e "\e[31m No puedes usar una contraseña vacía. \e[39m"
		else
			echo -e "\e[32m Contraseña guardada, se utilizará para el usuario odoo en Postgresql. \e[39m"
			sleep 3
			break
		fi
	else
		echo -e "\e[31m Las contraseñas no coinciden, inténtalo otra vez. \e[39m"
		echo
	fi	
done


#Actualización del sistema. [-y] puede traducirse por [--assume-yes] por lo que no pedirá confirmación
echo
echo -e "\e[33m Actualizando el sistema... \e[39m"
sudo apt update && sudo apt upgrade -y

#Generación de informe de paquetes instalados antes de instalar Odoo
echo
echo -e "\e[33m Identificando paquetes instalados en el sistema... \e[39m"
apt list --installed > /tmp/pkgs-installed-before.txt

#Instalación de dependencias para Odoo
echo
echo -e "\e[33m Instalando dependencias necesarias para el funcionamiento de Odoo... \e[39m"
sudo apt install -y git python3 python3-pip python3-dev build-essential wget libxslt-dev libzip-dev libldap2-dev libsasl2-dev libjpeg-dev libpq-dev wkhtmltopdf postgresql libxml2-dev libopenjp2-7-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev libxcb1-dev python3-venv node-less

#Creación del usuario Odoo en el sistema
echo
echo -e "\e[33m Creando el usuario Odoo en el sistema... \e[39m"
sudo adduser --system --home=$home_odoo --group $usuario_odoo || true

#Configuración Postgres
echo
echo -e "\e[33m Configurando PostgreSQL... \e[39m"
sudo su - postgres -c "createuser -s $usuario_postgres" || true
echo "ALTER USER $usuario_postgres WITH PASSWORD '$pass1';" | sudo -u postgres psql || true

#Descargar Odoo desde repositorio
echo
echo -e "\e[33m Clonando repositorio desde GitHub... \e[39m"
sudo git clone https://www.github.com/odoo/odoo --depth 1 --branch $version_odoo $home_odoo/odoo

#Crear el directorio custom-addons
echo -e "\e[33m Creando directorio para custom addons... \e[39m"
sleep 2
sudo mkdir -p $home_odoo/custom-addons

#Entorno virtual, requisitos
sudo chown -R $usuario_odoo: $home_odoo
sudo -u $usuario_odoo bash -c "cd $home_odoo && python3 -m venv venv && source venv/bin/activate && pip install wheel && pip install -r odoo/requirements.txt"

echo
echo -e "\e[33m Ahora se va a configurar una contraseña de usuario para Odoo. \e[39m"
echo

while true;
do
	IFS= read -rp "Introduce la contraseña: " odooPass1
	echo
	IFS= read -rp "Introducela de nuevo: " odooPass2
	echo

	if [ "$odooPass1" = "$odooPass2" ]; then
		if [ -z "$odooPass1" ]; then
			echo -e "\e[31m No puedes dejar la contraseña en blanco. Inténtalo de nuevo. \e[39m"
			echo
		else
			echo -e "\e[32m Contraseña guardada, se utilizará para el usuario de Odoo. \e[39m"
			sleep 3
			break
		fi
	else
		echo -e "\e[31m Las contraseñas no coinciden, intentalo otra vez. \e[39m"
		echo 
	fi	
done

#Configuración de odoo.conf
cat <<EOF | sudo tee /etc/odoo.conf
[options]
admin_passwd = $odooPass1
db_host = False
db_port = False
db_user = $usuario_postgres
db_password = $pass1
addons_path = $home_odoo/odoo/addons,$home_odoo/custom-addons
EOF

#Configuracion systemd para autoinicio
cat <<EOF | sudo tee /etc/systemd/system/odoo.service
[Unit]
Description=Odoo
After=network.target

[Service]
User=$usuario_odoo
Group=$usuario_odoo
Environment=PYTHONPATH=$home_odoo/odoo
ExecStart=$home_odoo/venv/bin/python3 $home_odoo/odoo/odoo-bin -c /etc/odoo.conf
Restart=always

[Install]
WantedBy=multi-user.target
EOF

#Comprobar puerto 8069 antes de tratar de iniciar Odoo
echo -e "\e[33m Comprobando puerto 8069 \e[39m"
sleep 2
if ss -tuln | grep -qE ":$puerto_odoo\b"; then
	echo -e "\e[31m El puerto $puerto_odoo necesario para Odoo está ocupado por otro proceso. \e[39m"
	read -rp "¿Continuar de todos modos?[s/n]: " cont_port
	if [[ $cont_port == [sS] ]]; then 
		echo -e "\e[33m Continuando, pero considera modificar 'xmlrpc_port = $puerto_odoo' en /etc/odoo.conf \e[39m"
	else
		echo -e "\e[31m Abortando instalación... \e[39m"
		exit 1
	fi
else
	echo -e "\e[32m Puerto 8069 libre, continuando instalación.... \e[39m"
fi
sleep 2

sudo systemctl daemon-reload
sudo systemctl start odoo
sudo systemctl enable odoo
sudo systemctl status odoo --no-pager

#Identificación de paquetes instalados para Odoo
#Esto permitirá revertir la instalación de forma efectiva
echo
echo -e "\e[33m Identificando paquetes instalados en el sistema tras instalar Odoo... \e[39m"
apt list --installed > /tmp/pkg-installed-after.txt

#Ordenamos ambos paquetes antes de compararlos
sort /tmp/pkgs-installed-before.txt > /tmp/pkgs-installed-before-ordenado.txt
sort /tmp/pkg-installed-after.txt > /tmp/pkg-installed-after-ordenado.txt

pkgs_installed=$(comm -13 /tmp/pkgs-installed-before-ordenado.txt /tmp/pkg-installed-after-ordenado.txt | awk -F/ '{print $1}' | tr '\n' ' ')
echo "Paquetes instalados: $pkgs_installed" >> pkgs-installed-odoo.txt
echo
sleep 1
echo -e "\e[33m Generando informe de instalación... \e[39m"
sleep 2
timestamp_instalacion=$(date +"%d-%m-%Y a las %H:%M:%S")

cat << EOF > informe-instalacion.txt
********************INFORME TRAS INSTALACIÓN ODOO********************

   Versión instalador: $version_instalador
   Creado por: Héctor Monroy Fuertes
   GitHub: https://www.github.com/HectorCRM
   
*********************************************************************
La instalación se completo en $(printf "%02d minutos y %02d segundos." $((SECONDS%3600/60)) $((SECONDS%60)))
Fecha y hora de instalación: $timestamp_instalacion.

Versión de Odoo instalada: $version_odoo
Usuario PostgreSQL: $usuario_postgres
Contraseña PostgreSQL: $pass1
Contraseña Odoo: $odooPass1

Puedes consultar los paquetes instalados en el archivo pkgs-installed-odoo.txt.
Si firefox no ha abierto Odoo automáticamente escribe en tu navegador: http://localhost:8069

Recuerda que no es buena idea almacenar contraseñas en un .txt en entornos de producción.
¡¡Espero que te haya sido de utilidad!!
EOF

#Cambiar permisos al informe de instalación para que sólo el root pueda leerlo
sudo chmod 600 informe-instalacion.txt

#Limpieza de variables y archivos temporales
echo -e "Limpiando variables y archivos temporales..."
sleep 2
unset puerto_odoo version_instalador usuario_odoo home_odoo usuario_postgres reintento pass1 pass2 odooPass1 odooPass2 pkgs_installed
rm /tmp/pkgs-installed-before.txt /tmp/pkg-installed-after.txt /tmp/pkgs-installed-before-ordenado.txt /tmp/pkg-installed-after-ordenado.txt || true

echo -e "\e[32m Instalación terminada!! \e[39m"
printf "La instalación ha tardado: %02d:%02d\n"  $((SECONDS%3600/60)) $((SECONDS%60))


firefox http://localhost:8069


