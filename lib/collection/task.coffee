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
  estimate:
    type: Number
    label: 'Time estimate in minutes'
    defaultValue: 0
  created:
    type: Date
    label: 'Date created'
    autoValue: ->
      if @isInsert
        return new Date
      @unset
      return
  updated:
    type: Date
    label: 'Date updated'
    autoValue: ->
      new Date
  user:
    type: String
    label: 'User id'
)
Tasks.attachSchema TasksSchema
Meteor.methods
  createTask: (brief, estimate) ->
    if !Meteor.userId()
      throw new (Meteor.Error)('not-authorized')
    Tasks.insert
      brief: brief
      estimate: estimate
      user: Meteor.userId()
  setTaskState: (id, state) ->
    task = Tasks.findOne id
    if task.user != Meteor.userId()
      throw new (Meteor.Error)('not-authorized')
    Tasks.update id, $set: state: state, updated: new Date
  deleteTask: (id) ->
    task = Tasks.findOne id
    if task.user != Meteor.userId()
      throw new (Meteor.Error)('not-authorized')
    Meteor.call 'setTaskState', id, 'DELETED'
