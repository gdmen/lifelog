Meteor.subscribe 'tasks'

Template.dashboard.helpers
  tasks: ->
    Tasks.find {}, sort: created: -1

Template.dashboard.events

  'submit #create-task': (e) ->
    estimate = Math.round e.target.estimate.value * 60
    if !estimate
      estimate = 5
    Meteor.call 'createTask',
      e.target.brief.value
      estimate
    e.target.brief.value = e.target.estimate.value = ""
    return false
