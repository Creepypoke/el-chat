const path = require("path")
const express = require("express")
const expressWs = require("express-ws")
const MongoClient = require("mongodb").MongoClient

const config = require("./config")
const routes = require("./routes")

const app = express()
const appWs = expressWs(app)

app.use(express.static(path.join(process.cwd(), "dist")))

const dbAuthOptions = {
  auth: {
    user: config.db.user,
    password: config.db.password
  }
}

MongoClient.connect(config.db.url, dbAuthOptions, (err, client) => {
  if (err) throw err

  const db = client.db(config.db.name)

  routes(app, db)
  
  app.use(function (err, req, res, next) {
    console.error(err.stack)
    res.status(500).send('Something broke!')
  })
  
  startApp()
})



function startApp () {
  const port = config.port

  app.listen(port, () => {
    console.log("El-Chat app listening on http://localhost:" + port)
  })
}