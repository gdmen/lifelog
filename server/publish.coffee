Meteor.publish 'userData', ->
  if @userId
    return Meteor.users.find({ _id: @userId }, fields:
      'services.google.given_name': 1
      'services.google.email': 1
    )
  else
    @ready()
  return


Meteor.publish 'notes', ->
  Notes.find user: @userId


Meteor.publish 'tasks', ->
  Tasks.find user: @userId
