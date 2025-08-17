FROM ruby:3.2.5

RUN apt-get update -y && apt-get install -y build-essential libyaml-dev libpq-dev nodejs yarn

WORKDIR /app
ENV RAILS_ENV=production \
    BUNDLE_WITHOUT="development:test" \
    RAILS_LOG_TO_STDOUT=enabled \
    RAILS_SERVE_STATIC_FILES=true \
    PORT=3000

COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 2.5.18 && bundle install --jobs 4 --retry 3

COPY . .

RUN if [ -f "bin/rails" ]; then bundle exec rake assets:precompile || true; fi

EXPOSE 3000
CMD ["bundle","exec","puma","-C","config/puma.rb"]
