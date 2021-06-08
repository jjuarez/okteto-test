ARG IMAGE_TAG=2.7.3-alpine3.13@sha256:19598fc1ef09911a1015c03be08f1b9c881035ea279216153e804d65812b9f31 
FROM ruby:${IMAGE_TAG} AS builder

ARG APP_HOME=/app

RUN apk --no-cache add --virtual build-dependencies build-base ruby-dev

WORKDIR ${APP_HOME}
COPY Gemfile Gemfile.lock ./
RUN bundle install


FROM ruby:${IMAGE_TAG} AS runtime
LABEL \
      org.label-schema.name="Sinatra application" \
      org.label-schema.description="A basic application to test the okteto platform" \
      org.label-schema.url="https://github.com/jjuarez/okteto-test" \
      org.label-schema.maintainer="javier.juarez@gmail.com"

ARG APP_HOME=/app

COPY --from=builder /usr/local/bundle /usr/local/bundle

RUN addgroup -g 1001 -S services && \
    adduser --system --uid 1001 --shell /bin/false -G services app

WORKDIR ${APP_HOME}
RUN chown -R app:services ${APP_HOME}
USER app

COPY . ./
EXPOSE 8080/tcp

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "--port", "8080"]
