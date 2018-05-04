FROM node:9


WORKDIR /app/
COPY ./ ./
RUN apt-get update && apt-get install -y \
  ca-certificates \
  libgmp-dev netbase libnss-lwres libnss-mdns libss3 
RUN ["yarn", "add", "global", "elm"]
RUN ["yarn", "build"]
RUN npm install -g serve

CMD serve -s ./build -p 3000

EXPOSE 3000
