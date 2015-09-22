@Measurements = new (Mongo.Collection)('measurements')
MeasurementsSchema = new SimpleSchema(
  value:
    type: Number
    label: 'Value'
    decimal: true
    optional: true
  reps:
    type: Number
    label: 'Repetitions'
    optional: true
  start_time:
    type: Date
    label: 'Start time'
    optional: true
  duration:
    type: Number
    label: 'Duration (in seconds)'
    optional: true
  measurement_type:
    type: String
    label: 'MeasurementType name'
  source:
    type: String
    label: 'Data source'
  user:
    type: String
    label: 'User id'
)
Measurements.attachSchema MeasurementsSchema
Meteor.methods
  createMeasurement: (type_name, value, reps, start_time, duration, source) ->
    if !Meteor.userId()
      throw new (Meteor.Error)('not-authorized')
    type = MeasurementTypes.findOne(
      name: type_name)
    if !type
      throw new (Meteor.Error)('no such measurement type')
    Measurements.insert
      value: value
      reps: reps
      start_time: start_time
      duration: duration
      measurement_type: type_name
      source: source
      user: Meteor.userId()

    deleteMeasurementsWithSource: (source) ->
      Measurements.remove
        source: source
