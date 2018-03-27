const express = require("express")
const expressWs = require("express-ws")

const path = require("path")

const app = express()
const appWs = expressWs(app)

app.use(express.static(path.join(process.cwd(), "dist")))


app.get("/api/rooms", (req, res) => {

  const rooms = [
    { name: "room 1", id: "1", users: [] },
    { name: "room 2", id: "2", users: [{ name: "user1" }, { name: "user2" }, { name: "user3" }]}
  ]

  res.setHeader("Content-Type", "application/json")
  res.send(JSON.stringify(rooms));
})

app.get("*", (req, res) => {
  const indexPath = path.join(process.cwd(), "dist", "index.html")
  res.sendFile(indexPath)
})

app.listen(3000, () => {
  console.log("El-Chat app listening on port 3000")
})