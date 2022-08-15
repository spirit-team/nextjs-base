FROM node:lts-alpine3.16 AS builder
## to avoid https denied error
RUN sed -i 's/https/http/' /etc/apk/repositories

RUN apk add --no-cache bash make g++ curl openssl ca-certificates
RUN update-ca-certificates 

WORKDIR /app
# OS packages for compilation
#RUN apk add --no-cache bash python2 make g++ curl openssl ca-certificates

#COPY package.json package-lock.json ./
COPY package.json ./
RUN npm config set cafile /etc/ssl/certs/ca-certificates.crt --location=global && \
npm install -g npm@latest minimatch@3.0.5 && \
npm install
#RUN npm ci
COPY . .

#RUN npm run build
#RUN npm prune --production

FROM node:lts-alpine3.16 AS production
## to avoid https denied error
RUN sed -i 's/https/http/' /etc/apk/repositories
ENV NODE_ENV=production

WORKDIR /app
## Also copy any custom non-next code you might have e.g. server.js
# COPY --from=builder --chown=node:node /app/src ./src
#COPY --chown=node:node package.json next.config.js ./
COPY --chown=node:node package.json ./
COPY --from=builder --chown=node:node /app/node_modules ./node_modules

RUN apk add --no-cache bash curl openssl ca-certificates
RUN update-ca-certificates && \
npm config set cafile /etc/ssl/certs/ca-certificates.crt --location=global && \
npm install -g npm@latest minimatch@3.0.5  && \
#rm -rf /usr/local/lib/node_modules &&\
apk upgrade
