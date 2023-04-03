## Node.js authentication app implemented with Docker container

### Project setup

- `npm init -y`
- `npm install express mongoose bcrypt jsonwebtoken dotenv nodemon`

The above command installs the required dependencies for our authentication application. Let's take a closer look at each of these dependencies:

- `express`: A popular Node.js framework for building web applications and APIs.

- `mongoose`: A library that provides a simple schema-based solution for modeling MongoDB data.

- `bcrypt`: A library used for password hashing and storing passwords securely.

- `jsonwebtoken`: A library used for generating and verifying JSON web tokens.

- `dotenv`: A zero-dependency module that loads environment variables from a .env file into process.env. We will use this to load sensitive configuration data for our application.

- `nodemon`: a tool for Node.js that automatically restarts the application when changes are made to the code, making development easier and more efficient.

By installing these dependencies, we have laid the foundation for our authentication API. In the next section, we will create the basic structure of our application and define the necessary routes.

### Application structure

To ensure a more organized and maintainable code base, we will create a `src` directory that will house our application files and folders. Within the `src` directory, we will create a `routes` directory and define our registration and login routes in separate files. Also within `src` create file `server.js` We will also create a `models` directory to define our database schema and models for user registration and authentication. Finally, we will create the `controllers` directory.

#### Express Server `server.js`

```javascript
const express = require("express");
const mongoose = require("mongoose");
const dotenv = require("dotenv");
const router = require("./routes/auth");

dotenv.config();

const app = express();
const port = process.env.PORT || 8080;

const connectDB = async () => {
  try {
    await mongoose.connect(
      process.env.MONGO_URI || "mongodb://localhost:27017/docker-node-app"
    );
    console.log("MongoDB connected");
  } catch (error) {
    console.error(error);
  }
};

connectDB();

app.use(express.json());
app.use("/api", router);

app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`);
});
```

#### Users

Create `models/user.js` and complete the schema.

Each user will have a `name`, `email` and `password`

We will use `bcrypt` to hash the passwords

#### Routes

Create `routes/auth.js` and define 2 routes:

- `/register`
- `/login`

#### Controllers

Create `controllers/authController.js` and define two functions: register and login.

Let's start with the `register` function. Here, we are creating a new user in our database using the `User.create()` method from the `Mongoose` library. This method takes in the user object that we have received from the client and saves it to our MongoDB database. This function also automatically hashes the user's password using the `bcrypt` library before saving it to the database, ensuring that the password is secure and cannot be easily decrypted.

Moving on to the `login` function, we first search for the user by their email address using the `User.findOne()` method from `Mongoose`. Once we have the user object, we then use the `bcrypt.compare()` method to check if the password provided by the user matches the hashed password in the database. If the password is correct, it generates a `JSON Web Token` (JWT) using the `jwt.sign()` method from the `jsonwebtoken` package. This token contains the user's ID, email address, and an expiration time, and is sent back to the client for use in subsequent API requests.

Overall, these two functions provide the basic functionality required for user authentication in our application. The register function allows new users to create an account with a secure, hashed password, while the login function verifies the user's credentials and generates a secure token for future use.

#### Update `package.json`

Update `package.json` `scripts` and `keywords`:

```json
  "scripts": {
    "dev": "nodemon src/server.js",
    "build": "NODE_ENV=production node server.js"
  },
  "keywords": [
    "docker",
    "node"
  ],
```

### Docker

#### Create Dockerfile

The first line of the Dockerfile specifies the base image that we'll use to build our Node.js application. In this case, we're using the `node:18-alpine` image, which is a lightweight Alpine Linux-based image that includes Node.js 18.

`FROM node:18-alpine as build`

Next, we set the working directory for our application inside the Docker container:

`WORKDIR /app`

We then copy the package.json and package-lock.json files to the working directory:

`COPY package\*.json ./`

This step is important because it allows Docker to cache the installation of our application's dependencies. If these files haven't changed since the last build, Docker can skip the installation step and use the cached dependencies instead.

We then install our application's dependencies using npm install:

`RUN npm install`

After that, we copy the rest of our application's source code to the Docker container:

`COPY . .`

This includes all of our application's JavaScript files, as well as any static assets like images or stylesheets.

Next, we expose port 8080 to the outside world:

`EXPOSE 8080`

Finally, we specify the command that will be run when the Docker container starts up. In this case, we're using npm run dev to start our application in development mode:

`CMD ["npm", "run", "dev"]`

This will start our application using the dev script specified in the package.json file.

#### Docker compose

In the previous section, we created a Dockerfile for our app and optimized the Docker image using multi-stage builds. Now, we will take a step further by defining the Docker services for our application using Docker Compose.

Docker Compose is a tool that allows us to define and run multi-container Docker applications. In this section, we will define the services required for our Node.js authentication API and how to run them using Docker Compose.

#### Docker ignore

Create `.dockerignore` as this:

```
node_modules
npm-debug.log
.DS_Store
.env
.git
.gitignore
README.md
```

### Project start up

Run `docker-compose up` in your terminal

### Project testing

Using `Postman` try this:

`POST` to `http://localhost:8080/api/register`

```json
{
  "name": "Test",
  "email": "test@email.com",
  "password": "password"
}
```

Expect response:

```json
{
   "success": true,
   "message": "User registered successfully",
   "data": {
       "name": "Test",
       "email": "test@email.com",
      ...
   }
}
```

`POST` to `http://localhost:8080/api/login`

```json
{
  "email": "test@email.com",
  "password": "password"
}
```

Expect response:

```json
{
  "success": true,
  "token": "a-token..."
}
```
