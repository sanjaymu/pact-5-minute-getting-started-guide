const request = require("superagent");
const { Order } = require("./order");

const hostname = "127.0.0.1"

const fetchOrders = () => {
  return request.get(`http://${hostname}:${process.env.API_PORT}/orders`).then(
    (res) => {
      return res.body.reduce((acc, o) => {
        acc.push(new Order(o.id, o.items));
        return acc;
      }, []);
    },
    (err) => {
      const detail = err.response ? JSON.stringify(err.response.body) : err.message;
      throw new Error(`Error from response: ${detail}`);
    }
  );
};

module.exports = {
  fetchOrders,
};
