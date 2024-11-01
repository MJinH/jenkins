FROM node:alpine
# app folder
ENV CI=true
ENV WDS_SOCKET_PORT=0
WORKDIR /app
COPY ./client/package.json .
RUN npm install

# copy everything to app folder
COPY . .

# set up command to run with the image or container first starts up
CMD ["npm", "run", "start"]