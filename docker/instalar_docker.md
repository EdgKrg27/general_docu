# Comandos para la instalación de Docker en terminal Linux (Debian, Ubuntu)

Se debe utilizar el repositorio oficial de Docker para tener las versiones más recientes de Docker.

1. Eliminar instalaciones anteriores

```bash
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
	sudo apt-get remove -y $dpkg
done
```

2. Actualización de paquetes

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg
```

3. Agrega la llave GPG oficial

```bash
sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

4. Agrega el repositorio oficial

```bash
echo \
"deb [arch=$dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(: /etc/os-release && echo "$VERSION_CODENAME") stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

5. Actualizar nuevamente los paquetes

```bash
sudo apt update
```

6. Instalar Docker

```bash
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

7. Verificación de la instalación

```bash
docker --version

docker compose version
```

8. Prueba de Docker

```bash
sudo docker run hello-world
```

9. Permitir el uso de Docker sin sudo

Agregamos el usuario al grupo docker


```bash
sudo usermod -aG docker $USER
```

Aplicar el cambio

```bash
newgrp docker
```

Comprobación del docker

```bash
docker run hello-world
```
