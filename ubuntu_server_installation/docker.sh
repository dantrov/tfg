#!/bin/bash

# Comprobación de privilegios
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root o usando sudo."
  exit 1
fi

echo "Actualizando repositorios..."
apt update -y
apt upgrade -y
echo "Repositorios actualizados."

echo "Instalando dependencias necesarias..."
apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
echo "Dependencias instaladas."

echo "Añadiendo clave GPG oficial de Docker..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "Clave GPG añadida."

echo "Añadiendo repositorio de Docker..."
ARCH=$(dpkg --print-architecture)
RELEASE=$(lsb_release -cs)
echo \
  "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $RELEASE stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Actualizando repositorios con el nuevo repositorio de Docker..."
apt update -y

echo "Instalando Docker Engine, CLI y containerd..."
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
echo "Docker instalado correctamente."

echo "Habilitando e iniciando el servicio Docker..."
systemctl enable docker
systemctl start docker

echo "Instalando Docker Compose (versión independiente)..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

# Verificación
echo "Versión de Docker:"
docker --version
echo "Versión de Docker Compose:"
docker-compose --version

echo "Instalación de Docker y Docker Compose completada."
