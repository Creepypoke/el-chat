const WebSocket = require('ws')
const jwt = require('jsonwebtoken')

const consts = require('./consts')


module.exports = (app, server, db) => {
  app.rooms = {}

  const wss = new WebSocket.Server({ server })

  function getUserByJwt (token, callback) {
    const user = jwt.verify(token, app.config.salt, (err, user) => {
      if (err) return callback(null)
      callback(user)
    })
  }


  function processMessage (ws, message, user) {
    switch (message.kind) {
      case consts.MESSAGE_TYPES.JOIN:
        joinRoom(user, message.roomId)
        break
      case consts.MESSAGE_TYPES.LEAVE:
        leaveRoom(user, message.roomId)
        break
      case consts.MESSAGE_TYPES.TEXT:
        textMessage(user, message.roomId, message.text)
        break
      default:
        const errorMessage = createErrorMessage(message.roomId, "unsupported kind of message")
        ws.send(JSON.stringify(errorMessage))
        break
    }
  }


  function joinRoom (user, roomId) {
    if (!app.rooms[roomId]) {
      app.rooms[roomId] = {
        id: roomId,
        users: {}
      }
    }
    app.rooms[roomId].users[user.id] = user

    const joinMessage = createJoinMessage(roomId, user)

    notifyRoom(app.rooms[roomId], joinMessage)
  }

  function leaveRoom(user, roomId) {
    if (!app.rooms[roomId]) return

    delete app.rooms[roomId].users[user.id]

    const leaveMessage = createLeaveMessage(roomId, user)
    notifyRoom(app.rooms[roomId], leaveMessage)
  }

  function textMessage(user, roomId, text) {
    const message = createTextMessage(roomId, user, text)
    notifyRoom(app.rooms[roomId], message)
  }

  function notifyRoom(room, message) {
    Object.values(room.users).forEach((user) => {
      user.ws.send(JSON.stringify(message))
    })
  }

  function createTextMessage (roomId, user, text) {
    return {
      roomId: roomId,
      message: {
        id: "123",
        text: text,
        kind: consts.MESSAGE_TYPES.TEXT,
        from: cleanUser(user)
      }
    }
  }

  function createErrorMessage (roomId, errorText) {
    return {
      roomId: roomId,
      message: {
        text : errorText,
        kind : consts.MESSAGE_TYPES.ERROR
      }
    }
  }

  function createJoinMessage (roomId, user) {
    return {
      roomId: roomId,
      message: {
        text: `${user.name} joined room`,
        kind: consts.MESSAGE_TYPES.JOIN
      }
    }
  }

  function createLeaveMessage (roomId, user) {
    return {
      roomId: roomId,
      message: {
        text: `${user.name} leaved room`,
        kind: consts.MESSAGE_TYPES.LEAVE
      }
    }
  }

  function cleanUser (dirtyUser) {
    return {
      name: dirtyUser.name,
      id: dirtyUser.id
    }
  }

  wss.on("connection", (ws, req) => {

    ws.on("message", (message) => {
      messageObj = JSON.parse(message)

      const jwt = messageObj.jwt

      getUserByJwt(jwt, (user) => {
        if (user) {
          user.ws = ws
          processMessage(ws, messageObj, user)
        } else {
          const errorMessage = createErrorMessage(messageObj.roomId, "Authentication failed")
          ws.send(JSON.stringify(errorMessage))
        }
      })
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