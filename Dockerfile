FROM alpine:3.13 AS base


RUN apk add --no-cache git \
            nodejs \
            npm && \
    mkdir -p /usr/src/node-red /data && \
    adduser -h /usr/src/node-red -D -H node-red -u 1000 && \
    chown -R node-red:node-red /data 

FROM nodered/node-red:2.2.2-minimal AS build

COPY package.json .

RUN npm install \
        --unsafe-perm --no-update-notifier \ 
        --no-audit --only=production

RUN npm install @cloudnative/health-connect swagger-ui-express

COPY red.js /usr/src/node-red/node_modules/node-red/red.js

FROM base as prod

COPY --from=build --chown=node-red:node-red /data/ /data/

WORKDIR /usr/src/node-red
#COPY server.js  /data/server.js
COPY settings.js /data/settings.js
COPY flows.json  /data/flows.json
COPY red.js /usr/src/node-red/node_modules/node-red/red.js

COPY --from=build --chown=node-red:node-red /usr/src/node-red/  /usr/src/node-red/
USER node-red
COPY red.js /usr/src/node-red/node_modules/node-red/red.js

CMD ["npm", "start"]
