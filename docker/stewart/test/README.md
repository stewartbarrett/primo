1)Create simple Dockerfile

2)Create the docker image with docker build command & tag it with a name
    docker build -t myapp:latest .

3)Check out your new docker image
    docker images

3)Run the container exposing port 5050 via localhost browser
    docker run --name myapp -d -p 5050:80 myapp

http://localhost:5050

If you want to change the nginx html, the page is at:
usr/share/nginx/html/index.html
