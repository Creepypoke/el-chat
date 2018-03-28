exports.roomBuilder = (room) => {
  return {
    id: room._id,
    name: room.name,
    users: []
  }
}