./node_modules/.bin/jade src/jade --out electron-src/html
#./node_modules/.bin/tsc --outDir electron-src/js -p src/ts
./node_modules/.bin/coffee -c -o electron-src/js src/coffee
