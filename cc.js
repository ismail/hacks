var XMLHttpRequest = require('xhr2');
var xhr = new XMLHttpRequest();

function compile(data) {
  xhr.open("POST", "http://coliru.stacked-crooked.com/compile", true);
  xhr.onload = function(e) {
    if (xhr.readyState === 4) {
      if (xhr.status === 200) {
        console.log(xhr.responseText);
      } else {
        console.error(xhr.statusText);
      }
      process.exit()
    }
  };

  xhr.onerror = function(e) { console.error(xhr.statusText); };
  xhr.send(JSON.stringify({
    "cmd": "clang++ -std=c++11 -Wall -g -fsanitize=undefined main.cpp && ./a.out",
    "src": data
  }));
}

process.stdin.resume();
process.stdin.setEncoding('utf8');

process.stdin.once('data', function(text) { compile(text); });
