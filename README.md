# gitbook docker image
The old version of gitbook has been officially abandoned. So I create a docker image based on gitbook 3.2.3 with node 10.

## Usage
### Building pdf
```dockerfile
FROM yunnysunny/gitbook:latest  AS build-stage
WORKDIR /opt
COPY . /opt
RUN gitbook pdf .

FROM scratch AS export-stage
COPY --from=build-stage /opt/book.pdf /
```

## Tag
1.0.0