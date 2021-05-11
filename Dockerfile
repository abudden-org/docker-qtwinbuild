FROM ubuntu:bionic
MAINTAINER A. S. Budden <abudden@gmail.com>

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt-get update && apt-get -y install \
		autoconf \
		automake \
		autopoint \
		bash \
		bison \
		build-essential \
		bzip2 \
		flex \
		g++ \
		g++-multilib \
		gettext \
		git \
		gperf \
		intltool \
		libc6-dev-i386 \
		libgdk-pixbuf2.0-dev \
		libltdl-dev \
		libssl-dev \
		libtool-bin \
		libxml-parser-perl \
		make \
		openssl \
		p7zip-full \
		patch \
		perl \
		pkg-config \
		python \
		python-mako \
		python3-mako \
		ruby \
		scons \
		sed \
		tzdata \
		unzip \
		wget \
		xz-utils \
		lzip
WORKDIR /
RUN git clone https://github.com/mxe/mxe.git
WORKDIR /mxe
# The following is the changeset ID of master as of 27/1/2021 at 08.49
#RUN git checkout 138fcd2e5d377caae209342f304c0c926a423425

ENV MXE_TARGETS "x86_64-w64-mingw32.shared x86_64-w64-mingw32.static x86_64-w64-mingw32.shared.posix x86_64-w64-mingw32.static.posix"
ENV MXE_PLUGIN_DIRS plugins/gcc10

RUN make download-gcc
RUN make MXE_PLUGIN_DIRS="$MXE_PLUGIN_DIRS" MXE_TARGETS="x86_64-w64-mingw32.shared" cc
RUN make MXE_PLUGIN_DIRS="$MXE_PLUGIN_DIRS" MXE_TARGETS="x86_64-w64-mingw32.static" cc
RUN make MXE_PLUGIN_DIRS="$MXE_PLUGIN_DIRS" MXE_TARGETS="x86_64-w64-mingw32.shared.posix" cc
RUN make MXE_PLUGIN_DIRS="$MXE_PLUGIN_DIRS" MXE_TARGETS="x86_64-w64-mingw32.static.posix" cc
RUN make MXE_TARGETS="$MXE_TARGETS" boost
RUN make MXE_TARGETS="$MXE_TARGETS" cmake
RUN make MXE_TARGETS="$MXE_TARGETS" freetype
RUN make MXE_TARGETS="$MXE_TARGETS" fontconfig
RUN make MXE_TARGETS="$MXE_TARGETS" sqlite
RUN make MXE_TARGETS="$MXE_TARGETS" freetds
RUN make MXE_TARGETS="$MXE_TARGETS" postgresql
RUN make MXE_TARGETS="$MXE_TARGETS" libmysqlclient
RUN make MXE_TARGETS="$MXE_TARGETS" jpeg pcre2

RUN make MXE_PLUGIN_DIRS="$MXE_PLUGIN_DIRS" MXE_TARGETS="x86_64-w64-mingw32.shared" qt5
RUN make MXE_PLUGIN_DIRS="$MXE_PLUGIN_DIRS" MXE_TARGETS="x86_64-w64-mingw32.static" qt5
RUN make MXE_PLUGIN_DIRS="$MXE_PLUGIN_DIRS" MXE_TARGETS="x86_64-w64-mingw32.shared.posix" qt5
RUN make MXE_PLUGIN_DIRS="$MXE_PLUGIN_DIRS" MXE_TARGETS="x86_64-w64-mingw32.static.posix" qt5

RUN ls /mxe/usr/bin

ENV PATH /mxe/usr/bin:$PATH

RUN useradd -s /bin/bash -m -u 1000 builduser
RUN chown -R builduser /home/builduser

# Add a qmake alias
RUN ln -s /mxe/usr/bin/x86_64-w64-mingw32.static-qmake-qt5 /mxe/usr/bin/qmake

USER builduser

WORKDIR /home/builduser/project/

CMD qmake && make clean && make
