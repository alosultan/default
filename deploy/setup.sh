#!/usr/bin/env bash

set -e

# TODO: Set to URL of git repo.
PROJECT_GIT_URL='https://github.com/CHANGEME.git'

PROJECT_ROOT_PATH='/usr/local/apps/{{ project_slug }}'

echo "Installing dependencies..."
sudo apt-get update
sudo apt-get -y upgrade

# Add software-properties-common that provides some useful scripts for adding and removing PPAs
sudo apt-get install -y software-properties-common

# Add necessary PPAs to the apt index and update it
sudo add-apt-repository ppa:redislabs/redis
sudo apt-get update

# Install necessary apps
sudo apt-get install -y python3-venv python3-pip supervisor nginx git postgresql postgresql-contrib libpq-dev redis

# Create project directory
sudo mkdir -p $PROJECT_ROOT_PATH
sudo git clone $PROJECT_GIT_URL $PROJECT_ROOT_PATH

# Create virtual environment
sudo mkdir -p $PROJECT_ROOT_PATH/env
sudo python3 -m venv $PROJECT_ROOT_PATH/env

# Install python packages
$PROJECT_ROOT_PATH/env/bin/pip install -r $PROJECT_ROOT_PATH/requirements/production.txt

# Run migrations and collectstatic
sudo cd $PROJECT_ROOT_PATH
$PROJECT_ROOT_PATH/env/bin/python manage.py migrate
$PROJECT_ROOT_PATH/env/bin/python manage.py collectstatic --noinput

# Configure supervisor
sudo cp $PROJECT_ROOT_PATH/deploy/supervisor.conf /etc/supervisor/conf.d/{{ project_name }}.conf
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl restart {{ project_name }}

# Configure nginx
sudo cp $PROJECT_ROOT_PATH/deploy/nginx.conf /etc/nginx/sites-available/{{ project_name }}.conf
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/{{ project_name }}.conf /etc/nginx/sites-enabled/
sudo systemctl restart nginx.service

echo "DONE! :)"
