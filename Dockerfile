# Find eligible builder and runner images on Docker Hub. We use Ubuntu/Debian instead of
# Alpine to avoid DNS resolution issues in production.
#
# https://hub.docker.com/r/hexpm/elixir/tags?page=1&name=ubuntu
# https://hub.docker.com/_/ubuntu?tab=tags

# renovate: datasource=github-tags depName=elixir packageName=elixir-lang/elixir versioning=semver
ARG ELIXIR_VERSION=1.18.4
# renovate: datasource=github-tags depName=erlang packageName=erlang/otp versioning=regex:^(?<major>\d+)\.(?<minor>\d+)(\.(?<patch>\d+))?$ extractVersion=^OTP-(?<version>.*)$
ARG OTP_VERSION=28.0.2
# renovate: datasource=docker depName=ubuntu versioning=ubuntu
ARG UBUNTU_VERSION=noble-20250714

ARG BUILDER_IMAGE=hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-ubuntu-${UBUNTU_VERSION}
ARG RUNNER_IMAGE=ubuntu:${UBUNTU_VERSION}

FROM ${BUILDER_IMAGE} AS builder

# install build dependencies
RUN apt-get update && apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y nodejs git build-essential
RUN apt-get clean && rm -f /var/lib/apt/lists/*_*

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"

ENV ERL_FLAGS="+JPperf true"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv

COPY lib lib

COPY assets assets

RUN npm install --prefix ./assets

# compile assets
RUN mix assets.deploy

# Compile the release
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel
RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}

RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses6 locales \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/website ./

USER nobody

CMD ["/app/bin/server"]
