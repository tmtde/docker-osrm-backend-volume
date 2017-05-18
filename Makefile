IMAGE_NAME := tmtde/osrm-backend-volume

build:
	docker build --rm -t $(IMAGE_NAME) .
	
run:
	@echo docker run --rm -it $(IMAGE_NAME)
	
shell:
	docker run --rm -it --entrypoint sh $(IMAGE_NAME) -l

test: build
	docker run --rm -it tmtde/osrm-backend-volume osrm-routed -h | head -1 | tail -1 | cut -d' ' -f1 
