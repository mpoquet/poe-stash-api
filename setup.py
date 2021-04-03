#!/usr/bin/env python
from distutils.core import setup

setup(name='poe-stash-api',
    version='0.1.0',
    packages=['poe_stash_api'],

    python_requires='>=3.8.5',
    install_requires=[
        'pandas>=1.1.1',
        'requests>=2.24.0',
    ],

    description="Simple Python code to retrieve Path of Exile stash information from GGG's API.",
    author='Millian Poquet',
    author_email='millian.poquet@gmail.com',
    url='https://github.com/mpoquet/poe-stash-api/',
    license='MIT',
    classifiers=[
        'Programming Language :: Python :: 3',
        'License :: OSI Approved :: MIT License',
    ],
)
