#!/bin/bash

# Comprobación de privilegios
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root o usando sudo."
  exit 1
fi

echo "Actualizando repositorios..."
apt update -y
echo "Repositorios actualizados."

echo "Instalando Apache..."
apt install apache2 -y
echo "Apache instalado correctamente."

echo "Instalando PHP..."
apt install php libapache2-mod-php php-mysql -y
echo "PHP instalado correctamente."

# Preguntar por la base de datos
echo "¿Qué sistema de base de datos deseas instalar? (mysql/mariadb)"
read -r db_choice

if [[ "$db_choice" == "mysql" ]]; then
  echo "Instalando MySQL Server..."
  apt install mysql-server -y
  echo "MySQL Server instalado correctamente."
elif [[ "$db_choice" == "mariadb" ]]; then
  echo "Instalando MariaDB Server..."
  apt install mariadb-server -y
  echo "MariaDB Server instalado correctamente."
else
  echo "Opción no válida. No se instalará ninguna base de datos."
fi

echo "Habilitando servicios..."
systemctl enable apache2
systemctl start apache2

if [[ "$db_choice" == "mysql" ]]; then
  systemctl enable mysql
  systemctl start mysql
elif [[ "$db_choice" == "mariadb" ]]; then
  systemctl enable mariadb
  systemctl start mariadb
fi

echo "Instalación completa."
