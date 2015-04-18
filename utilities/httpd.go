package main
 
import(
    "net/http"
    "flag"
)
 
func main() {
    var dir = flag.String("directory", "C:/", "Directory to serve.")
    flag.Parse()
    h := http.FileServer(http.Dir(*dir))
    http.ListenAndServe(":8080", h)
}
