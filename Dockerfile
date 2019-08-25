FROM ruby:2.5.5-alpine as builder

LABEL "version"="1.0" \
      "service"="sinatra" \
      "description"="A minimal Sinatra application" \
      "maintainer"="javier.juarez@gmail.com"

WORKDIR /opt/app
COPY . /opt/app
RUN apk add --no-cache --virtual build-dependencies ruby-dev build-base && \
    bundle install --without development test -j2


FROM ruby:2.5.5-alpine as production
COPY --from=builder /usr/local/ /usr/local/
COPY --from=builder /opt/app /opt/app/
RUN chown -R nobody:nogroup /opt/app
USER nobody

WORKDIR /opt/app
EXPOSE 8080
CMD ["bundle", "exec", "rackup", "-s", "puma", "--host", "0.0.0.0", "--port", "8080"]
