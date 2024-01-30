# Import statements
FROM elixir:1.13

RUN apt-get update && \
  apt-get install -y postgresql-client

# Create app directory  
RUN mkdir /app
WORKDIR /app
COPY . .

# Install dependencies
RUN mix local.hex --force && \ 
mix local.rebar --force && \    
mix deps.get

# Compile application
RUN mix do compile 
