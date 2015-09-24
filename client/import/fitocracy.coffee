Template.fitocracy.events

  'change #files': (e) ->
    data_source = 'fitocracy'
    files = e.target.files or e.dataTransfer.files

    Meteor.call 'deleteMeasurementsWithSource', data_source

    for file in files
      do (file) ->
        reader = new FileReader
        reader.onloadend = (e) ->
          csv = e.target.result
          all = Papa.parse csv
          all = all['data']
          header = all.shift()
          # ["Activity", "Date (YYYYMMDD)", "Set", "", "unit", "Combined", "Points"]
          _.each all, (entry) ->
            if entry[0] == ''
              return
            name = entry[0]
            date = entry[1]

            reps = 0
            duration = 0
            value = null
            units = null
            # Parse combined set/rep/etc field
            # e.g.
            #  5 reps
            #  5 reps || weighted || 10 lb
            #  60 min || 3.2 mi
            #  45 lb || 5 reps
            #  45 min
            #  120 min || practice
            combined = entry[entry.length - 2]
            pieces = combined.split '||'
            for piece in pieces
              do (piece) ->
                piece = piece.replace /^\s+|\s+$/g, ''
                split_piece = piece.split ' '
                _value = split_piece[0]
                _units = split_piece[1]
                switch _units
                  when 'lb'
                    value = _value
                    units = 'lbs'
                  when 'reps'
                    reps = _value
                  when 'mi'
                    value = _value
                    units = 'mi'
                  when 'min'
                    duration = _value * 60
                  else
                    console.log 'could not parse ' + piece

            Meteor.call 'createMeasurementType', name, units, 'exercise'
            console.log name + '|' + value + '|' + reps + '|' + date + '|' + duration
            Meteor.call 'createMeasurement', name, value, reps, date, duration, data_source
            return
          return
        reader.readAsText file

    return
