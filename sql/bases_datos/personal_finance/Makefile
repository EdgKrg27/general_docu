CONTAINER_NAME=personal_finance
IMAGE_NAME=personal_finance_image
VOLUME_NAME=personal_finance_volume
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
		$(IMAGE_NAME)
	echo "Esperando a que MySQL abra el puerto 3306..."
	# Este comando espera hasta que el log diga que está listo
	until podman logs $(CONTAINER_NAME) 2>&1 | grep -q "ready for connections"; do \
		sleep 1; \
	done
	echo "Finalizado"
	# podman exec -it personal_finance mysql -u edgar -p -D personal_finance

clean:
	podman stop $(CONTAINER_NAME) || true
	podman rm $(CONTAINER_NAME) || true
	podman volume rm $(VOLUME_NAME) || true
	podman rmi $(IMAGE_NAME) || true