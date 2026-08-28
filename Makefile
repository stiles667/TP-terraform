.PHONY: apply inventory build ci docker-build clean

apply:
	$(MAKE) -C CI-CD-proj-final apply

inventory:
	$(MAKE) -C CI-CD-proj-final inventory

build:
	$(MAKE) -C CI-CD-proj-final build

ci:
	$(MAKE) -C CI-CD-proj-final ci

docker-build:
	$(MAKE) -C CI-CD-proj-final docker-build

clean:
	$(MAKE) -C CI-CD-proj-final clean
