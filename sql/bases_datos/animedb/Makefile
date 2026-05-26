CONTAINER_NAME=animedb
IMAGE_NAME=animedbimage
VOLUME_NAME=animedbvolume
IMAGE_MYSQL=mysql:lts

create:
	podman build -t $(IMAGE_NAME) .
	podman volume inspect $(VOLUME_NAME) >/dev/null 2>&1 || podman volume create $(VOLUME_NAME)
	podman run -d \
		--name $(CONTAINER_NAME) \
		--replace \
		-p 3306:3306 \
		-v $(VOLUME_NAME):/var/lib/mysql \
		-e MYSQL_ROOT_PASSWORD=root090215 \
		-e MYSQL_DATABASE=animedb \
		-e MYSQL_USER=edgar \
		-e MYSQL_PASSWORD=090215 \
		$(IMAGE_NAME)
	@echo "Esperando a que MySQL abra el puerto 3306..."
	@until podman logs $(CONTAINER_NAME) 2>&1 | grep -q "ready for connections"; do \
		sleep 1; \
	done
	echo "Finalizado"
	# podman exec -it animedb mysql -u edgar -p -D animedb

clean:
	podman stop $(CONTAINER_NAME) || true
	podman rm $(CONTAINER_NAME) || true
	podman volume rm $(VOLUME_NAME) || true
	podman rmi $(IMAGE_NAME) || true