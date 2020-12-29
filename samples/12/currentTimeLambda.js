exports.handler =  async (event) => {
  const payload = {
    date: new Date()
  };
  return JSON.stringify(payload);
};
