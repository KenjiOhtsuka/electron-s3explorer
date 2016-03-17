mainPane = document.getElementById 'main_pane'
contents = document.getElementById 'contents'
delimiter = '/'


class FsObjectDomFactory
  #@createFileDom: () ->

  @createDirectoryDom: (name) ->
    li = document.createElement 'li'
    li.classList.add 'fs_node'
    li.setAttribute 'ondblclick', "explorer.showContents('#{name}')"
    li.appendChild(document.createTextNode(name))
    return li

  @createFileDom: (name) ->
    li = document.createElement 'li'
    li.classList.add 'fs_node'
    li.appendChild(document.createTextNode(name))
    return li

class Explorer
  _instance = null
  constructor: () ->
    throw new Error "This is singleton class!"
  class _Explorer
    currentDirectory = ""
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
      @.currentDirectory = prefix
      request.send()
    clearContents: () ->
      while (contents.lastChild)
        contents.removeChild contents.lastChild
    up: () ->
      if @.currentDirectory == 0
        return
      delimiterIndex =
        @.currentDirectory.substr(0, @.currentDirectory .length - 1).
          lastIndexOf(delimiter)
      dirString = @.currentDirectory.substr(0, delimiterIndex + 1)
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


  
