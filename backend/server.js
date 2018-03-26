const express = require("express")
const expressWs = require("express-ws")

const path = require("path")

const app = express()
const appWs = expressWs(app)

app.use(express.static(path.join(process.cwd(), "dist")))

app.get("*", (req, res) => {
  const indexPath = path.join(process.cwd(), "dist", "index.html")
  res.sendFile(indexPath)
})

app.listen(3000, () => {
  console.log("El-Chat app listening on port 3000")
})