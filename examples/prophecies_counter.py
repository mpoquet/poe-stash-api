#!/usr/bin/env python3
import csv
import os

import poe_stash_api.stash as stash

league='Ritual'
realm='pc'

tabs = stash.fetch_all_tabs(league, realm, os.getenv('POEACCOUNT'), os.getenv('POESESSID'))
prophecies_tabs = tabs[-3:]
tabs_df = stash.prophecies_tabs_to_df(prophecies_tabs)
tabs_df.sort_values(by=['count'], ascending=False).to_csv('./raw-data.csv', index=False, quoting=csv.QUOTE_NONNUMERIC)
