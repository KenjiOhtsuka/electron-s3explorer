REM generate js
node_modules\.bin\coffee -c -o electron-src\js src\coffee
node_modules\.bin\jade electron-src\html --out src\jade