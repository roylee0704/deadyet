APPNAME=deadyet

export GOPATH:=$(shell pwd)
export PATH:=$(PATH):$(GOPATH)

linux:
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o $(APPNAME) .
