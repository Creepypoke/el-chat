const md5 = require("md5")

exports.roomBuilder = (room) => {
  return {
    id: room._id,
    name: room.name,
    users: [],
    messages: []
  }
}

exports.hashPassword = (password, salt) => {
  return md5(password)
}

exports.messageBuilder = (message) => {
  return {
    id: message._id,
    datetime: message.datetime,
    from: message.from,
    text: message.text,
    kind: message.kind
  }
}

exports.messageNormalizer = (message) => {
  return {
    roomId: message.roomId,
    datetime: message.message.datetime,
    from: message.message.from,
    text: message.message.text,
    kind: message.message.kind
  }
}

exports.userBuilder = (user) => {
  return {
    id: user._id,
    name: user.name
  }
}