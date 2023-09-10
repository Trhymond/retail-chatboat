FROM node:alpine

WORKDIR /app

COPY package.json /package.json
RUN npm install

COPY . .
EXPOSE 80:8080
CMD ["npm", "run", "dev"]
 