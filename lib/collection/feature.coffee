@Projects = new (Mongo.Collection)('features')
ProjectsSchema = new SimpleSchema(
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
  tasks:
    type: [String]
    label: 'List of Task ids'
  projects:
    type: [String]
    label: 'List of sub Project ids'
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
Projects.attachSchema ProjectsSchema
Meteor.methods
  createProject: (brief) ->
    if !Meteor.userId()
      throw new (Meteor.Error)('not-authorized')
    Projects.insert
      brief: brief
      user: Meteor.userId()
  deleteProject: (id) ->
    feature = Projects.findOne id
    if feature.user != Meteor.userId()
      throw new (Meteor.Error)('not-authorized')
    Projects.remove id
