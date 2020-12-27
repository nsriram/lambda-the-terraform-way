const accounting = require("accounting");

exports.handler = (event, context, callback) => {
  const value = event.value;
  callback(null, { amount: accounting.formatMoney(value) });
};

