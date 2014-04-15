# SSHBro

Replaces a fella's SSH Config (~/.ssh/config) with some stuff from a Google doc.

This gives you handy bookmarks for all them servers and tab-completion if you're using a decent shell.

## Installation

Like this:

    $ gem install ssh_bro

Ruby 1.9.3+ blah blah.

## Usage

Run it:

    $ sshbro

It will prompt you for things. To update your SSH config file:

    $ sshbro > ~/.ssh/config

## TODO:

- Allow config file templates.
- Allow per-host templates.
