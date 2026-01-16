#!/bin/bash

set -euo pipefail

version_instalador="3.0"
SECONDS=0
path=$(pwd)
archivo_config="$path/installer.conf"
vm=false
express=false
pgadmin=false
forma_instalacion=""

while [[ $# -gt 0 ]]; do
	case $1 in
		--help)
			echo -e "\e[33m****************Menú de ayuda Odoo-easy-installer********************"
			echo "*********************************************************************"
			echo "[Opciones admitidas por el instalador]:"
			echo "		--help:          Muestra este menú de ayuda"
			echo
			echo "		--version:       Muestra la versión del instalador"
			echo
			echo "		-x o --express:  Instala Odoo de forma rápida, sin interacción con el usuario"
			echo
			echo "		-x--help:        Amplía información sobre la opcion -x o --express"
			echo
			echo "		-vm:             Le indica al instalador que Odoo va a ser instalado en máquina virtual, al final de la instalación mostrará la IP para acceder a Odoo desde la máquina host"
			echo
			echo "		--pgadmin:	 Instala y configura PgAdmin4 v9.11 en modo servidor al terminar la instalacion de Odoo"
			echo
			echo "		--pg-help:	 Muestra más información sobre la bandera --pgadmin"
			echo -e "\e[39m"
			exit 0
		;;
		--version)
			echo -e "\e[33mVersión del instalador: $version_instalador\e[39m"
			exit 0
		;;
		-x|--express)
			express=true
			shift
		;;
		-vm)
			vm=true
			shift
		;;
		-x--help)
			echo -e "\e[33mPara utilizar esta opción del instalador hay que editar el archivo\e[32m installer.conf\e[39m\e[33m y especificar en él la versión de Odoo que se desea instalar asi como las diferentes contraseñas."
			echo -e "Esta opción es totalmente automática y rapida, sólo hay interacción con el usuario en caso de fallo de conexión\e[39m"
			exit 0
		;;
		--pgadmin)
			pgadmin=true
			shift
		;;
		--pg-help)
			echo -e "\e[33mAl ejecutar el instalador con esta bandera, al final de la instalacón de Odoo se clonará el repositorio con el instalador de Pgadmin4. Este instalador descargará PgAdmin4 en su versión 9.11 y lo configurará en modo servidor con Apache. \r\n Puedes analizar el repositorio aquí: https://github.com/HectorCRM/pgAdmin4-easy-installer  \e[39m"
			exit 0
		;;
		*) 
			echo "Parametro no valido"
			exit 0
		;;
	esac
done

echo -e "\e[33m"
echo " ██████╗ ██████╗  ██████╗  ██████╗     ███████╗ █████╗ ███████╗██╗   ██╗";
echo "██╔═══██╗██╔══██╗██╔═══██╗██╔═══██╗    ██╔════╝██╔══██╗██╔════╝╚██╗ ██╔╝";
echo "██║   ██║██║  ██║██║   ██║██║   ██║    █████╗  ███████║███████╗ ╚████╔╝ ";
echo "██║   ██║██║  ██║██║   ██║██║   ██║    ██╔══╝  ██╔══██║╚════██║  ╚██╔╝  ";
echo "╚██████╔╝██████╔╝╚██████╔╝╚██████╔╝    ███████╗██║  ██║███████║   ██║   ";
echo " ╚═════╝ ╚═════╝  ╚═════╝  ╚═════╝     ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝   ";
echo "                                                                        ";
echo "██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗   ";
echo "██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗  ";
echo "██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     █████╗  ██████╔╝  ";
echo "██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗  ";
echo "██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║  ";
echo "╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝  ";
echo -e "Versión: $version_instalador"
echo -e "By: Héctor Monroy Fuertes"
echo -e "GitHub: https://www.github.com/HectorCRM"
echo -e "******************************************************** \e[39m"
echo 
	
