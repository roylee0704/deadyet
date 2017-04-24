package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"sync"
	"time"
)

var (
	httpAddr   = flag.String("http", ":8080", "Listen Address")
	env        = flag.String("env", "test01", "Target Environment")
	pollPeriod = flag.Duration("poll", 5*time.Second, "Poll Period")
)

const baseChangeURL = "http://gobike-api-%s.ap-southeast-1.elasticbeanstalk.com"

func main() {
	flag.Parse()
	changeURL := fmt.Sprintf(baseChangeURL, *env)
	http.Handle("/", NewServer(*env, changeURL, *pollPeriod))
	http.ListenAndServe(*httpAddr, nil)
}

// Server implements http.Handler.
// It serves the web user interface
// and polls the GoBike env URL for health status.
type Server struct {
	env    string
	url    string
	period time.Duration

	mu  sync.Mutex
	yes bool
}

// NewServer returns an initialise deadyet server.
func NewServer(env, url string, period time.Duration) *Server {
	s := &Server{env: env, url: url, yes: false, period: period}
	go s.poll()
	return s
}

// poll polls the change URL for the specific period until
// the
func (s *Server) poll() {
	for {
		s.mu.Lock()
		s.yes = !s.isAlive()
		s.mu.Unlock()
		time.Sleep(s.period)
	}
}

func (s *Server) isAlive() bool {
	r, err := http.Head(s.url)
	if err != nil {
		log.Print(err)
		return false
	}
	return r.StatusCode == http.StatusOK
}

func (s *Server) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Is %s (%s) Dead Yet? \n%t", s.url, s.env, s.yes)
}
