const WebSocket = require('ws')

module.exports = (app, server, db) => {
  const wss = new WebSocket.Server({ server })

  wss.on("connection", (ws, req) => {

    ws.on("message", (message) => {
      console.log("received: %s", message)
    })

    ws.on("close", () => {

    })
  })
}