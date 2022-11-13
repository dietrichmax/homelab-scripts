const http = require("http");
const axios = require('axios');

const server = http.createServer((request, response) => {
  let body = [];
  if (request.method === "POST") {
     request.on('data', (chunk) => {
      body.push(chunk);
      }).on('end', () => {
      body = JSON.parse(Buffer.concat(body).toString());
      axios({
        method: 'post',
        url: "",
        headers: {},
        data: body
      });

      axios({
        method: 'post',
        url: "",
        headers: {},
        data: body
      });

    });
  }


  response.end();
});

server.listen(9000);
