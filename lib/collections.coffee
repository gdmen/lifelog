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


@Tasks = new (Mongo.Collection)('tasks')
TasksSchema = new SimpleSchema(
  brief:
    type: String
    label: 'Brief summary'
  state:
    type: String
    label: 'Current state'
    allowedValues: ['QUEUED', 'ACTIVE', 'PAUSED', 'COMPLETE', 'DELETED']
    defaultValue: 'QUEUED'
  notes:
    type: [String]
    label: 'List of Note ids'
    optional: true
  created:
    type: Date
    label: 'Date created'
    autoValue: ->
      new Date
  completed:
    type: Date
    label: 'Date completed'
    optional: true
  user:
    type: String
    label: 'User id'
)
Tasks.attachSchema TasksSchema
Meteor.methods
  createTask: (brief) ->
    if !Meteor.userId()
      throw new (Meteor.Error)('not-authorized')
    Tasks.insert
      brief: brief
      user: Meteor.userId()
  deleteTask: (id) ->
    task = Tasks.findOne id
    if task.user != Meteor.userId()
      throw new (Meteor.Error)('not-authorized')
    Tasks.remove id
