Meteor.subscribe 'tasks'

Template.dashboard.helpers
  tasks: ->
    Tasks.find {}, sort: created: -1

Template.createTask.events

  'submit #create-task': (e) ->
    e.preventDefault()
    Meteor.call 'createTask',
      e.target.brief.value
    e.target.brief.value = ""
    return
