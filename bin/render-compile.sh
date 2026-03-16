#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset

echo "-----> Install pipenv"
python -m pip install --upgrade pip
python -m pip install pipenv

echo "-----> Install project dependencies from Pipfile"
pipenv install --system --deploy --ignore-pipfile || {
  echo "Pipenv install failed - trying fallback pip install from requirements.txt if exists"
  if [ -f requirements.txt ]; then
    pip install -r requirements.txt
  else
    echo "No requirements.txt found - aborting"
    exit 1
  fi
}

echo "-----> I'm post-compile hook"
cd ./tabbycat/ || { echo "cd tabbycat failed"; exit 1; }

echo "-----> Running database migration"
python manage.py migrate --noinput

echo "-----> Running dynamic preferences checks"
python manage.py checkpreferences

echo "-----> Running static files compilation"
python manage.py collectstatic --noinput --clear

echo "-----> Post-compile done"
