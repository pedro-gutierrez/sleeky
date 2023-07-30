# Mix sleeky.new

Provides `sleeky_new` installer as an archive.

## Installation

To install from Hex, run:

    $ mix archive.install hex sleeky_new

To build and install it locally, ensure any previous archive versions are removed:

    $ mix archive.uninstall sleeky_new

Then run:

    $ cd installer
    $ MIX_ENV=prod mix do archive.build, archive.install

## Usage

Create a new `sleeky` project with:

    $ mix sleeky.new hello_world
