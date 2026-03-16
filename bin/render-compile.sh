#!/usr/bin/env bash
# exit on error
set -o errexit

echo "-----> Install dependencies"
python -m pip install pipenv
pipenv install --system

echo "-----> I'm post-compile hook"
cd ./tabbycat/

echo "-----> Running database migration"
python manage.py migrate --noinput

echo "-----> Running dynamic preferences checks"
python manage.py checkpreferences

echo "-----> Running static asset compilation"
export NODE_OPTIONS=--max-old-space-size=192   # < NEW LINE
npm install -g @vue/cli-service-global
npm install
npm run build

echo "-----> Running static files compilation"
python manage.py collectstatic --noinput

echo "-----> Post-compile done"
