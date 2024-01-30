FROM elixir:latest

# Set working directory
WORKDIR /app

# Copy the source folder into the Docker image
COPY . .

# Install dependencies
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get

# Compile the project
RUN mix do compile

CMD ["mix", "phx.server"]

