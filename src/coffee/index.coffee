centerTag = document.getElementsByClassName('center')[0]
mainPane = document.getElementById 'main_pane'
settingPane = document.getElementById 'setting_pane'
contentsTag = document.getElementById 'contents'
dirTreeTag  = document.getElementsByClassName('dir_tree')[0]
settingPane = document.getElementById 'setting_pane'
delimiter = '/'

mainPane.style.width = (centerTag.clientWidth - dirTreeTag.offsetWidth).toString() + 'px'

document.addEventListener \
  'keydown',
  (e) ->
    switch e.keyCode
      when 8  # Backspace
        explorer.up()
#      when 13 # Enter
#      when 27 # Space
#      when 35 # End
#      when 36 # Home
#      when 46 # Delete
      when 116 # F5
        explorer.showContents(explorer.getCurrentDirectory())


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
    li.setAttribute 'onclick', "explorer.selectFsNode(this)"
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
    li.setAttribute 'onclick', "explorer.selectFsNode(this)"
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

class TreeView
  @dom = null
  @fsTree = null
  constuctor: (dom, fsTree) ->
    @dom = dom
    @fsTree = fsTree
  getFsTree: () ->
    return @fsTree

class Explorer
  _instance = null
  constructor: () ->
    throw new Error "This is singleton class!"
  class _Explorer
    treeView = null
    dirTree = {}
    currentDirectory = ""
    dispSetting = false
    constructor: () ->
      @.treeView = new TreeView(dirTreeTag, new FsTree())
    setCurrentDirectory: (value) ->
      @.currentDirectory = value
      return @
    getCurrentDirectory: () ->
      return @.currentDirectory
    setDispSetting: (value) ->
      @.dispSetting = value
    getDispSetting: () ->
      return @.dispSetting
    showContents: (prefix = "") ->
      request = new AWS.S3().listObjects
        Bucket: window.bucketName
        Delimiter: delimiter
        Prefix: prefix
      request.on 'success', (response) =>
        @.clearContents()
        tree = @.treeView.getFsTree()
        json = response.data
        console.log json['CommonPrefixes']
        for d in json['CommonPrefixes']
          contentsTag.appendChild(FsObjectDomFactory.createDirectoryDom(d['Prefix']))
          tree.add(d['Prefix'].replace(/\/$/, ""))
          console.log(d['Prefix'])
        for f in json['Contents']
          console.log f['Key']
          contentsTag.appendChild(FsObjectDomFactory.createFileDom(f['Key']))
        mainPane.style.width = (centerTag.clientWidth - dirTreeTag.offsetWidth).toString() + 'px'
        mainPane.style.width = (centerTag.clientWidth - dirTreeTag.offsetWidth).toString() + 'px'
      @.setCurrentDirectory(prefix)
      document.getElementById('current_directory').innerText = @.getCurrentDirectory()
      request.send()
    clearContents: () ->
      while (contentsTag.lastChild)
        contentsTag.removeChild contentsTag.lastChild
    up: () ->
      if @.getCurrentDirectory().length == 0
        return
      delimiterIndex =
        @.getCurrentDirectory().substr(0, @.getCurrentDirectory().length - 1).
          lastIndexOf(delimiter)
      dirString = @.getCurrentDirectory().substr(0, delimiterIndex + 1)
      @.showContents(dirString)
    selectFsNode: (fsTag) =>
      activeTags = contentsTag.getElementsByClassName 'active'
      for activeTag in activeTags
        activeTag.classList.remove 'active'
      fsTag.classList.add 'active'
    toggleSetting: () ->
      if @.getDispSetting()
        @.setDispSetting(false)
        settingPane.style.display = 'none'
      else
        @.setDispSetting(true)
        settingPane.style.display = 'block'
    loadConfigJson: () ->
      fileReader = new FileReader()
      fileReader.onload = (e) ->
        json = JSON.parse(fileReader.result)
        #json = eval(fileReader.result)
        console.log json['region']
        # load aws config from json
        AWS.config.region = json['region']
        AWS.config.update
          'accessKeyId':     json['access_key_id']
          'secretAccessKey': json['secret_access_key']
        window.bucketName = json['bucket_name']
      
      fileReader.onerror = (e) ->
        alert 'File Reading Error!'

      file = document.getElementById('config_json').files[0]
      fileReader.readAsText file

      if explorer.getDispSetting()
        explorer.toggleSetting()
    getTreeView: () ->
      return @.treeView
  @get: () ->
    return _instance ?= new _Explorer()

class FsObject
  children = []
  name = null
  type = null # d or f
  constructor: (name) ->
    @.name = name
  getName: () ->
    return @.name
  setName: (name) ->
    @.name = name
    return @
  getChild: (name) ->
    for fso in _children
      if fso.getName() == name
        return fso
    return null
  addChild: (name) ->
    if null == @.getChild(name)
      @.children.push(new FsObject(name))

class FsTree
  root = null
  constructor: () ->
    # add root node
    @.root = new FsObject()
  add: (prefix) ->
    targetDir = _root
    dirs = prefix.split(delimiter)
    for dir in dirs
      if dir != ""
        c = targetDir.getChild(dir)
        if (c == null)
          targetDir.addChild(dir)
        targetDir = targetDir.getChild(dir)



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


  
