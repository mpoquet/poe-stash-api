"""Convert JSON tabs into usable data frames"""
import pandas
from collections import defaultdict

def tabs_to_items(tabs):
    stackable = defaultdict(int)

    for tab in tabs:
        for item in tab['items']:
            if 'stackSize' in item:
                stackable[item['typeLine']] += item['stackSize']

    return pandas.DataFrame(stackable.items(), columns=['item', 'count'])
