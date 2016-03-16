'use strict';

var request = new AWS.S3().listObjects({
  Bucket: window.bucketName,
  Delimiter: '/'
  //Marker: '/'    
});
/*
#  (err, data) ->
#    if err
#      console.log err, err.stack
#    return
#    console.log data
*/

request.on('success', function(response) {
  console.log response.data
});
request.send()

console.log('finish');