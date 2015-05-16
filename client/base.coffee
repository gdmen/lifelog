Meteor.subscribe 'userData'
Meteor.subscribe 'tasks'

Template.body.events

  'click a#login-button': (e, t) ->
    e.preventDefault()
    Meteor.loginWithGoogle()
    return

  'click a#logout-button': (e, t) ->
    e.preventDefault()
    Meteor.logout()
    return

  'submit .new-task': (e) ->
    Meteor.call 'createTask', event.target.text.value
    event.target.text.value = ""
    return false

Template.body.helpers
  tasks: ->
    Tasks.find {}, sort: created: -1
