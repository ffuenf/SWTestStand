<a href="http://www.ffuenf.de" title="ffuenf - code • design • e-commerce"><img src="https://github.com/ffuenf/Ffuenf_Common/blob/master/skin/adminhtml/default/default/ffuenf/ffuenf.png" alt="ffuenf - code • design • e-commerce" /></a>

SWTestStand
===========
[![GitHub tag](https://img.shields.io/github/tag/ffuenf/SWTestStand.svg)][tag]
[![Build Status](https://img.shields.io/travis/ffuenf/SWTestStand.svg)][travis]
[![PayPal Donate](https://img.shields.io/badge/paypal-donate-blue.svg)][paypal_donate]
[tag]: https://github.com/ffuenf/SWTestStand
[travis]: https://travis-ci.org/ffuenf/SWTestStand
[paypal_donate]: https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=J2PQS2WLT2Y8W&item_name=Shopware%20Extension%3a%20SWTestStand&item_number=SWTestStand&currency_code=EUR

This tool is used to build a minimal Shopware environment that allows to run PHPUnit tests for a Shopware extension on Travis CI.

Travis CI configuration
-----------------------

Example .travis.yml file (in the Shopware extension you want to test):

```yml
language: php
sudo: false
cache:
  apt: true
  directories:
  - "$HOME/.composer/cache"
  - "$HOME/.cache/bin"
php:
- 7.0
- 7.1
- 7.2
- 7.3
matrix:
  fast_finish: true
env:
  matrix:
  - SHOPWARE_VERSION="5.5"
  global:
  - PLUGIN_NAME=EXTENSIONNAME
  - SHOPWARE_DIRECTORY="${HOME}/shopware"
  - PLUGIN_DIRECTORY="${SHOPWARE_DIRECTORY}/custom/plugins"
before_install:
- curl -sSL https://raw.githubusercontent.com/ffuenf/SWTestStand/master/before_install.sh
  | bash
script:
- curl -sSL https://raw.githubusercontent.com/ffuenf/SWTestStand/master/script.sh
  | bash
after_success:
- curl -sSL https://raw.githubusercontent.com/ffuenf/SWTestStand/master/build.sh ${PLUGIN_NAME} ${TRAVIS_TAG}
  | bash
deploy:
  provider: releases
  file:
  - "${PLUGIN_NAME}-${TRAVIS_TAG}.zip"
  - "${PLUGIN_NAME}-${TRAVIS_TAG}.tar.gz"
  skip_cleanup: true
  file_glob: true
  on:
    branch: master
    tags: true
```

Development
-----------
1. Fork the repository from GitHub.
2. Clone your fork to your local machine:

        $ git clone https://github.com/USER/SWTestStand

3. Create a git branch

        $ git checkout -b my_bug_fix

4. Make your changes/patches/fixes, committing appropriately
5. Push your changes to GitHub
6. Open a Pull Request

License and Author
------------------

- Author:: Achim Rosenhagen (<a.rosenhagen@ffuenf.de>)
- Copyright:: 2019, ffuenf

The MIT License (MIT)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.