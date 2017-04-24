APPNAME=deadyet
RELEASE_APPNAME=roylee0704/$(APPNAME)
ECR_REPO=368117745450.dkr.ecr.ap-southeast-1.amazonaws.com/$(RELEASE_APPNAME)
CMD_REPOLOGIN = "eval $$\(aws ecr get-login --region ap-southeast-1 --profile roylee0704 \)"
VERSION=0.0.1

export GOPATH:=$(shell pwd)
export PATH:=$(PATH):$(GOPATH)

linux:
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o $(APPNAME) .

.build:
	docker build -t $(APPNAME) .
	docker inspect -f '{{.Id}}' $(APPNAME) > .build

build: .build

release/$(APPNAME): build
	docker run --rm --entrypoint /bin/sh $(APPNAME) -c 'tar cf - $(APPNAME)' > $@ || (rm -f $@; false)
	docker build --rm -t $(RELEASE_APPNAME) release

release: release/$(APPNAME)

# to push docker image to Cloud.
publish: release
	@eval $(CMD_REPOLOGIN)
	docker tag $(RELEASE_APPNAME):latest $(ECR_REPO):$(VERSION)
	docker push $(ECR_REPO):$(VERSION)

.elasticbeanstalk:
	eb init --profiler roylee0704

deploy: .elasticbeanstalk
	eb use

clean:
	rm .build release/$(APPNAME)
