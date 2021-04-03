"""Stash fetching from GGG's API"""
import json
import logging
import pandas
import requests
import time
from collections import defaultdict

class FetchTabException(RuntimeError):
    pass

class ForbiddenFTException(FetchTabException):
    pass

class ResourceNotFoundFTException(FetchTabException):
    pass

class RateLimitExceededFTException(FetchTabException):
    pass

class HTTPErrorFTException(FetchTabException):
    pass


def fetch_tab(league, realm, account_name, poe_sessid, tab_index):
    """Fetch a single tab from GGG's API"""
    url = 'https://www.pathofexile.com/character-window/get-stash-items'
    data = {
        'accountName': account_name,
        'league': league,
        'realm': realm,
        'tabIndex': tab_index,
        'tabs': 0,
    }
    cookies = {
        'POESESSID': poe_sessid,
    }
    headers = {
        'user-agent': 'poe-stash-api/0.1.0 simple python functions to retrieve PoE stash info'
    }

    r = requests.post(url, data=data, cookies=cookies, headers=headers)
    if not r.ok:
        raise HTTPErrorFTException(f'Got HTTP status {r.status_code}: {r.reason}')

    response = r.text
    parsed = json.loads(response)
    if 'error' in parsed:
        if parsed['error']['code'] == 6:
            raise ForbiddenFTException(f'Cannot access stash. Are your account_name/poe_sessid correct? Raw response: {response}')
        elif parsed['error']['code'] == 3:
            raise RateLimitExceededFTException(f'Raw response: {response}')
        elif parsed['error']['code'] == 1:
            raise ResourceNotFoundFTException(f'Raw response: {response}')
        else:
            raise FetchTabException(f'Unknown error received. Raw response: {response}')

    return parsed

def fetch_all_tabs(league, realm, account_name, poe_sessid):
    """Fetch all your tabs from GGG's API"""
    tabs = list()
    tabs.append(fetch_tab(league, realm, account_name, poe_sessid, 0))

    base_delay = 0.005
    flood_delay = 30
    tab_index = 1

    # Loop while we can find tabs (while 'resource not found' has NOT been received)
    while True:
        try:
            time.sleep(base_delay)
            logging.info(f'Fetching tab {tab_index}...')
            tabs.append(fetch_tab(league, realm, account_name, poe_sessid, tab_index))
        except RateLimitExceededFTException:
            logging.warning(f"Rate limit exceeded received. Sleeping {flood_delay} s to stop flooding GGG's API")
            time.sleep(flood_delay)
            flood_delay *= 2
            base_delay += 1
        except ResourceNotFoundFTException:
            break
        else:
            tab_index = tab_index + 1
            flood_delay = 30
    return tabs

def tabs_to_df(tabs):
    """Convert JSON tabs into usable data frames"""
    stackable = defaultdict(int)

    for tab in tabs:
        for item in tab['items']:
            if 'stackSize' in item:
                stackable[item['typeLine']] += item['stackSize']

    return pandas.DataFrame(stackable.items(), columns=['item', 'count'])

def prophecies_tabs_to_df(tabs):
    """Convert JSON tabs into usable data frames"""
    stackable = defaultdict(int)

    for tab in tabs:
        for item in tab['items']:
            if 'typeLine' in item:
                stackable[item['typeLine']] += 1

    return pandas.DataFrame(stackable.items(), columns=['item', 'count'])
