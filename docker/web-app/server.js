//http://htmldog.com/examples/
var http = require('http');
var fs = require('fs');

// 404 if thisngs go wrong
function send404Response(response){
  response.writeHead(404, {"Content-Type": "text/plain"});
  response.write("Error 404: Page not found!");
  response.end();
}

//Handle user request
function onRequest (request, response) {

  if( request.method == 'GET' && request.url == '/' ){
    response.writeHead(200, {"Content-Type": "text/html"});
    fs.createReadStream("./index-gg.html").pipe(response);
  }else{
    send404Response(response);
  }
}

http.createServer(onRequest).listen(8889);
console.log("Server is now runing...");
