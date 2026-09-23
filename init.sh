#!/bin/bash
# Actualizar el sistema e instalar Docker
apt-get update -y
apt-get install -y docker.io
systemctl start docker
systemctl enable docker

# Levantar un servidor web Nginx puro en el puerto 80 (Simula la app de tu empresa)
docker run -d -p 80:80 nginx:latest
