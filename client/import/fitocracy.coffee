Template.fitocracy.events

  'change #files': (e) ->
    data_source = 'fitocracy'
    name_override_map =
      'Ab Wheel (kneeling)': 'Kneeling Ab Wheel'
      'Barbell Bench Press': 'Flat Barbell Bench Press'
      'Barbell Deadlift': 'Conventional Barbell Deadlift'
      'Barbell Squat': 'Barbell Back Squat'
      'Chin-Up': 'Chin Up'
      'Cycling': 'Road Cycling'
      'Dips - Triceps Version': 'Parallel Bar Triceps Dip'
      'General Yoga': 'Yoga'
      'Indoor Volleyball': 'Volleyball'
      'Light Walking (secondary e.g. commute, on the job, etc)': 'Walking'
      'One-Arm Dumbbell Row': 'One Arm Dumbbell Row'
      'Parallel-Grip Pull-Up': 'Neutral Grip Pull Up'
      'Pull-Up': 'Pull Up'
      'Push-Up': 'Push Up'
      'Standing Military Press': 'Standing Barbell Shoulder Press (OHP)'
      'Wide-Grip Pull-Up': 'Wide Grip Pull Up'

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
          # ["Activity", "Date (YYYYMMDD)", "Set", "", "unit", "Combined", "Points"]
          _.each csv, (entry) ->
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
                    console.log 'could not parse units from "' + piece + '"'

            if name of name_override_map
              name = name_override_map[name]

            Meteor.call 'createMeasurementType', name, units, 'exercise'
            Meteor.call 'createMeasurement', name, value, reps, date, duration, data_source
            return
          return
        reader.readAsText file

    return
