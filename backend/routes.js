const utils = require("./utils")

module.exports = (app, db) => {
  const roomsCollection = db.collection("rooms")
  
  app.get("/api/rooms", (req, res, next) => {
    roomsCollection.find({}).toArray((err, rooms) => {
      if (err) return next(err)
      
      rooms = rooms.map(utils.roomBuilder)
      res.json(rooms)
    })
  })
  
  app.post("/api/rooms", (req, res, next) => {
    const errors = []

    if (!req.body.name) errors.push({ field: "name", message: "Empty" })

    const newRoom = { name: req.body.name }

    if (errors.length > 0) return res.status(400).json(errors)

    roomsCollection.insertOne(newRoom, (err, result) => {
      if (err) return next(err)

      res.status(201).json({ id: result.insertedId})  
    })
  })


  app.get("*", (req, res) => {
    const indexPath = path.join(process.cwd(), "dist", "index.html")
    res.sendFile(indexPath)
  })
}