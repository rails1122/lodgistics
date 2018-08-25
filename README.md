# Lodgistics

## Project Information

Inventory/Procurement system for hotels

Staging site: [http://lodgistics-staging.dev.sbox.es/](http://http://lodgistics-staging.dev.sbox.es/)

Users: gm_h1@example.com, hm_h1@example.com; Password: 'password'

### Contacts

* [Nikhil Natu](mailto:nikhil@lodgistics.com)
* [Shaunak Patel](mailto:shaunak.patel@lodgistics.com)

## Development Environment

* Ruby 2.0.0
* Ruby on Rails 4.0.5
* PostgreSQL 9.4


## Set Up Your Dev Environment (Mac OS)

### Install Docker on your machine

1. Docker
- We will set up our dev environment in Docker VM containers. All the required tools and libraries will be automatically installed and configured by Docker
- Download Docker for Mac from https://store.docker.com/editions/community/docker-ce-desktop-mac

2. Docker Toolbox
- helps us to get started with Docker with GUI and CLI tools.
- Download from https://www.docker.com/products/docker-toolbox

### Checkout Code and create required config files

1. Checkout from github
```sh
git clone git@github.com:shaunakpatel/Lodgistics.git
cd Lodgistics
```

2. Create config files
```sh
cp config/database.yml.docker config/database.yml  # database.yml for docker setup
cp config/env_config.yml.example config/env_config.yml
```

### Inital setups

0. Create docker volume for data storage (postgres, redis)
- NOTE : it will take a while. have a coffee break :-)
```sh
docker volume create lodgistics-postgres
docker volume create lodgistics-redis
```

1. Build Docker images
- NOTE : it will take a while. have a coffee break :-)
```sh
docker-compose build
```

2. create Symmetric Encryption Config
```sh
docker-compose run lodgistics rails generate symmetric_encryption:config /etc/rails/keys
```

3. Setup database in docker container
```sh
docker-compose run lodgistics rake db:create       # run rake db:create command in lodgistics docker container
docker-compose run lodgistics rake db:migrate
docker-compose run lodgistics rake db:test:prepare
```

### Boot up Docker containers

1. Build and start Docker containers
```sh
docker-compose up
```
- You will see logs from all running containers (e.g. redis, postgres, rails server)
- To manage and view container status in GUI tool, run Kitematic


### Running Tests

1. Build and start Docker containers
```sh
docker-compose run lodgistics rake test:models        # model test
docker-compose run lodgistics rake test:controllers   # controller test
docker-compose run lodgistics rake test:integration   # integration test
```

### Note on Setting up production server

1. Set aws related env variable in env_config.yml - required for S3 upload

```sh
vim config/env_config.yml

  lodgistics_s3_region: us-east
  lodigstics_s3_bucket_name: lodgistics-production
  lodigstics_aws_access_key: xxx
  lodigstics_aws_secret_access_key: xxx
```

2. Set up push notification

```sh
bundle exec rake push_notification:setup RAKE_ENV=production
```


