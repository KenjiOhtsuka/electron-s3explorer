mkdir electron-src/css
mkdir electron-src/html
mkdir electron-src/js

./node_modules/.bin/jade src/jade --out electron-src/html
#./node_modules/.bin/tsc --outDir electron-src/js -p src/ts
./node_modules/.bin/coffee -c -o electron-src/js src/coffee
./node_modules/.bin/node-sass -o electron-src/css src/sass
