mainPane = document.getElementById 'main_pane'
contents = document.getElementById 'contents'

showContent: () ->
  request = new AWS.S3().listObjects
    Bucket: window.bucketName
    Delimiter: '/'
  request.on 'success', (response) ->
    json = response.data
    console.log json
    for d in json['CommonPrefixes']
      contents.appendChild(FsObjectDomFactory.createDirectoryDom(d['Prefix']))
  request.send()

class FsObjectDomFactory
  #@createFileDom: () ->

  @createDirectoryDom: (name) ->
    li = document.createElement('li')
    li.appendChild(document.createTextNode(name))
    return li



request = new AWS.S3().listObjects
  Bucket: window.bucketName,
  Delimiter: '/'
  #Marker: '/'
#  (err, data) ->
#    if err
#      console.log err, err.stack
#    return
#    console.log data

  
  
