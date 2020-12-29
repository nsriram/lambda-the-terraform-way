exports.handler =  async (event) => {
  console.log(JSON.stringify(event));
  event.Records.forEach(record => console.log(record.body));
};
