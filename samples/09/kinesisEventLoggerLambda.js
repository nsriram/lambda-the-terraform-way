exports.handler = async (event) => {
  console.log(JSON.stringify(event));
  event.Records.forEach(record => {
    const eventPayload = Buffer.from(record.kinesis.data, 'base64')
      .toString('utf8');
    console.log(eventPayload);
  });
};
