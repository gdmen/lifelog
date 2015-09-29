Template.bodyweight.events

  'change #files': (e) ->
    data_source = 'fitnotes_bodyweight'

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
          units = header[2].match(/[^()]+(?=\))/)[0]
          # ["Date", "Time", "Body Weight (lbs)", "Body Fat"]
          _.each csv, (entry) ->
            date = new Date(entry[0] + 'T' + entry[1])
            value = entry[2]
            name = 'Body Weight'

            Meteor.call 'createMeasurementType', name, units, 'body metric'
            Meteor.call 'createMeasurement', name, value, 0, date, 0, data_source
            return
          return
        reader.readAsText file

    return
