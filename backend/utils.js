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