if [[ "$express" == "false" ]]; then
	if [[ "$vm" == "true" ]]; then
		forma_instalacion="Normal en VM"
		if [[ "$pgadmin" == "true" ]]; then
			forma_instalacion="Normal en VM junto a PgAdmi4"
			echo -e "\e[33mIniciando instalación de Odoo y PgAdmin4 en VM, se mostrará IP de acceso al final de cada instalación \e[39m"
			sleep 2
		else
			forma_instalacion="Normal en VM"
			echo -e "\e[33mIniciando instalación de Odoo en VM, se mostrara IP al final para acceso desde máquina real. \e[39m"
			sleep 2
		fi
	else
		if [[ "$pgadmin" == "true" ]]; then
			forma_instalacion="Normal junto a PgAdmi4"
			echo -e "\e[33mIniciando instalación de Odoo y PgAdmin4. \e[39m"
			sleep 2
		else
			forma_instalacion="Normal"
			echo -e "\e[33mIniciando instalación de Odoo... \e[39m"
			sleep 2
		fi
	fi
	
#COMPROBACIÓN DE LA CONEXIÓN
	echo -e "\e[33mComprobando conexión a internet... \e[39m"
	if ping -c 1 -W 2 github.com > /dev/null; then
		echo -e "\e[32m¡Conexión correcta! \e[39m"
	else 
		while ! ping -c 1 -W 2 github.com > /dev/null; do
			echo -e "\e[31mNo hay conexión a internet o www.github.com no funciona. \e[39m"
			echo -e "\e[31mRevisa la conexión a internet. \e[39m"
			read -rp " ¿Intentar de nuevo?[s/n]: " reintento
		
			if [[ $reintento == [sS] ]]; then
				echo "Reintentado la conexión..."
				sleep 2
			else 
				echo -e "\e[31mAbortando instalación... \e[39m"
				sleep 2
				exit 1
			fi
		done
		echo -e "\e[32mConexión reestablecida con éxito. \e[39m"
	fi
	sleep 2

	echo -e "\e[33mBuscando archivo de configuración... \e[39m"
	if [ -f "$archivo_config" ]; then
		echo -e "\e[32m¡Archivo encontrado! \e[39m"
		source "$archivo_config"
		sleep 2
	else
		 echo -e "\e[31mArchivo de configuración no encontrado..."
		 sleep 2
		 echo -e "Abortando instalación...  \e[39m"
		 sleep 2
		 exit 1
	fi
	echo

	while true;
	do
		IFS= read -rp "¿Qué versión de Odoo deseas instalar?:" version_odoo
		if [ -z "$version_odoo" ]; then
			echo -e "\e[31mNo puedes dejar en blanco la versión, el instalador no sabrá que versión de Odoo clonar de GitHub. \e[39m"
		elif ! [[ $version_odoo =~ ^[0-9]+\.[0-9]+$ ]]; then
			echo -e "\e[31mFormato para versión inválido. Debe ser similar a '17.0' (numero+.+numero) \e[39m"
		else
			echo -e "\e[33mVersión elegida: $version_odoo \e[39m"
			sleep 2
			echo
			break
		fi
	done
	sleep 2

	echo -e "\e[33mPara el funcionamiento de Odoo se instalará más adelante PostgreSQL. \e[39m" 
	echo -e "\e[33mEl usuario para PostgreSQL configuruado en el archivo de configuración es:\e[39m \e[34m$usuario_postgres\e[39m"
	echo -e "\e[33mA continuación se pedirá una contraseña para el usuario en PostgreSQL. \e[39m"
	echo

#CONTRASEÑA PARA POSTGRESQL
	while true; do
    for i in 1 2; do
        [ $i -eq 1 ] && prompt=" Introduce la contraseña: " || prompt=" Introdúcela de nuevo: "
        echo -n "$prompt"
        
        password=""
        while IFS= read -r -s -n1 char; do
            if [[ -z $char ]]; then # Al pulsar Enter
                break
            fi
            if [[ $char == $'\177' ]]; then # Al pulsar Retroceso (BackSpace)
                if [ -n "$password" ]; then
                    password="${password%?}"
                    echo -ne '\b \b' # Borra el asterisco de la pantalla
                fi
            else
                password+="$char"
                echo -n "*" # Imprime el asterisco
            fi
        done
        echo # Nueva línea tras pulsar Enter
        
        [ $i -eq 1 ] && pass1="$password" || pass2="$password"
    done

    if [ "$pass1" = "$pass2" ]; then
        if [ -z "$pass1" ]; then
            echo -e "\e[31mNo puedes usar una contraseña vacía. \e[39m"
        else
            echo -e "\e[32mContraseña guardada, se utilizará para el usuario\e[39m \e[34m$usuario_postgres\e[39m\e[32m en PostgreSQL. \e[39m"
            sleep 2
            break
        fi
    else
        echo -e "\e[31mLas contraseñas no coinciden, inténtalo otra vez. \e[39m"
    fi
