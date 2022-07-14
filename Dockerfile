FROM node:lts

ENTRYPOINT curl -s https://widget.motivus.cl/workerLoader.js | node
