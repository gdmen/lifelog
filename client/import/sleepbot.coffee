Template.sleep.events

  'change #files': (e) ->
    data_source = 'sleepbot'

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
          # ["Date", "Sleep Time", "Awake Time", "Duration", "Rating"]
          _.each csv, (entry) ->
            date = new Date(entry[0] + entry[1])
            name = 'Sleep'

            duration = 0
            hours = entry[3].match(/\d+(?= hr)/)
            if !_.isNull hours
                duration += 60 * 60 * Number(hours[0])
            minutes = entry[3].match(/\d+(?= min)/)
            if !_.isNull minutes
                duration += 60 * Number(minutes[0])

            Meteor.call 'createMeasurementType', name, '', 'input'
            Meteor.call 'createMeasurement', name, 0, 0, date, duration, data_source
            return
          return
        reader.readAsText file

    return
