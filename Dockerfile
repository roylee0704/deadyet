FROM            golang

# Recompile standard library without CGO
RUN             CGO_ENABLED=0 go install -a std

# keep cache above if maintainer changes.
MAINTAINER      roylee0704 <roy@gobike.asia>

ENV             APP_DIR    $GOPATH/src/deadyet

ENTRYPOINT      ["./deadyet"]

ADD             .          $APP_DIR
RUN             cd $APP_DIR && make linux && mv deadyet $GOPATH

EXPOSE 8080
