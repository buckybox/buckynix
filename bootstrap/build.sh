#!/bin/bash -eux

pushd $(dirname $0)

if [ -d bootstrap ]; then
    cd bootstrap
    git reset --hard
    git clean -fd
    git pull
else
    git clone https://github.com/twbs/bootstrap.git
    cd bootstrap
fi

cp -v ../_custom.scss scss/

npm install
bundle install

grunt
tree dist/

popd

cp -v bootstrap/bootstrap/dist/css/bootstrap.min.css* web/static/assets/css/
cp -v bootstrap/bootstrap/dist/js/bootstrap.min.js web/static/assets/js/

./node_modules/brunch/bin/brunch build
