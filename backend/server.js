const path = require("path")
const http = require("http")
const express = require("express")
const bodyParser = require("body-parser")
const MongoClient = require("mongodb").MongoClient

const config = require("./config")
const routes = require("./routes")
const ws = require("./ws")

const app = express()

app.use(express.static(path.join(process.cwd(), "dist")))
app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())
app.config = config

const dbAuthOptions = {
  auth: {
    user: config.db.user,
    password: config.db.password
  }
}

MongoClient.connect(config.db.url, dbAuthOptions, (err, client) => {
  if (err) throw err

  const db = client.db(config.db.name)
  const server = http.createServer(app)

  routes(app, db)
  ws(app, server, db)

  app.use(function (err, req, res, next) {
    console.error(err.stack)
    res.status(500).send('Something broke!')
  })

  startApp(server)
})



function startApp (server) {
  const port = config.port

  server.listen(port, () => {
    console.log("El-Chat app listening on http://localhost:" + port)
  })
}


const msg = {
  roomId: "room id",
  message: {
    from: { name: "name"},
    text: "text",
    kind: "message/join/leave"
  },
  messages: [{
    from: { name: "name"},
    text: "text",
    kind: "message/join/leave"
  }]
}