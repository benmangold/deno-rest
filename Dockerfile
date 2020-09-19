# source: https://github.com/hayd/deno-docker/blob/master/alpine.dockerfile

FROM frolvlad/alpine-glibc:alpine-3.12_glibc-2.32 as builder

ENV DENO_VERSION=1.4.0

RUN apk add --virtual .download --no-cache curl \
        && curl -fsSL https://github.com/denoland/deno/releases/download/v${DENO_VERSION}/deno-x86_64-unknown-linux-gnu.zip \
        --output deno.zip \
        && unzip deno.zip \
        && rm deno.zip \
        && chmod 777 deno \
        && mv deno /bin/deno \
        && apk del .download

RUN addgroup -g 1993 -S deno \
        && adduser -u 1993 -S deno -G deno \
        && mkdir /deno-dir/ \
        && chown deno:deno /deno-dir/

FROM frolvlad/alpine-glibc:alpine-3.12_glibc-2.32

COPY --from=builder /bin/deno /usr/local/bin

WORKDIR /home/deno

COPY . .

RUN adduser --disabled-password --gecos '' deno

RUN chown -R deno:deno /home/deno

USER deno

EXPOSE 8000

RUN deno install server.ts

CMD ["deno", "run","--allow-net", "server.ts"]