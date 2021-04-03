# poe-stash-api
Simple Python code to retrieve Path of Exile stash information from GGG's API.

Note: This code has no special ambition, it started as an example to fetch GGG API and I added a prototype to price items and gather prophecy information.

## Install

`pip install .`

## Usage
Give a look to the `examples` directory.

## Known issues

- Some divination cards and prophecies have the same name (`The Twins`, `Rebirth`...), which creates issues when joining item data with poe.ninja price information.
