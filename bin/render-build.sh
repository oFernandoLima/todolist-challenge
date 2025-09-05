#!/usr/bin/env bash
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

# Em instâncias Free o Render recomenda rodar migrations no build
bundle exec rails db:migrate