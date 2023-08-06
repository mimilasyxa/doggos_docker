FROM node:15

RUN npm install pm2 -g

WORKDIR /home/node/app

COPY pm2.json ../

EXPOSE 3000

CMD pm2-runtime start ../pm2.json
