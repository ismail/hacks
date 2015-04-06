var XMLHttpRequest = require('xhr2');
var xhr = new XMLHttpRequest();
var data = '';

function compile(data) {
  xhr.open("POST", "http://coliru.stacked-crooked.com/compile", true);
  xhr.onload = function(e) {
    if (xhr.readyState === 4) {
      if (xhr.status === 200) {
        console.log(xhr.responseText.trim());
      } else {
        console.error(xhr.statusText);
      }
      process.exit()
    }
  };

  xhr.onerror = function(e) { console.error(xhr.statusText); };
  xhr.send(JSON.stringify({
    "cmd" :
        "clang++ -std=c++14 -Weverything -Wno-c++98-compat -g -fsanitize=undefined main.cpp && ./a.out",
    "src" : data
  }));
}

process.stdin.resume();
process.stdin.setEncoding('utf8');

process.stdin.on('data', function(text) { data += text; });
process.stdin.on('end', function() { compile(data) });
