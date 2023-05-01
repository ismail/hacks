package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
)

func main() {
	args := os.Args[1:]

	if len(args) < 1 {
		log.Fatal("Please provide a directory as the first argument.")
	}

	dir := args[0]
	http.Handle("/", http.FileServer(http.Dir(dir)))

	port := 8080
	if len(args) >= 2 {
		var err error
		port, err = strconv.Atoi(args[1])
		if err != nil {
			log.Fatalf("Invalid port: %s. Please provide a valid integer.", args[1])
		}
	}

	fmt.Printf("Serving files from '%s' on port %d\n", dir, port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%d", port), nil))
}
