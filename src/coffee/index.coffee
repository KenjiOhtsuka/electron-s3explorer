centerTag = document.getElementsByClassName('center')[0]
mainPane = document.getElementById 'main_pane'
contents = document.getElementById 'contents'
dirTreeTag = document.getElementsByClassName('dir_tree')[0]
delimiter = '/'

mainPane.style.width = (centerTag.clientWidth - dirTreeTag.offsetWidth).toString() + 'px'

document.addEventListener \
  'keydown',
  (e) ->
    switch e.keyCode
      when 8  # Backspace
        explorer.up()
###
      when 13 # Enter
      when 27 # Space
      when 35 # End
      when 36 # Home
      when 46 # Delete
###


class FileUtil
  @pickBaseName: (key) ->
    delimiterIndex = key.lastIndexOf(delimiter)
    if delimiterIndex < 0 then return key
    return key.substr(delimiterIndex + 1)
  @pickExtension: (key) ->
    periodIndex = key.lastIndexOf(".")
    if periodIndex < 0 then return null
    return key.substr(periodIndex + 1)

class FsObjectDomFactory
  #@createFileDom: () ->

  @createDirectoryDom: (key) ->
    name = FileUtil.pickBaseName key.substr(0, key.length - 1)

    li = document.createElement 'li'
    li.classList.add 'fs_node'
    li.setAttribute 'ondblclick', "explorer.showContents('#{key}')"
    iconSpan = document.createElement 'span'
    iconSpan.classList.add 'icon'
    iconSpan.classList.add 'fa'
    iconSpan.classList.add 'fa-folder'
    nameSpan = document.createElement 'span'
    nameSpan.classList.add 'name'
    nameSpan.appendChild(document.createTextNode(name))
    li.appendChild iconSpan
    li.appendChild document.createTextNode(' ')
    li.appendChild nameSpan
    return li

  @createFileDom: (key) ->
    name = FileUtil.pickBaseName key
    extension = FileUtil.pickExtension key

    li = document.createElement 'li'
    li.classList.add 'fs_node'
    iconSpan = document.createElement 'span'
    iconSpan.classList.add 'icon'
    iconSpan.classList.add 'fa'
    switch extension
      when 'zip', 'gz', 'bz'
        iconSpan.classList.add 'fa-file-archive-o'
      when 'jpg', 'jpeg', 'bmp', 'gif', 'png'
        iconSpan.classList.add 'fa-file-image-o'
      when 'pdf'
        iconSpan.classList.add 'fa-file-pdf-o'
      when 'wav', 'mp3'
        iconSpan.classList.add 'fa-file-audio-o'
      when 'avi', 'mp4', 'mepg'
        iconSpan.classList.add 'fa-file-video-o'
      when 'c', 'cpp', 'vb', 'vbs', 'js', 'ts', 'cs', 'java', 'kt'
        iconSpan.classList.add 'fa-file-code-o'
      when 'ppt'
        iconSpan.classList.add 'fa-file-powerpoint-o'
      when 'doc', 'docx'
        iconSpan.classList.add 'fa-file-word-o'
      when 'xls', 'xlsx'
        iconSpan.classList.add 'fa-file-excel-o'
      else
        iconSpan.classList.add 'fa-file-o'
    nameSpan = document.createElement 'span'
    nameSpan.classList.add 'name'
    nameSpan.appendChild(document.createTextNode(name))
    li.appendChild(iconSpan)
    li.appendChild document.createTextNode(' ')
    li.appendChild nameSpan
    return li

###
class ExplorerWindow
  _instance = null
  class _ExplorerWindow
    explorer = null
    constructor: () ->
      explorer = new Explorer()
    showContents: (prefix = "") ->
      explorer.showContents(prefix)
  @get: () ->
    return _instance ?: new _ExplorerWindow()
###

class Explorer
  _instance = null
  constructor: () ->
    throw new Error "This is singleton class!"
  class _Explorer
    _currentDirectory = ""
    setCurrentDirectory: (value) ->
      @._currentDirectory = value
      return @
    getCurrentDirectory: () ->
      return @._currentDirectory
    showContents: (prefix = "") ->
      request = new AWS.S3().listObjects
        Bucket: window.bucketName
        Delimiter: delimiter
        Prefix: prefix
      request.on 'success', (response) =>
        @.clearContents()
        json = response.data
        console.log json
        for d in json['CommonPrefixes']
          contents.appendChild(FsObjectDomFactory.createDirectoryDom(d['Prefix']))
        for f in json['Contents']
          console.log f['Key']
          contents.appendChild(FsObjectDomFactory.createFileDom(f['Key']))
      @.setCurrentDirectory(prefix)
      document.getElementById('current_directory').innerText = @.getCurrentDirectory()
      request.send()
    clearContents: () ->
      while (contents.lastChild)
        contents.removeChild contents.lastChild
    up: () ->
      if @.getCurrentDirectory().length == 0
        return
      delimiterIndex =
        @.getCurrentDirectory().substr(0, @.getCurrentDirectory().length - 1).
          lastIndexOf(delimiter)
      dirString = @.getCurrentDirectory().substr(0, delimiterIndex + 1)
      @.showContents(dirString)

  @get: () ->
    return _instance ?= new _Explorer()

request = new AWS.S3().listObjects
  Bucket: window.bucketName,
  Delimiter: '/'
  #Marker: '/'
#  (err, data) ->
#    if err
#      console.log err, err.stack
#    return
#    console.log data

explorer = Explorer.get()
explorer.showContents()


  
