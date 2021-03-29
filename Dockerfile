FROM bitwalker/alpine-elixir-phoenix:1.11.3

RUN mkdir /app
WORKDIR /app

COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

COPY assets/package.json assets/package-lock.json ./assets/
RUN npm install --prefix ./assets

COPY . .

CMD ["mix", "phx.server"]