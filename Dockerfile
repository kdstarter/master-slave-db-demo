FROM ruby:2.7.0

MAINTAINER Teddy Jiang <teddy.jiang@qq.com>

ENV WORKDIR /master-slave-demo
WORKDIR $WORKDIR

# Set ENV for database.yml and Redis
ENV REDIS_HOST redis_server
ENV REDIS_PORT 6379
ENV DATABASE_HOST mysql_master
ENV DATABASE_PORT 3306
ENV DB_READONLY_HOST mysql_slave
ENV DB_READONLY_PORT 3306

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get update && apt install -y nodejs

ARG CURRENT_ENV=development
ENV RAILS_ENV $CURRENT_ENV
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
RUN bundle install

# COPY . .
RUN npm install -g yarn
RUN yarn install --check-files
# RUN rake db:migrate

EXPOSE 3000
ENTRYPOINT ["bundle", "exec"]
CMD ["puma", "-C", "config/puma.rb"]
