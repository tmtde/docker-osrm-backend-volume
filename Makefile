IMAGE_NAME := tmtde/osrm-backend-volume

OSRM_EXTRACT := docker run -t -v $$(pwd)/data:/data osrm/osrm-backend osrm-extract
OSRM_CONTRACT := docker run -t -v $$(pwd)/data:/data osrm/osrm-backend osrm-contract
MAP_URL := http://download.geofabrik.de/europe/germany
# Latest map filename has date of yesterday
MAP_LATEST := $(shell date --date yesterday "+%y%m%d")

# See if LOCATION.txt exist and use first word as location
ifneq ("$(wildcard LOCATION.txt)","")
	MAP_LOCATION := $(shell head -1 LOCATION.txt | tail -1 | cut -d' ' -f1)
else
	# Fallback to small map
	MAP_LOCATION := bremen
endif

# Construct map filename (of latest build)
ifndef $(MAP_FILE)
	MAP_FILE := $(MAP_LOCATION)-$(MAP_LATEST).osm.pbf
endif

build:
	docker build --rm -t $(IMAGE_NAME) .
	
clean: map-clean
	test $$(docker image list | grep -c $(IMAGE_NAME)) -gt 0  && docker image rm $(IMAGE_NAME) || true

run:
	@echo docker run --rm -it $(IMAGE_NAME)
	
shell:
	docker run --rm -it --entrypoint sh $(IMAGE_NAME) -l
	
# Remove old artefacts from map build
map-clean:
	rm -f $$(pwd)/data/*.osm.pbf $$(pwd)/data/*.osrm*
	
map-build: map-fetch map-extract map-contract

# Fetch latest map
map-fetch:
	mkdir -p $$(pwd)/data/
	[ -f $$(pwd)/data/$(MAP_FILE) ] || wget $(MAP_URL)/$(MAP_FILE) -O $$(pwd)/data/$(MAP_FILE)

# Extract the map
map-extract: map-fetch
	@echo "Running osrm-extract..."
	[ -f /data/$$(basename $(MAP_FILE) .osm.pbf).osrm ] || $(OSRM_EXTRACT) -p /opt/car.lua /data/$(MAP_FILE)

# Contract the map
map-contract: map-extract
	@echo "Running osrm-contract..."
	$(OSRM_CONTRACT) /data/$$(basename $(MAP_FILE) .osm.pbf).osrm

# Trigger build test and (re-)build a map
test: build-test map-clean map-build

# Test if the docker images is build and osrm-routed works as expected
build-test: build
	docker run --rm -it $(IMAGE_NAME) osrm-routed -h | head -1 | tail -1 | cut -d' ' -f1
