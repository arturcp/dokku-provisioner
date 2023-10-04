# Dokku provisioner

[Dokku](https://dokku.com/) is a fantastic tool! According to their website, Dokku is an open-source PAAS alternative to Heroku that helps you build and manage the lifecycle of applications from building to scaling.

In 2022, Heroku has [decided to discontinue the free plans](https://help.heroku.com/RSBRUH58/removal-of-heroku-free-product-plans-faq), which increased the number of people looking for free alternatives. That's where Dokku comes in, it provides everything Heroku offered, if you have a host to install it and if you are willing to learn how it works.

The objective of this project is to shorten the learning curve for those who want to use Dokku. It is a ruby script that will ask questions about the app that will be installed and will list the commands you need to run to have you app up and running in no time.

![](http://g.recordit.co/bMGYI0qwok.gif)

# How to use it

This is a pure ruby project, so you need to have ruby installed on your machine. If you don't have it, you can follow [this guide](https://www.ruby-lang.org/en/documentation/installation/) to install it.

After cloning the project, you need to install the dependencies. To do that, run:

```
bundle install
```

Then, you are ready to run the script. In the terminal, at the root folder of this project, run:

```
ruby setup.rb
```

Then, follow the instructions on your dokku server.

# Tests

To run the tests, use RSpec's command:

```
rspec
```

If you need to run the tests of one single file, you can specify it:

```
rspec spec/models/mytest_spec.rb
```

# Customizing to your needs

If you run the script, you will come across placeholders, like this:

```
dokku postgres:backup-auth api-database <AWS_ACCESS_KEY_ID> <AWS_SECRET_ACCESS_KEY>
git remote add dokku dokku@<IP ADDRESS>:api
```

See those variables inside `<>`? You need to replace them with your values when running the commands on your Dokku server. However, if you plan to install many apps on the same server, it gets boring to keep replacing the placeholders with the same values over and over again. That's why you can create a `.env` file at the root of this project and add the values you want to replace the placeholders with.

The simplest way to start is by duplicating the .env.example file and renaming it to .env. Then, you can replace the values inside it with your values (and fear not, the .env file is going to be ignored by git, so there is no risk of you committing any secret to the repository).

.env example:

```
DOKKU_SERVERS=127.0.0.1,my-host.com
AWS_ACCESS_KEY_ID=AAAAABBBBB1231401010
AWS_SECRET_ACCESS_KEY=ABCDEFGHIJKLMNOPQRSTUVWXYZ
```

DOkKU_SERVERS is a special variable. If it is empty, you will see a placeholder on the instructions output. Otherwise, it can hold any number of IP addresses or hostnames, separated by commas. If you have more than one server, the script will ask you which one you want to use.
