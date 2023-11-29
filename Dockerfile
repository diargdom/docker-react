# development
# FROM node:14-alpine AS base
# RUN mkdir -p /home/node/app
# RUN chown -R node:node /home/node && chmod -R 770 /home/node
# WORKDIR /home/node/app
FROM node:20-alpine AS development
RUN mkdir -p /home/node/app
RUN chown -R node:node /home/node && chmod -R 770 /home/node
WORKDIR /home/node/app

# server-side
FROM development AS builder-server
WORKDIR /home/node/app
RUN apk add --no-cache --virtual .build-deps git make python3 g++
COPY --chown=node:node ./package.json ./package.json
COPY --chown=node:node ./package-lock.json ./package-lock.json
USER node
RUN npm install --loglevel warn --production

# client build
# FROM base AS builder-client
# WORKDIR /home/node/app
# COPY --chown=node:node . ./
# USER node
# RUN npm install --loglevel warn
# EXPOSE 3000
# CMD ["npm", "start"]
FROM development AS builder-client
WORKDIR /home/node/app
COPY --chown=node:node . ./
USER node
RUN npm install --loglevel warn
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]

#production
FROM development AS production
WORKDIR /home/node/app
USER node
COPY --chown=node:node --from=builder-client /home/node/app/build ./build/
COPY --chown=node:node --from=builder-server /home/node/app/node_modules ./node_modules
COPY --chown=node:node ./package.json ./package.json
COPY --chown=node:node ./package-lock.json ./package-lock.json
COPY --chown=node:node ./public ./public
EXPOSE 3000
CMD ["npm", "run", "server"]