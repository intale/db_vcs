# DbVcs

Makes it possible to version your local databases during development.

## What is it for?

During the development, you need to handle several branches for several tickets at a time. This make the necessity to have correct database for each branch. For example, `branch1` add `table1.some_column` and `branch2` removes `table1.some_another_column`. When switching between `branch1` and `branch2` - you need to re-create databases, seed then, etc, to make your application work properly. This process may be annoying, especially for large projects with a ton of seeds.

## How it works?

Integrating `db_vcs` helps you to have separated databases for each branch. It provides a tool to create a database for new branch with single command, based on a database you already have in main branch. No need to create/migrate/seed new database when switching between branches.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "db_vcs", require: "db_vcs/autoconfigure"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install db_vcs

`db_vcs` has its own command line tool - `db-vcs`. After installing a gem - you can run `db-vcs --help` in your terminal to see available options.

## Configuration

`db_vcs` autoloads configuration from `.db_vcs.yml` file, placed under your project's root folder. The configuration loader supports ERB templating as well. Example:

```yaml
environments: # The list of environments you want to use db_vcs gem for
  - test
  - development
db_basename: your_project_name # This name will be used as a prefix of all databases names, related to your project
dbs_in_use: # The list of databases you want to use db_vcs gem for
  - mongo
  - postgres
main_branch: main # The name of your main branch. When creating new database for new branch, this branch's database will be used as a source database
pg_config: # Configuration of PostgreSQL
  host: localhost
  port: '5432'
  username: <%= ENV['PGUSER'] %>
  password: postgres
mongo_config: # Configuration of Mongodb
  mongodump_path: "/path/to/mongodump" # resolved automatically using which util. Override it otherwise
  mongorestore_path: "/path/to/mongorestore" # resolved automatically using which util. Override it otherwise
  mongo_uri: mongodb://localhost:27017
mysql_config: # Configuration of MySQL
  host: 127.0.0.1
  port: '3306'
  username: root
  password: root
  mysqldump_path: "/path/to/mysqldump" # resolved automatically using which util. Override it otherwise
  mysql_path: "/path/to/mysql" # resolved automatically using which util. Override it otherwise
```

Notices:

- to be able to use MongoDB - you need to have "mongo" gem installed
- to be able to use MongoDB - you need to have [MongoDB Database Tools](https://docs.mongodb.com/database-tools/) installed. You can have it as docker container - just make sure to adjust "mongodump_path" and "mongorestore_path" options in configuration file
- to be able to use PostgreSQL - you need to have "pg" gem installed 
- to be able to use MySQL - you need to have "mysql2" gem installed 
- to be able to use MySQL - you need to have `mysql` and `mysqldump` utils installed. You can have it as docker container - just make sure to adjust "mysqldump_path" and "mysql_path" options in configuration file

## Usage

**WARNING!** This gem should be used **only** locally - its architecture isn't supposed the usage of it in production environment. 

- Create configuration file `.db_vcs.yml` in your project's root folder.
- Edit your `database.yml`/`mongoid.yml`/any other config file and change database name to `DbVcs::Utils.db_name(env, DbVcs::Utils.current_branch)`. It will allow `db_vcs` gem correctly calculate database name for each branch/environment. 

Example of `database.yml`:

```yaml
development:
  adapter: postgresql
  prepared_statements: false
  encoding: utf8
  username: postgres
  port: 5432
  database: <%= DbVcs::Utils.db_name("development", DbVcs::Utils.current_branch) %>
test:
  adapter: postgresql
  prepared_statements: false
  encoding: utf8
  username: postgres
  port: 5432
  database: <%= DbVcs::Utils.db_name("test", DbVcs::Utils.current_branch) %>
```

Example of `mongoid.yml`:

```yaml
development:
  clients:
    default:
      database: <%= DbVcs::Utils.db_name("development", DbVcs::Utils.current_branch) %>
      hosts:
        - localhost:27017      
test:
  clients:
    default:
      database: <%= DbVcs::Utils.db_name("test", DbVcs::Utils.current_branch) %>
      hosts:
      - localhost:27017      
```

- Create DbVcs-friendly databases. You can skip this step if you want to create databases in your own. Switch into you main branch, and run:

```shell
bundle exec db-vcs init
```

- Now, run commands to load your db structure and populate it with test data. In rails you would usually want to run `rails db:schema:load && rails db:seed`.

Done! The databases for your main branch are setup. Now, when switching into new branch, you can create the database for it just with a single command:

```
bundle exec db-vcs create
```

## git-checkout integration

You may want to add git hook that, when switching between branches: 

- will inform you about databases existence
- restart processes, such as puma server, to apply new database settings

To do so, create `.git/hooks/post-checkout` file(if you don't have it yet) and make it executable:

```shell
touch .git/hooks/post-checkout
chmod +x .git/hooks/post-checkout
```

Example of file's content:

```shell
#!/bin/bash

# Comparison with third argument is needed to detect whether the checkout is related to the switching between branches. In this case third argument equals to 1.
if [ $3 -eq 1 ]
  then
    bundle exec db-vcs check # or "bundle exec db-vcs create" if you want to create databases automatically on checkout
    bundle exec pumactl -C config/puma.rb restart
fi
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Interactive console and tests require all, supported by DbVcs gem, databases to be installed and run. You can do it by running docker with `bin/start-docker` command.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/intale/db_vcs. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/intale/db_vcs/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the DbVcs project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/intale/db_vcs/blob/master/CODE_OF_CONDUCT.md).
