const AWS = require('aws-sdk');
const s3 = new AWS.S3();

exports.handler = async (event, context, callback) => {
  const uploadedObject = event.Records[0].s3.object;
  const objectKey = uploadedObject.key;
  if (!objectKey.includes('metadata.txt')) {
    const metadata = {
      objectKey,
      objectSize: uploadedObject.size,
      objectETag: uploadedObject.eTag,
      objectCreationTime: event.Records[0].eventTime,
    };
    const bucketName = event.Records[0].s3.bucket.name;
    const metadataObjectKey = `${uploadedObject.key}-metadata.txt`;
    const s3Params = {
      Bucket: bucketName,
      Key: metadataObjectKey,
      Body: JSON.stringify(metadata),
      ServerSideEncryption: 'AES256',
      ContentType: 'text/plain'
    };
    s3.putObject(s3Params).promise()
      .then((data) => {
        console.log('Metadata uploaded');
        console.log(data);
      }).catch((err) => {
      console.log('Error occured uploading');
      console.log(err);
    });
    callback(null, `${metadataObjectKey} uploaded successfully.`);
  }
  callback(null, `${objectKey} ignored.`);
};

