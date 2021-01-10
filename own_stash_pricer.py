import pandas

import stash
import price
import plot

league='Heist'
realm='pc'

tabs = stash.fetch_all_tabs(league, realm, os.getenv('POEACCOUNT'), os.getenv('POESESSID'))
tabs_df = stash.tabs_to_df(tabs)

currencies = price.fetch_currencies(league)
currencies_df = price.currencies_to_df(currencies)

items = price.fetch_items(league)
items_df = price.items_to_df(items)

price_df = pandas.concat([currencies_df, items_df], ignore_index=True, copy=True)

joined_df = pandas.merge(tabs_df, price_df, how='inner')
joined_df['chaos_total'] = joined_df['chaos_unity'] * joined_df['count']
joined_df['count_log'] = np.log(joined_df['count'])

color_scale='Blues'
fig = px.treemap(joined_df,
    path=['family', 'item'],
    hover_data=['item', 'count', 'chaos_unity'],
    values='chaos_total',
    color='count_log',
    color_continuous_scale=color_scale
)

fig.write_html("/tmp/plotly.html")
