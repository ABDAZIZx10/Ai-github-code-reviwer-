/**
 * CI fixture — smoke test (npm test).
 *
 * Starts a tiny Express server on port 5000, then GETs / and expects HTTP 200.
 * An intentional syntax error near the bottom forces the job to fail so the
 * GitHub Actions → n8n failure path can be demonstrated.
 *
 * To run a green smoke test locally:
 *   1. Comment out the INTENTIONAL FAILURE line at the bottom.
 *   2. Ensure `express` is installed (`npm install`).
 *   3. Run `npm test`.
 */

const http = require("http");
const express = require("express");

const app = express();

const options = {
  hostname: "localhost",
  port: 5000,
  path: "/",
  method: "GET",
};

app.get("/", (req, res) => {
  res.status(200).send("OK");
});

const server = app.listen(5000, () => {
  console.log("Smoke test running...");
  const req = http.get(options, (res) => {
    if (res.statusCode === 200) {
      console.log("Smoke Test Passed");
      server.close(() => process.exit(0));
    } else {
      console.error(`Smoke Test failed with status code: ${res.statusCode}`);
      server.close(() => process.exit(1));
    }
  });

  req.on("error", (e) => {
    console.error(`Problem with request: ${e.message}`);
    server.close(() => process.exit(1));
  });
});

// INTENTIONAL FAILURE: invalid JS — comment this out to run a green smoke test
console.log(this is also an intentional bug);
