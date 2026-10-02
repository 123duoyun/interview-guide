DOCKER ?= docker
FRONTEND_IMAGE ?= interview-frontend
APP_IMAGE ?= interview-app
REGISTRY = crpi-jr4becmh09ijs655.cn-shanghai.personal.cr.aliyuncs.com
NAMESPACE = lyw1
IMAGE_NAME = interview-guide
USERNAME = luoyunwen
PASSWORD = 12345678aB.
COMMIT_SHA = $(shell git rev-parse --short HEAD || echo latest)
TAG ?= $(COMMIT_SHA)
FRONTEND_IMAGE_NAME = $(REGISTRY)/$(NAMESPACE)/$(FRONTEND_IMAGE):$(TAG)
APP_IMAGE_NAME = $(REGISTRY)/$(NAMESPACE)/$(APP_IMAGE):$(TAG)

.PHONY: docker-login docker-build-frontend docker-build-app docker-build-all \
        docker-push-frontend docker-push-app docker-push-all \
        docker-pull-frontend docker-pull-app docker-pull-all up down

docker-login:
	@echo "正在登录到 Docker 镜像仓库..."
	@echo $(PASSWORD)| docker login --username=$(USERNAME) --password-stdin $(REGISTRY)

docker-build-frontend:
	$(DOCKER) buildx build --platform linux/amd64 --load --provenance=false --sbom=false -f frontend/Dockerfile -t $(FRONTEND_IMAGE_NAME) ./frontend

docker-build-app:
	$(DOCKER) buildx build --platform linux/amd64 --load --provenance=false --sbom=false -f app/Dockerfile -t $(APP_IMAGE_NAME) .

docker-build-all: docker-build-frontend docker-build-app

docker-push-frontend: docker-build-frontend
	@echo "正在推送 Docker 镜像到仓库: $(FRONTEND_IMAGE_NAME)"
	docker push $(FRONTEND_IMAGE_NAME)
	docker tag $(FRONTEND_IMAGE_NAME) $(REGISTRY)/$(NAMESPACE)/$(FRONTEND_IMAGE):latest
	docker push $(REGISTRY)/$(NAMESPACE)/$(FRONTEND_IMAGE):latest

docker-push-app: docker-build-app
	@echo "正在推送 Docker 镜像到仓库: $(APP_IMAGE_NAME)"
	docker push $(APP_IMAGE_NAME)
	docker tag $(APP_IMAGE_NAME) $(REGISTRY)/$(NAMESPACE)/$(APP_IMAGE):latest
	docker push $(REGISTRY)/$(NAMESPACE)/$(APP_IMAGE):latest

docker-push-all: docker-push-frontend docker-push-app

docker-pull-frontend:
	docker pull $(FRONTEND_IMAGE_NAME)

docker-pull-app:
	docker pull $(APP_IMAGE_NAME)

docker-pull-all: docker-pull-frontend docker-pull-app

up: docker-build-all
	docker compose up -d

down:
	docker compose down
