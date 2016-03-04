# Contributing

If you have a bugfix or new feature that you would like to contribute to this puppet module, please find or open an issue about it first.
Talk about what you would like to do.
It may be that somebody is already working on it, or that there are particular issues that you should know about before implementing the change.

**Note**: If you have support-oriented questions that aren't a bugfix or feature request, please post your questions on the [discussion forums](https://discuss.elastic.co/c/elasticsearch).

We enjoy working with contributors to get their code accepted.
There are many approaches to fixing a problem and it is important to find the best approach before writing too much code.

The process for contributing to any of the Elastic repositories is similar.

## The Contributor License Agreement

Please make sure you have signed the [Contributor License Agreement](http://www.elastic.co/contributor-agreement/). We are not asking you to assign copyright to us, but to give us the right to distribute your code without restriction. We ask this of all contributors in order to assure our users of the origin and continuing existence of the code. You only need to sign the CLA once.

## Development Setup

There are a few testing prerequisites to meet:

* Ruby.
  As long as you have a recent version with `bundler` available, `bundler` will install development dependencies.
* Docker.
  If you are developing on a Linux machine with a working Docker instance, this should be sufficient.
  If you are developing on OS X, we've provided a lightweight VM to serve as a testing hypervisor that you can boot up with the following commands at the root of the repo:

    $ vagrant up
    $ export DOCKER_HOST=tcp://192.168.6.5:2375

  Confirm that you can communicate with the Docker hypervisor with `docker version`.

You can then install the necessary gems with:

    make

## Testing

Running through the tests on your own machine can get ahead of any problems others (or Jenkins) may run into.

First, run the rspec tests and ensure it completes without errors with your changes. These are lightweight tests.

    make test-rspec

Next, run the more thorough acceptance tests.
By default, the test will run against a Debian 8 Docker image - other available hosts can be found in `spec/acceptance/nodesets`.
For example, to run the acceptance tests against CentOS 6, run the following:

    DISTRO=centos-6-x64 make test-acceptance

The final output line will tell you which, if any, tests failed.

## Opening Pull Requests

In summary, to open a new PR:

* Sign the Contributor License Agreement
* Run the tests to confirm everything works as expected
* Rebase your changes.
  Update your local repository with the most recent code from this puppet module repository, and rebase your branch on top of the latest master branch.
* Submit a pull request
  Push your local changes to your forked copy of the repository and submit a pull request. In the pull request, describe what your changes do and mention the number of the issue where discussion has taken place, eg "Closes #123".

Then sit back and wait! There will probably be discussion about the pull request and, if any changes are needed, we would love to work with you to get your pull request merged into this puppet module.
