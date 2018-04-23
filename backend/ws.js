const WebSocket = require('ws')
const jwt = require('jsonwebtoken')

const consts = require('./consts')
const utils = require('./utils')

module.exports = (app, server, db) => {
  app.rooms = {}

  const messagesCollection = db.collection("messages")

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
      case consts.MESSAGE_TYPES.RECENT:
        recentMessages(user, message.roomId, message.text)
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
    const normalizedMessage = utils.messageNormalizer(joinMessage)

    messagesCollection.insertOne(normalizedMessage, (err, result) => {
      joinMessage["id"] = result.inseredId
      notifyRoom(app.rooms[roomId], joinMessage)
    })
  }

  function leaveRoom(user, roomId) {
    if (!app.rooms[roomId]) return

    const leaveMessage = createLeaveMessage(roomId, user)
    const normalizedMessage = utils.messageNormalizer(leaveMessage)

    messagesCollection.insertOne(normalizedMessage, (err, result) => {
      leaveMessage["id"] = result.inseredId
      delete app.rooms[roomId].users[user.id]
      notifyRoom(app.rooms[roomId], leaveMessage)
    })
  }

  function textMessage(user, roomId, text) {
    const message = createTextMessage(roomId, user, text)
    const normalizedMessage = utils.messageNormalizer(message)

    messagesCollection.insertOne(normalizedMessage, (err, result) => {
      if (err) return

      message["id"] = result.inseredId
      notifyRoom(app.rooms[roomId], message)
    })
  }

  function recentMessages(user, roomId, count) {
    messagesCollection
    .find({ roomId: roomId })
    .sort("datetime", 1)
    .toArray((err, messages) => {
      if (err) return

      const message = createRecentMessage(roomId, messages)
      user.ws.send(JSON.stringify(message))
    })
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
        text: text,
        datetime: Date(),
        kind: consts.MESSAGE_TYPES.TEXT,
        from: cleanUser(user)
      },
      messages: []
    }
  }

  function createErrorMessage (roomId, errorText) {
    return {
      roomId: roomId,
      message: {
        datetime: Date(),
        text : errorText,
        kind : consts.MESSAGE_TYPES.ERROR,
        from: { name: "" }
      },
      messages: []
    }
  }

  function createJoinMessage (roomId, user) {
    return {
      roomId: roomId,
      message: {
        datetime: Date(),
        text: `${user.name} joined room`,
        kind: consts.MESSAGE_TYPES.JOIN,
        from: cleanUser(user)
      },
      messages: []
    }
  }

  function createLeaveMessage (roomId, user) {
    return {
      roomId: roomId,
      datetime: Date(),
      message: {
        datetime: Date(),
        text: `${user.name} leaved room`,
        kind: consts.MESSAGE_TYPES.LEAVE,
        from: cleanUser(user)
      },
      messages: []
    }
  }

  function createRecentMessage (roomId, messages) {
    return {
      roomId: roomId,
      messages: messages.map(utils.messageBuilder),
      message: null
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
          ws.user = user
          user.ws = ws
          processMessage(ws, messageObj, user)
        } else {
          const errorMessage = createErrorMessage(messageObj.roomId, "Authentication failed")
          ws.send(JSON.stringify(errorMessage))
        }
      })
    })

    ws.on("close", () => {
      if (ws.user) {
        const user = ws.user
        Object.values(app.rooms).forEach(room => {
          if (room.users[user.id]) leaveRoom(user, room.id)
        })
      }
    })
  })
}