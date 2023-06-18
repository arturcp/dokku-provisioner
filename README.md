# Dokku provisioner

[Dokku](https://dokku.com/) is a fantastic tool! According to their website, Dokku is an open-source PAAS alternative to Heroku that helps you build and manage the lifecycle of applications from building to scaling.

In 2022, Heroku has [recently decided to discontinue the free plans](https://help.heroku.com/RSBRUH58/removal-of-heroku-free-product-plans-faq), which increased the number of people looking for free alternatives. That's where Dokku comes in, it provides everything Heroku offered, if you have a host to install it and if you are willing to learn how it works.

The objective of this project is to shorten the learning curve for those who want to use Dokku. It is a ruby script that will ask questions about the app that will be installed and will list the commands you need to run to have you app up and running in no time.

# How to use it

In the terminal, at the root folder of this app, run:

```
ruby setup.rb
```

Then, follow the instructions on your dokku server.

# Tests

To run the tests, use Rspec's command:

```
rspec spec/features/mytest_spec.rb
```
