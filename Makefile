default:
	if [ ! -d electron-src/css ]; then mkdir electron-src/css; fi
	if [ ! -d electron-src/html ]; then mkdir electron-src/html; fi
	if [ ! -d electron-src/js ]; then mkdir electron-src/js; fi
	./node_modules/.bin/node-sass -o electron-src/css src/sass
	./node_modules/.bin/jade src/jade --out electron-src/html
	./node_modules/.bin/coffee -c -o electron-src/js src/coffee


clean:
	rm -rf electron-src/html
	rm -rf electron-src/js
	rm -rf electron-src/css
