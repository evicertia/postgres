ARG VERSION=0.0
ARG PG_MAJOR=12
FROM postgres:$PG_MAJOR AS builder
ENV PG_MAJOR=$PG_MAJOR
ENV SQLITE_FDW_VERSION=v2.0.0
WORKDIR /workdir
RUN apt-get update
RUN apt-get -y install libsqlite3-dev wget build-essential postgresql-server-dev-$PG_MAJOR
RUN wget https://github.com/pgspider/sqlite_fdw/archive/refs/tags/$SQLITE_FDW_VERSION.tar.gz
RUN tar xzf $SQLITE_FDW_VERSION.tar.gz -C /workdir
RUN mkdir /destdir && cd /workdir/sqlite_fdw* &&  make USE_PGXS=1 && make install USE_PGXS=1 DESTDIR=/destdir

FROM postgres:$PG_MAJOR
RUN mkdir -p /workdir
WORKDIR /workdir
COPY --from=builder /destdir/. /

LABEL version=${VERSION} description="PostgreSQL $PG_MAJOR + sqlite fdw" maintainer="ahuete@evicertia.com" vendor="evicertia"
