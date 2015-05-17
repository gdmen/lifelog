@Notes = new (Mongo.Collection)('notes')
NotesSchema = new SimpleSchema(
  text:
    type: String
    label: 'Text'
  user:
    type: String
    label: 'User id'
)
Notes.attachSchema NotesSchema
Meteor.methods
  createNote: (text) ->
    if !Meteor.userId()
      throw new (Meteor.Error)('not-authorized')
    Notes.insert
      text: text
      user: Meteor.userId()
  deleteNote: (id) ->
    note = Notes.findOne id
    if note.user != Meteor.userId()
      throw new (Meteor.Error)('not-authorized')
    Notes.remove id
