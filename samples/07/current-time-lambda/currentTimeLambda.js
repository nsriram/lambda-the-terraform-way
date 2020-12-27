const moment = require('moment');

exports.handler = (event, context, callback) => {
  const time = moment().format('MMMM Do YYYY, h:mm:ss a');
  callback(null, { time });
};
