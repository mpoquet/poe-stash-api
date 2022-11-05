"""Fetch prices from poe.ninja's API"""
import json
import pandas
import requests

def fetch_currencies(league):
    currencies = dict()
    url = 'https://poe.ninja/api/data/currencyoverview'
    currencies['Currency'] = requests.get(f'{url}?league={league}&type=Currency').json()
    currencies['Fragment'] = requests.get(f'{url}?league={league}&type=Fragment').json()
    return currencies

def currencies_to_df(currencies):
    data = list()
    for currency_type in currencies:
        for currency in currencies[currency_type]['lines']:
            data.append({
                'item': currency['currencyTypeName'],
                'chaos_unity': currency['chaosEquivalent'],
                'family': currency_type,
            })

    return pandas.DataFrame(data)

def fetch_items(league):
    items = dict()
    url = 'https://poe.ninja/api/data/itemoverview'

    items['Oil'] = requests.get(f'{url}?league={league}&type=Oil').json()
    items['Scarab'] = requests.get(f'{url}?league={league}&type=Scarab').json()
    items['Fossil'] = requests.get(f'{url}?league={league}&type=Fossil').json()
    items['Resonator'] = requests.get(f'{url}?league={league}&type=Resonator').json()
    items['Essence'] = requests.get(f'{url}?league={league}&type=Essence').json()
    items['DivinationCard'] = requests.get(f'{url}?league={league}&type=DivinationCard').json()
    return items

def items_to_df(items):
    data = list()
    for item_type in items:
        for item in items[item_type]['lines']:
            data.append({
                'item': item['name'],
                'chaos_unity': item['chaosValue'],
                'family': item_type,
            })

    return pandas.DataFrame(data)
