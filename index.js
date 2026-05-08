const express = require("express");
const AWS = require("aws-sdk");

const app = express();
const port = process.env.PORT || 3000;
const awsRegion = process.env.AWS_REGION || "us-east-1";

const s3 = new AWS.S3({ region: awsRegion });

app.use(express.static("public"));

app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok", uptime: process.uptime() });
});

app.get("/s3-check", async (req, res) => {
  try {
    const data = await s3.listBuckets().promise();

    res.status(200).json({
      status: "ok",
      buckets: data.Buckets.map(b => b.Name)
    });

  } catch (error) {
    res.status(500).json({
      status: "error",
      message: error.message
    });
  }
});

app.listen(port, () => {
  console.log(`Rodando na porta ${port} na regiao AWS ${awsRegion}`);
});
