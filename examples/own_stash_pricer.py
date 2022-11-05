import csv
import os
import pandas
import numpy as np

import poe_stash_api.stash as stash
import poe_stash_api.price as price

league = 'Ritual'
realm = 'pc'
poeaccount = os.getenv('POEACCOUNT')
poesessid = os.getenv('POESESSID')

tabs = stash.fetch_all_tabs(league, realm, poeaccount, poesessid)
tabs_df = stash.items_to_df(tabs)
tabs_df.sort_values(by=['count'], ascending=False).to_csv('./raw-data.csv', index=False, quoting=csv.QUOTE_NONNUMERIC)

currencies = price.fetch_currencies(league)
currencies_df = price.currencies_to_df(currencies)

items = price.fetch_items(league)
items_df = price.items_to_df(items)

price_df = pandas.concat([currencies_df, items_df], ignore_index=True, copy=True)

joined_df = pandas.merge(tabs_df, price_df, how='inner')
joined_df['chaos_total'] = joined_df['chaos_unity'] * joined_df['count']
joined_df['count_log'] = np.log(joined_df['count'])
joined_df.sort_values(by=['chaos_total'], ascending=False).to_csv('./joined-data.csv', index=False, quoting=csv.QUOTE_NONNUMERIC)