done
	sleep 2

	#Actualización del sistema. [-y] puede traducirse por [--assume-yes] por lo que no pedirá confirmación
	echo
	echo -e "\e[33mActualizando el sistema... \e[39m"
	sudo apt update && sudo apt upgrade -y

	#Generación de informe de paquetes instalados antes de instalar Odoo
	echo
	echo -e "\e[33mIdentificando paquetes instalados en el sistema... \e[39m"
	apt list --installed > /tmp/pkgs-installed-before.txt

	#Instalación de dependencias para Odoo
	echo
	echo -e "\e[33mInstalando dependencias necesarias para el funcionamiento de Odoo... \e[39m"
	sudo apt install -y git python3 python3-pip python3-dev build-essential wget libxslt-dev libzip-dev libldap2-dev libsasl2-dev libjpeg-dev libpq-dev wkhtmltopdf postgresql libxml2-dev libopenjp2-7-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev libxcb1-dev python3-venv node-less

	#Creación del usuario Odoo en el sistema
	echo
	echo -e "\e[33mCreando el usuario Odoo en el sistema... \e[39m"
	sudo adduser --system --home=$home_odoo --group $usuario_odoo || true

	#Configuración Postgres
	echo
	echo -e "\e[33mConfigurando PostgreSQL... \e[39m"
	sudo su - postgres -c "createuser -s $usuario_postgres" || true
	echo "ALTER USER $usuario_postgres WITH PASSWORD '$pass1';" | sudo -u postgres psql || true

	#Descargar Odoo desde repositorio
	echo
	echo -e "\e[33mClonando repositorio desde GitHub... \e[39m"
	sudo git clone https://www.github.com/odoo/odoo --depth 1 --branch $version_odoo $home_odoo/odoo

	#Crear el directorio custom-addons
	echo -e "\e[33mCreando directorio para custom addons... \e[39m"
	sleep 2
	sudo mkdir -p $addons_path

	#Entorno virtual, requisitos
	sudo chown -R $usuario_odoo: $home_odoo
	sudo -u $usuario_odoo bash -c 'cd $home_odoo && python3 -m venv venv && source venv/bin/activate && pip install wheel && pip install -r odoo/requirements.txt'

	echo
	echo -e "\e[33mAhora se va a configurar una contraseña de acceso a Odoo. \e[39m"
	sleep 2

	while true; do
	    for i in 1 2; do
		[ $i -eq 1 ] && prompt=" Introduce la contraseña: " || prompt=" Introdúcela de nuevo: "
		echo -n "$prompt"
		
		password=""
		while IFS= read -r -s -n1 char; do
		    if [[ -z $char ]]; then # Al pulsar Enter
		        break
		    fi
		    if [[ $char == $'\177' ]]; then # Al pulsar Retroceso (BackSpace)
		        if [ -n "$password" ]; then
		            password="${password%?}"
		            echo -ne '\b \b' # Borra el asterisco de la pantalla
		        fi
		    else
		        password+="$char"
		        echo -n "*" # Imprime el asterisco
		    fi
		done
		echo # Nueva línea tras pulsar Enter
		
		[ $i -eq 1 ] && odooPass1="$password" || odooPass2="$password"
	    done

	    if [ "$odooPass1" = "$odooPass2" ]; then
		if [ -z "$odooPass1" ]; then
		    echo -e "\e[31m¡No puedes usar una contraseña vacía! \e[39m"
		else
		    echo -e "\e[32mContraseña guardada, se utilizará para acceder al ERP de Odoo\e[39m"
		    sleep 2
		    break
		fi
	    else
		echo -e "\e[31mLas contraseñas no coinciden, inténtalo otra vez. \e[39m"
	    fi
	done
	sleep 2
	#Configuración de odoo.conf
	cat <<EOF | sudo tee /etc/odoo.conf
	[options]
	admin_passwd = $odooPass1
	db_host = False
	db_port = False
	db_user = $usuario_postgres
	db_password = $pass1
	addons_path = $home_odoo/odoo/addons,$addons_path
