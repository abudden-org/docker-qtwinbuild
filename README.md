This is a docker target for cross-compiling Qt5 for Windows projects from docker.

To use it, create a `docker-compose.yml` looking something like this:

```
version: "2"
services:
    qtbuild:
        build: .
        volumes:
            - .:/home/builduser/project
```

You can replace "build: ." with "from: abudden/qtwinbuild" to use the docker
hub version.  The "." in the volume entry assumes that the docker-compose.yml
file is in the same folder as your Qt project.  By default, the docker container
will build a static version using `qmake && make clean && make`.  To change this,
create a local Dockerfile that looks a bit like this:

```
FROM abudden/qtwinbuild

# Pick one of these:
CMD /mxe/usr/bin/x86_64-w64-mingw32.shared-qmake-qt5 && make clean && make
# CMD /mxe/usr/bin/x86_64-w64-mingw32.static-qmake-qt5 && make clean && make
# CMD /mxe/usr/bin/x86_64-w64-mingw32.shared.posix-qmake-qt5 && make clean && make
# CMD /mxe/usr/bin/x86_64-w64-mingw32.static.posix-qmake-qt5 && make clean && make
```
