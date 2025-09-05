#!/usr/bin/env bash
set -o errexit

bundle install
bin/rails assets:precompile
bin/rails assets:clean

# Em instâncias Free o Render recomenda rodar migrations no build
bin/rails db:migrate