EOF

	#Configuracion systemd para autoinicio
	cat <<EOF | sudo tee /etc/systemd/system/odoo.service
	[Unit]
	Description=Odoo ERP, instalado con Odoo-easy-installer
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
	echo -e "\e[33mComprobando puerto 8069 \e[39m"
	sleep 2
	if ss -tuln | grep -qE ":$puerto_odoo\b"; then
		echo -e "\e[31mEl puerto $puerto_odoo necesario para Odoo está ocupado por otro proceso. \e[39m"
		read -rp " ¿Continuar de todos modos?[s/n]: " cont_port
		if [[ $cont_port == [sS] ]]; then 
			echo -e "\e[33mContinuando, pero considera modificar 'xmlrpc_port = $puerto_odoo' en /etc/odoo.conf \e[39m"
		else
			echo -e "\e[31mAbortando instalación... \e[39m"
			exit 1
		fi
	else
		echo -e "\e[32mPuerto 8069 libre, continuando instalación.... \e[39m"
	fi
	sleep 2

	sudo systemctl daemon-reload
	sudo systemctl start odoo
	sudo systemctl enable odoo
	#sudo systemctl status odoo --no-pager

	#Identificación de paquetes instalados para Odoo
	echo
	echo -e "\e[33mIdentificando paquetes instalados en el sistema tras instalar Odoo... \e[39m"
	apt list --installed > /tmp/pkg-installed-after.txt

	#Ordenamos ambos paquetes antes de compararlos
	sort /tmp/pkgs-installed-before.txt > /tmp/pkgs-installed-before-ordenado.txt
	sort /tmp/pkg-installed-after.txt > /tmp/pkg-installed-after-ordenado.txt

	pkgs_installed=$(comm -13 /tmp/pkgs-installed-before-ordenado.txt /tmp/pkg-installed-after-ordenado.txt | awk -F/ '{print $1}' | tr '\n' ' ')
	echo "$pkgs_installed" >> pkgs-installed-odoo.txt
	echo -e "\e[33mContando paquetes instalados... \e[39m"
	sleep 2
	total_pkgs=$(cat pkgs-installed-odoo.txt | wc -w)
	echo -e "\e[33mSe han instalado $total_pkgs paquetes en total. \e[33m"
	sleep 2
	echo
	echo -e "\e[33mGenerando informe de instalación... \e[39m"
	sleep 2
	timestamp_instalacion=$(date +"%d-%m-%Y a las %H:%M:%S")

	cat << EOF > informe-instalacion.html
	<!DOCTYPE html>
	<html>
	<head>
	<title>Iforme instalación Odoo-easy-installer</title>
	<style>
	main {
	  border: black 3px outset;
	  margin: 0;
	  padding: 15px;
	  background-color: powderblue;
	  border-radius: 10px;
	}
	article {
	  border: black 2px outset;
	  text-align: left;
	  margin: 0;
	  padding: 5px;
	  background-color: LightSteelBlue;
	  border-radius: 10px;
	}

	footer {
	  border: black 2px outset;
	  text-align: center;
	  padding: 3px;
	  background-color: LightSteelBlue;
	  border-radius: 10px;
	  color: black;
	}
	</style>
	</head>
	<body style="background-color: LightGray; text-align: center;">
	<header>
	<h1>Resumen instalación Odoo</h1>
	</header>
		<main>	 	
			<article>
			<h2>ADVERTENCIA:</h2>		 			
				<p>NO BORRES O MODIFIQUES LA UBICACIÓN DEL ARCHIVO <b>pkgs-installed-odoo.txt</b> ya que de querer desinstalar Odoo, el desinstalador no podrá eliminar los paquetes instalados en el sistema.</p>
				<p>Recuerda que no es aconsejable guardar contraseñas en archivos de texto, por lo que si has usado este script para instalar Odoo fuera de un entorno de aprendizaje cambia las contraseñas o eliminalas de este documento</p>
			</article>
			<p/>
			<article>
			<h2>Resumen:</h2>		 			
				<p>La instalación se completó en $(printf "%02d minutos y %02d segundos." $((SECONDS%3600/60)) $((SECONDS%60)))</p>
				<p>Fecha y hora de la instalación: $timestamp_instalacion.</p>
				<p>Versión de Odoo instalada: $version_odoo</p>
				<p>Forma de instalación: $forma_instalacion</p>
			</article>
			<p/>
			<article>
			<h2>Usuarios:</h2>
				<p>Usuario creado en el sistema para Odoo: odoo</p>
				<p>Usuario creado en PostgreSQL: odoo</p>
				<p>Contraseña para odoo en PostgreSQL: $pass1</p>
				<p>Contraseña de acceso a Odoo: $odooPass1</p>
			</article>
			<p/>
			<article>
			<h2>Paquetes instalados en el sistema:</h2>
				<p>Recuerda que estos paquetes se encuentran listados en el archivo pkgs-installed-odoo.txt</p>
				<p>Paquetes instalados en el sistema: $total_pkgs</p>
				<p>Listado: $(xargs -n 1 < pkgs-installed-odoo.txt)</p>
			</article> 
			</p>
			<footer>
			  <p>Odoo-easy-installer v$version_instalador<br>
			  Autor: Héctor Monroy Fuertes<br>
			  GitHub: 
			  <a href="https://github.com/HectorCRM/Odoo-easy-installer">github.com/HectorCRM/Odoo-easy-installer</a><br>
			  <a href="mailto:monroygti2.0@gmail.com">monroygti2.0@gmail.com</a></p>
			</footer>	
		</main>
	   
	</body>
	</html>

