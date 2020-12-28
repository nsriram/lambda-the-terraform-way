exports.handler =  async (event) => {
  event.Records.forEach(record => console.log(record.dynamodb.Keys));
};
