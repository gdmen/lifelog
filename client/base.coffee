Meteor.subscribe 'userData'

Template.body.events

  'click a#login-button': (e, t) ->
    e.preventDefault()
    Meteor.loginWithGoogle()
    return

  'click a#logout-button': (e, t) ->
    e.preventDefault()
    Meteor.logout()
    return