EOF

	#Cambiar permisos al informe de instalación para que sólo el root pueda leerlo
	sudo chmod 600 informe-instalacion.html



	rm /tmp/pkgs-installed-before.txt /tmp/pkg-installed-after.txt /tmp/pkgs-installed-before-ordenado.txt /tmp/pkg-installed-after-ordenado.txt || true

	echo -e "\e[32m¡¡Instalación terminada!! \e[39m"
	printf "La instalación ha tardado: %02d:%02d\n"  $((SECONDS%3600/60)) $((SECONDS%60))

	if [[ "$vm" == "true" ]]; then 
		ip=$(hostname -I | awk '{print $1}')
		echo -e "\e[32mPara acceder a Odoo desde tu máquina host introduce en el navegador: http://$ip:$puerto_odoo \e[39m"
		
	else
		echo -e "\e[33mPara acceder a Odoo introduce en tu navegador http://localhost:$puerto_odoo \e[39m"
	fi
	#Limpieza de variables y archivos temporales
	echo -e "\e[33mLimpiando variables y archivos temporales... \e[33m"
	sleep 2
	unset puerto_odoo version_instalador usuario_odoo home_odoo usuario_postgres reintento pass1 pass2 odooPass1 odooPass2 pkgs_installed ip vm total_pkgs express forma_instalacion
	
	if [[ "$pgadmin" == "false" ]]; then
		read -rp "Pulsa enter para terminar"
		xdg-open informe-instalacion.html
		exit 0
	else
		echo -e "\e[33mIniciando instalación de PgAdmin4... \e[39m"
		sleep 2 
		
		echo -e "\e[33mClonando repositorio... \e[39m"
		sleep 2
		git clone https://github.com/HectorCRM/pgAdmin4-easy-installer.git
		cd pgAdmin4-easy-installer
		chmod +x pgAdmin4-install.sh
		./pgAdmin4-install.sh
		echo -e "\e[36m¿Te ha sido útil? Déjame una estrellita en el proyecto en GitHub o cuéntamelo por LinkedIn(www.linkedin.com/in/héctor-monroy-fuertes-0a305b201)\e[0m"
		read -rp "Pulsa 'Enter' para terminar"
		exit 0
	fi
	
	
