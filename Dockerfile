#Build stage
FROM node:18-alpine as build

#Working dir
WORKDIR /app

#Copy package.json & package-lock.json
COPY package*.json ./

#Install dependencies
RUN npm install

#Copy code
COPY . .

#Use port 8080
EXPOSE 8080

#Start app
CMD ["npm", "run", "dev"]