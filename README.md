# Zoe Application repository

This repository contains application descriptions and related Docker images for [Zoe, the Analytics as a Service software](http://zoe-analytics.eu).

Zoe applications are composed of frameworks, who, in turn, are composed of services.
The service descriptions are closely related to the Docker images used to run them (command line arguments, environment variables, etc.).

The repository is organized as follows:

* `/applications` : contains scripts that generate Zoe application descriptions in JSON format. These scripts can be customized to set a number of parameters related to the services it is composed of.
* `/frameworks` : contains one directory per framework. Inside there are the Python modules needed by the scripts in the `applications` directory and an (optional) `images` directory
* `/frameworks/<framework name>/images` : contains one directory per Docker image, with Dockerfiles and related files
* `/frameworks/<framework name>/images/build_all.sh` : A script that builds all the images for that framework

Use the issue tracker of the [main Zoe repository](https://github.com/DistributedSystemsGroup/zoe) to report problems with the application descriptions and the images maintained in this repository.