else
	if [[ "$vm" == "true" ]]; then
		forma_instalacion="Express en VM"
		if [[ "$pgadmin" == "true" ]]; then
			forma_instalacion="Express en VM junto a PgAdmin4"
			echo -e "\e[33mIniciando instalación express de Odoo y PgAdmin4 en VM, se mostrará IP de acceso al final de cada instalación \e[39m"
			sleep 2
		else
			forma_instalacion="Express en VM"
			echo -e "\e[33mIniciando instalación express de Odoo en VM, se mostrara IP al final para acceso desde máquina real. \e[39m"
			sleep 2
		fi
	else
		if [[ "$pgadmin" == "true" ]]; then
			forma_instalacion="Express junto a PgAdmin4"
			echo -e "\e[33mIniciando instalación express de Odoo y PgAdmin4. \e[39m"
			sleep 2
		else
			forma_instalacion="Express"
			echo -e "\e[33mIniciando instalación express de Odoo. \e[39m"
			sleep 2
		fi

	fi

	echo -e "\e[33mComprobando archivo de configuración... \e[39m"
	if [ -f "$archivo_config" ]; then
		echo -e "\e[32mArchivo encontrado! \e[39m"
		source "$archivo_config"
	else
		 echo -e "\e[31mArchivo de configuración no encontrado."
		 echo -e "Prueba instalación normal  \e[39m"
		 sleep 2
		 exit
	fi
	echo

	if ping -c 1 -W 2 github.com > /dev/null; then
	echo -e "\e[32mConexión correcta \e[39m"
	else 
		while ! ping -c 1 -W 2 github.com > /dev/null; do
			echo -e "\e[31mNo hay conexión a internet o www.github.com no funciona. \e[39m"
			echo -e "\e[31mRevisa la conexión a internet. \e[39m"
			read -rp " ¿Intentar de nuevo?[s/n]: " reintento
		
			if [[ $reintento == [sS] ]]; then
				echo "Reintentado la conexión..."
				sleep 2
			else 
				echo -e "\e[31mAbortando instalación... \e[39m"
				sleep 2
				exit 1
			fi
		done
		echo -e "\e[32mConexión reestablecida con éxito. \e[39m"
	fi
	
	#Actualización del sistema. [-y] puede traducirse por [--assume-yes] por lo que no pedirá confirmación
	echo
	echo -e "\e[33mActualizando el sistema... \e[39m"
	sudo apt update && sudo apt upgrade -y

	#Generación de informe de paquetes instalados antes de instalar Odoo
	echo
	echo -e "\e[33mIdentificando paquetes instalados en el sistema... \e[39m"
	apt list --installed > /tmp/pkgs-installed-before.txt

	#Instalación de dependencias para Odoo
	echo
	echo -e "\e[33mInstalando dependencias necesarias para el funcionamiento de Odoo... \e[39m"
	sudo apt install -y git python3 python3-pip python3-dev build-essential wget libxslt-dev libzip-dev libldap2-dev libsasl2-dev libjpeg-dev libpq-dev wkhtmltopdf postgresql libxml2-dev libopenjp2-7-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev libxcb1-dev python3-venv node-less

	#Creación del usuario Odoo en el sistema
	echo
	echo -e "\e[33mCreando el usuario Odoo en el sistema... \e[39m"
	sudo adduser --system --home=$home_odoo --group $usuario_odoo || true

	#Configuración Postgres
	echo
	echo -e "\e[33mConfigurando PostgreSQL... \e[39m"
	sudo su - postgres -c "createuser -s $usuario_postgres" || true
	echo "ALTER USER $usuario_postgres WITH PASSWORD '$pass1';" | sudo -u postgres psql || true

	#Descargar Odoo desde repositorio
	echo
	echo -e "\e[33mClonando repositorio desde GitHub... \e[39m"
	sudo git clone https://www.github.com/odoo/odoo --depth 1 --branch $version_odoo $home_odoo/odoo

	#Crear el directorio custom-addons
	echo -e "\e[33mCreando directorio para custom addons... \e[39m"
	sudo mkdir -p $addons_path

	#Entorno virtual, requisitos
	sudo chown -R $usuario_odoo: $home_odoo
	sudo -u $usuario_odoo bash -c 'cd $home_odoo && python3 -m venv venv && source venv/bin/activate && pip install wheel && pip install -r odoo/requirements.txt'
	echo
	#Configuración de odoo.conf
	cat <<EOF | sudo tee /etc/odoo.conf
	[options]
	admin_passwd = $odooPass1
	db_host = False
	db_port = False
	db_user = $usuario_postgres
	db_password = $pass1
	addons_path = $home_odoo/odoo/addons,$addons_path
