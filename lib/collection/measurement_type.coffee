@MeasurementTypes = new (Mongo.Collection)('measurement_types')
MeasurementTypesSchema = new SimpleSchema(
  name:
    type: String
    label: 'Name'
    index: true,
    unique: true
  units:
    type: String
    label: 'Units'
    optional: true
  category:
    type: String
    label: 'Category'
  user:
    type: String
    label: 'User id'
)
MeasurementTypes.attachSchema MeasurementTypesSchema
Meteor.methods
  createMeasurementType: (name, units, category) ->
    if !Meteor.userId()
      throw new (Meteor.Error)('not-authorized')
    model = MeasurementTypes.findOne(
      name: name)
    if _.isUndefined model
      model = MeasurementTypes.insert
        name: name
        units: units
        category: category
        user: Meteor.userId()
    return model
