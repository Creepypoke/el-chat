const path = require("path")
const jwt = require("jsonwebtoken")

const utils = require("./utils")

module.exports = (app, db) => {
  const roomsCollection = db.collection("rooms")
  const usersCollection = db.collection("users")

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

      res.status(201).json({ id: result.insertedId, name: req.body.name, users: [] })
    })
  })

  app.post("/sign-up", (req, res, next) => {
    const errors = []

    const name = req.body.name
    const password = req.body.password
    const passwordConfirm = req.body.passwordConfirm

    if (!name) errors.push({ field: "name", message: "Can't be blank" })
    if (!password) errors.push({ field: "password", message: "Can't be blank" })
    if (!passwordConfirm) errors.push({ field: "passwordConfirm", message: "Can't be blank"})

    if (password && passwordConfirm && (password !== passwordConfirm)) {
      errors.push({ field: "passwordConfirm", message: "Passwords didn't match" })
    }

    if (errors.length > 0) return res.status(400).json(errors)

    usersCollection.findOne({ name: name }, (err, user) => {
      if (err) return next(err)

      if (user) {
        errors.push({ field: "name", message: "Already taken" })
        return res.status(400).json(errors)
      }

      const newUser = {
        name: name,
        hashedPassword: utils.hashPassword(password, app.config.salt)
      }

      usersCollection.insertOne(newUser, (err, result) => {
        if (err) return next(err)

        const token = jwt.sign({ name: newUser.name, id: result.insertedId }, app.config.salt)
        res.status(201).json({ jwt: token })
      })
    })
  })

  app.post("/sign-in", (req, res, next) => {
    const errors = []

    const name = req.body.name
    const password = req.body.password

    if (!name) errors.push({ field: "name", message: "Can't be blank" })
    if (!password) errors.push({ field: "password", message: "Can't be blank" })

    if (errors.length > 0) return res.status(400).json(errors)

    const hashedPassword = utils.hashPassword(password, app.config.salt)

    usersCollection.findOne({ name: name, hashedPassword: hashedPassword }, (err, user) => {
      if (err) return next(err)

      if (!user) {
        errors.push({ field: "name", message: "Wrong credentials" })
        return res.status(400).json(errors)
      }

      const token = jwt.sign({ name: name, id: user._id }, app.config.salt)
      res.status(201).json({ jwt: token })

    })
  })

  app.get("*", (req, res) => {
    const indexPath = path.join(process.cwd(), "dist", "index.html")
    res.sendFile(indexPath)
  })
}