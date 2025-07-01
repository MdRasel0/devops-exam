# Use Node.js base image
FROM node:18-slim

# Set working directory
WORKDIR /app

# Copy dependency files and install
COPY todo-app/package.json todo-app/yarn.lock ./
RUN yarn install

# Copy rest of the code
COPY todo-app/ .

# Expose the port your app uses (commonly 3000 or what src/index.js uses)
EXPOSE 3000

# Run the app using dev script (can also be changed to node src/index.js for production)
CMD ["yarn", "dev"]