EOF

	#Configuracion systemd para autoinicio
	cat <<EOF | sudo tee /etc/systemd/system/odoo.service
	[Unit]
	Description=Odoo ERP, instalado con Odoo-easy-installer
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
	echo -e "\e[33mComprobando puerto 8069 \e[39m"
	if ss -tuln | grep -qE ":$puerto_odoo\b"; then
		echo -e "\e[31mEl puerto $puerto_odoo necesario para Odoo está ocupado por otro proceso. \e[39m"
		read -rp " ¿Continuar de todos modos?[s/n]: " cont_port
		if [[ $cont_port == [sS] ]]; then 
			echo -e "\e[33mContinuando, pero considera modificar 'xmlrpc_port = $puerto_odoo' en /etc/odoo.conf \e[39m"
		else
			echo -e "\e[31mAbortando instalación... \e[39m"
			exit 1
		fi
	else
		echo -e "\e[32mPuerto 8069 libre, continuando instalación.... \e[39m"
	fi

	sudo systemctl daemon-reload
	sudo systemctl start odoo
	sudo systemctl enable odoo
#sudo systemctl status odoo --no-pager

	#Identificación de paquetes instalados para Odoo
	#Esto permitirá revertir la instalación de forma efectiva
	echo
	echo -e "\e[33mIdentificando paquetes instalados en el sistema tras instalar Odoo... \e[39m"
	apt list --installed > /tmp/pkg-installed-after.txt

	#Ordenamos ambos paquetes antes de compararlos
	sort /tmp/pkgs-installed-before.txt > /tmp/pkgs-installed-before-ordenado.txt
	sort /tmp/pkg-installed-after.txt > /tmp/pkg-installed-after-ordenado.txt
	
	pkgs_installed=$(comm -13 /tmp/pkgs-installed-before-ordenado.txt /tmp/pkg-installed-after-ordenado.txt | awk -F/ '{print $1}' | tr '\n' ' ')
	echo "$pkgs_installed" >> pkgs-installed-odoo.txt
	echo -e "\e[33mContando paquetes instalados... \e[39m"
	total_pkgs=$(cat pkgs-installed-odoo.txt | wc -w)
	echo -e "\e[33m$total_pkgs paquetes instalados. \e[33m"
	echo
	echo -e "\e[33mGenerando informe de instalación... \e[39m"
	timestamp_instalacion=$(date +"%d-%m-%Y a las %H:%M:%S")	

	cat << EOF > informe-instalacion.html
	<!DOCTYPE html>
	<html>
	<head>
	<title>Iforme instalación Odoo-easy-installer</title>
	<style>
	main {
	  border: black 3px outset;
	  margin: 0;
	  padding: 15px;
	  background-color: powderblue;
	  border-radius: 10px;
	}
	article {
	  border: black 2px outset;
	  text-align: left;
	  margin: 0;
	  padding: 5px;
	  background-color: LightSteelBlue;
	  border-radius: 10px;
	}

	footer {
	  border: black 2px outset;
	  text-align: center;
	  padding: 3px;
	  background-color: LightSteelBlue;
	  border-radius: 10px;
	  color: black;
	}
	</style>
	</head>
	<body style="background-color: LightGray; text-align: center;">
	<header>
	<h1>Resumen instalación Odoo</h1>
	</header>
		<main>	 	
			<article>
			<h2>ADVERTENCIA:</h2>		 			
				<p>NO BORRES O MODIFIQUES LA UBICACIÓN DEL ARCHIVO <b>pkgs-installed-odoo.txt</b> ya que de querer desinstalar Odoo, el desinstalador no podrá eliminar los paquetes instalados en el sistema.</p>
				<p>Recuerda que no es aconsejable guardar contraseñas en archivos de texto, por lo que si has usado este script para instalar Odoo fuera de un entorno de aprendizaje cambia las contraseñas o eliminalas de este documento</p>
			</article>
			<p/>
			<article>
			<h2>Resumen:</h2>		 			
				<p>La instalación se completó en $(printf "%02d minutos y %02d segundos." $((SECONDS%3600/60)) $((SECONDS%60)))</p>
				<p>Fecha y hora de la instalación: $timestamp_instalacion.</p>
				<p>Versión de Odoo instalada: $version_odoo</p>
				<p>Forma de instalación: $forma_instalacion</p>
			</article>
			<p/>
			<article>
			<h2>Usuarios:</h2>
				<p>Usuario creado en el sistema para Odoo: odoo</p>
				<p>Usuario creado en PostgreSQL: odoo</p>
				<p>Contraseña para odoo en PostgreSQL: $pass1</p>
				<p>Contraseña de acceso a Odoo: $odooPass1</p>
			</article>
			<p/>
			<article>
			<h2>Paquetes instalados en el sistema:</h2>
				<p>Recuerda que estos paquetes se encuentran listados en el archivo pkgs-installed-odoo.txt</p>
				<p>Paquetes instalados en el sistema: $total_pkgs</p>
				<p>Listado: $(xargs -n 1 < pkgs-installed-odoo.txt)</p>
			</article> 
			</p>
			<footer>
			  <p>Odoo-easy-installer v$version_instalador<br>
			  Autor: Héctor Monroy Fuertes<br>
			  GitHub: 
			  <a href="https://github.com/HectorCRM/Odoo-easy-installer">github.com/HectorCRM/Odoo-easy-installer</a><br>
			  <a href="mailto:monroygti2.0@gmail.com">monroygti2.0@gmail.com</a></p>
			</footer>	
		</main>
	   
	</body>
	</html>

