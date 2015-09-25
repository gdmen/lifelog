Meteor.publish 'userData', ->
  if @userId
    return Meteor.users.find({ _id: @userId }, fields:
      'services.google.given_name': 1
      'services.google.email': 1
    )
  else
    @ready()
  return


Meteor.publish 'measurements', ->
  if @userId
    return Measurements.find user: @userId
  else
    @ready()
  return


Meteor.publish 'measurement_types', ->
  if @userId
    return MeasurementTypes.find user: @userId
  else
    @ready()
  return
