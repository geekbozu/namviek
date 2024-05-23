from node:lts as base

user root
# Update image
RUN apt-get update && apt-get -y upgrade

copy . /app
workdir /app

#update npm
run npm install -g npm@latest

# Add NX
run yarn global add nx@latest

#############################
# Install NPM packages so we can ditch caches
from base as builder

# Install everything, I have no idea if we want --production
RUN --mount=type=cache,target=/root/.yarn YARN_CACHE_FOLDER=/root/.yarn \
    yarn install --immutable

#############################
# Runner without caches
from base as runner

# add non root user
run addgroup namviek && \
    adduser --disabled-login -ingroup namviek namviek

workdir /app
COPY --from=builder /app/node_modules ./node_modules
run chown -R namviek:namviek /app 

user namviek

#grab previously installed modules without caches. 

# TODO eventually use tini so it captures signals properly. 
entrypoint ["yarn","frontend"]
