// Generated by CoffeeScript 1.10.0
(function() {
  'use strict';
  var BrowserWindow, app, mainWindow;

  app = require('app');

  BrowserWindow = require('browser-window');

  mainWindow = null;

  app.on('window-all-closed', function() {
    if (process.platform !== 'darwin') {
      return app.quit();
    }
  });

  app.on('ready', function() {
    mainWindow = new BrowserWindow({
      width: 800,
      height: 600
    });
    mainWindow.loadURL('file://' + __dirname + '/../html/index.html');
    mainWindow.webContents.openDevTools();
    return mainWindow.on('closed', function() {
      return mainWindow = null;
    });
  });

}).call(this);
