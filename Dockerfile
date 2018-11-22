FROM elixir:1.7.4-slim
MAINTAINER hoominkani

ENV TZ Asia/Tokyo

RUN set -x && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
  nodejs \
  npm \
  mysql-client \
  inotify-tools \
  git \
  make \
  vim \
  imagemagick \
  tar \
  ssh \
  gzip \
  g++ \
  ca-certificates \
  python2.7-dev \
  python-setuptools \
  sqlite3 \
  locales \
  sudo \
  software-properties-common \
  wget \
  curl && \
  rm -rf /var/lib/apt/lists/* && \
  npm cache clean && \
  npm install n -g && \
  n stable && \
  ln -sf /usr/local/bin/node /usr/bin/node && \
  apt-get purge -y nodejs npm && \
  easy_install pip && \
  pip install awscli

#install n
RUN npm cache verify && npm install -g n

#install node
RUN n 7.6.0

#set timezone
RUN echo "${TZ}" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

# Add erlang-history
RUN git clone -q https://github.com/ferd/erlang-history.git && \
    cd erlang-history && \
    make install && \
    cd - && \
    rm -fR erlang-history

# Install Hex+Rebar
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix hex.info

# Set Locale
RUN locale-gen ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
ENV LC_CTYPE ja_JP.UTF-8
RUN localedef -f UTF-8 -i ja_JP ja_JP.utf8

RUN sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN sudo echo "deb http://download.mono-project.com/repo/debian jessie main" | tee /etc/apt/sources.list.d/mono-official.list
RUN sudo apt-get update
RUN sudo apt-get install -y mono-devel

EXPOSE 4000

CMD ["sh", "-c", "mix deps.get && elixir --sname service-node --cookie service -S mix phoenix.server"]
