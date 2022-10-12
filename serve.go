package main

import (
	"net/http"
	"os"
)

func main() {
	port := ":8080"
	handler := http.FileServer(http.Dir(os.Args[1]))
	http.ListenAndServe(port, handler)
}
