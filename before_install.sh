#!/usr/bin/env bash
set -e
set -x

export PATH="$HOME/.cache/bin:$PATH"

mv ~/.phpenv/versions/$(phpenv version-name)/etc/conf.d/xdebug.ini ~/.phpenv/versions/$(phpenv version-name)/etc/conf.d/xdebug.ini.disabled
echo 'memory_limit = -1' >> ~/.phpenv/versions/$(phpenv version-name)/etc/conf.d/travis.ini
phpenv rehash;
composer self-update
if [[ -n "$GITHUB_TOKEN" ]]; then
    composer config github-oauth.github.com "$GITHUB_TOKEN"
fi
composer install --no-interaction --prefer-dist

# install or update composer in casher dir
if [ "$CASHER_DIR" ]; then
    mkdir -p $HOME/.cache/bin
    # phpunit
    if [ ! -f $HOME/.cache/bin/phpunit ]; then
        if [[ "$TRAVIS_PHP_VERSION" = "7.0" ]]; then
            curl --connect-timeout 30 -sS https://phar.phpunit.de/phpunit-6.5.14.phar \
                 -o $HOME/.cache/bin/phpunit
        fi
        if [[ "$TRAVIS_PHP_VERSION" = "7.1" ]]; then
            curl --connect-timeout 30 -sS https://phar.phpunit.de/phpunit-7.5.6.phar \
                 -o $HOME/.cache/bin/phpunit
        fi
        if [[ "$TRAVIS_PHP_VERSION" = "7.2" &&
              "$TRAVIS_PHP_VERSION" = "7.3"  &&
              "$TRAVIS_PHP_VERSION" = "7.4" ]]; then
            curl --connect-timeout 30 -sS https://phar.phpunit.de/phpunit-8.0.4.phar \
                 -o $HOME/.cache/bin/phpunit
        fi
        chmod +x $HOME/.cache/bin/phpunit
    fi
    # phpcs
    if [ ! -f $HOME/.cache/bin/phpcs ]; then
        curl --connect-timeout 30 -sS https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar \
             -o $HOME/.cache/bin/phpcs
        chmod +x $HOME/.cache/bin/phpcs
    fi
    # phploc
    if [ ! -f $HOME/.cache/bin/phploc ]; then
        curl --connect-timeout 30 -sS https://phar.phpunit.de/phploc.phar \
             -o $HOME/.cache/bin/phploc
        chmod +x $HOME/.cache/bin/phploc
    fi
    # ocular
    if [ ! -f $HOME/.cache/bin/ocular ]; then
        curl --connect-timeout 30 -sL https://scrutinizer-ci.com/ocular.phar \
             -o $HOME/.cache/bin/ocular
        chmod +x $HOME/.cache/bin/ocular
    fi
    # assert.sh
    if [ ! -f $HOME/.cache/bin/assert.sh ]; then
        curl --connect-timeout 30 -sS https://raw.githubusercontent.com/lehmannro/assert.sh/master/assert.sh \
             -o $HOME/.cache/bin/assert.sh
        chmod +x $HOME/.cache/bin/assert.sh
    fi
    # phpstan
    if [ ! -f $HOME/.cache/bin/phpstan ]; then
        curl --connect-timeout 30 -sL https://github.com/phpstan/phpstan/releases/download/0.11.2/phpstan.phar \
             -o $HOME/.cache/bin/phpstan
        chmod +x $HOME/.cache/bin/phpstan
    fi
fi
