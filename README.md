# s3explorer

* Explorer of AWS S
* supports mac, linux and windows

## configure

* create your configuration json and modify it
  `cp config/default.json.sample config/default.json`

## setup developing environment

1. install nodejs
2. `. ./run.sh setup`

## develop

* For development, please prepare nodejs and npm.

1. clean built files
  `. ./run.sh clean`

1. build jade, coffeescript and sass
  `. ./run.sh build`

1. run electron
  `. ./run.sh`
