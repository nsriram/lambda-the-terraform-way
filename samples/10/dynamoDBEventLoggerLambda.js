exports.handler =  async (event, context, callback) => {
  event.Records.forEach(record => console.log(record.dynamodb.Keys));
};
