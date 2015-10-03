Template.nutrition.events

  'change #files': (e) ->
    data_source = 'myfitnesspal'

    files = e.target.files or e.dataTransfer.files

    Meteor.call 'deleteMeasurementsWithSource', data_source

    for file in files
      do (file) ->
        reader = new FileReader
        reader.onloadend = (e) ->
          text = e.target.result
          csv = Papa.parse text
          csv = csv['data']
          header = csv.shift()
          # ["Date", "Calories", "Carbs", "Fat", "Protein", "Cholesterol", "Sodium", "Sugars", "Fibre"]
          _.each csv, (entry) ->
            if entry[0] == ''
              return
            date = entry[0]
            name = 'Calories'
            value = Number(entry[1])
            units = 'calories'

            Meteor.call 'createMeasurementType', name, units, 'input'
            Meteor.call 'createMeasurement', name, value, 0, date, 0, data_source
            return
          return
        reader.readAsText file

    return
