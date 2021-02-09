#!/usr/bin/env bash

set -e

PROJECT_ROOT_PATH='/usr/local/apps/{{ project_slug }}'

git pull
$PROJECT_ROOT_PATH/env/bin/python manage.py migrate
$PROJECT_ROOT_PATH/env/bin/python manage.py collectstatic --noinput
supervisorctl restart {{ project_name }}

echo "DONE! :)"
