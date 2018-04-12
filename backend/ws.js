const WebSocket = require('ws')

module.exports = (app, server, db) => {
  const wss = new WebSocket.Server({ server })

  wss.on("connection", (ws, req) => {

    setTimeout(() => {
      ws.send(JSON.stringify(wsMessage));
    }, 3000)

    ws.on("message", (message) => {
      console.log("received: %s", message)
    })

    ws.on("close", () => {

    })
  })
}

const user = {
  "name" : "admin",
  "id": "0"
}

const message = {
  id: "123",
  from : user,
  text : "hello there",
  kind : "text"
}

const wsMessage = {
  roomId : "5ace3041c7925ccc3cd78205",
  message : message,
  messages : []
}



// type alias WsMessage =
//   { roomId : String
//   , message : Maybe Message
//   , messages : Maybe (List Message)
//   }


// type alias Message =
//   { id : String
//   , from : User
//   , text : String
//   , kind : String
//   }


// type alias User =
//   { name : String
//   , id : String
//   }