EOF

	#Cambiar permisos al informe de instalación para que sólo el root pueda leerlo
	sudo chmod 600 informe-instalacion.html



	rm /tmp/pkgs-installed-before.txt /tmp/pkg-installed-after.txt /tmp/pkgs-installed-before-ordenado.txt /tmp/pkg-installed-after-ordenado.txt || true

	echo -e "\e[32m¡¡Instalación terminada!! \e[39m"
	printf "La instalación ha tardado: %02d:%02d\n"  $((SECONDS%3600/60)) $((SECONDS%60))

	if [[ "$vm" == "true" ]]; then 
		ip=$(hostname -I | awk '{print $1}')
		echo -e "\e[32mPara acceder a Odoo desde tu máquina host introduce en el navegador: http://$ip:$puerto_odoo \e[39m"
		
	else
		echo -e "\e[33mPara acceder a Odoo introduce en tu navegador http://localhost:$puerto_odoo \e[39m"
	fi
	#Limpieza de variables y archivos temporales
	echo -e "\e[33mLimpiando variables y archivos temporales... \e[33m"
	unset puerto_odoo version_instalador usuario_odoo home_odoo usuario_postgres reintento pass1 pass2 odooPass1 odooPass2 pkgs_installed ip vm total_pkgs express forma_instalacion
	read -rp "Pulsa enter para terminar"
	xdg-open informe-instalacion.html
	if [[ "$pgadmin" == "false" ]]; then
		read -rp "Pulsa enter para terminar"
		xdg-open informe-instalacion.html
		exit 0
	else
		echo -e "\e[33mIniciando instalación de PgAdmin4... \e[39m"
		sleep 2 
		echo -e "\e[33mClonando repositorio... \e[39m"
		sleep 2
		git clone https://github.com/HectorCRM/pgAdmin4-easy-installer.git
		cd pgAdmin4-easy-installer
		chmod +x pgAdmin4-install.sh
		./pgAdmin4-install.sh
		echo -e "\e[36m¿Te ha sido útil? Déjame una estrellita en el proyecto en GitHub o cuéntamelo por LinkedIn(www.linkedin.com/in/héctor-monroy-fuertes-0a305b201)\e[0m"
		read -rp "Pulsa 'Enter' para terminar"
		exit 0
	fi
fi
