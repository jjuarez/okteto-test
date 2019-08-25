FROM ruby:2.5.5-alpine AS builder

RUN apk update &&\
    apk add --update --no-cache --virtual build-dependencies ruby-dev build-base &&\
    gem update bundler

WORKDIR /opt/app
COPY Gemfile* /opt/app/

RUN bundle install --without development:test -j 4 --retry 2 --path vendor/bundle &&\
    rm -rf vendor/bundle/ruby/2.5.0/cache/*.gem &&\
    find vendor/bundle/ruby/2.5.0/gems/ -name "*.c" -delete &&\
    find vendor/bundle/ruby/2.5.0/gems/ -name "*.o" -delete


FROM ruby:2.5.5-alpine AS production
LABEL \
      org.label-schema.name="Sinatra application" \
      org.label-schema.description="A basic application to test the okteto platform" \
      org.label-schama.url="https://github.com/jjuarez/okteto-test" \
      org.label-schema.docker.Dockerfile="Dockerfile" \
      org.label-schema.maintainer="javier.juarez@gmail.com"

COPY --from=builder /usr/local/ /usr/local/
COPY --from=builder /opt/app/ /opt/app
COPY . /opt/app/

RUN addgroup -g 1001 -S services
RUN adduser --system --uid 1001 --shell /bin/false -G services app
RUN chown -R app:services /opt/app
#USER app

WORKDIR /opt/app
EXPOSE 8080/tcp

CMD ["bundle", "exec", "rackup", "-s", "puma", "--host", "0.0.0.0", "--port", "8080"]
