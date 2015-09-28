Template.fitnotes.events

  'change #files': (e) ->
    data_source = 'fitnotes'
    name_override_map =
      'Deadlift': 'Conventional Barbell Deadlift'
      'Barbell Squat': 'Barbell Back Squat'
      'BJJ': 'Brazilian Jiu-Jitsu'
      'Dumbbell Overhead Triceps Extension': 'Lying Dumbbell Triceps Extension'
      'Lying Triceps Extension': 'Lying Barbell Triceps Extension'
      'Overhead Press': 'Standing Barbell Shoulder Press (OHP)',
      'Running (Outdoor)': 'Running'
      'Stationary Bike': 'Road Cycling'

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
          weight_units = header[3].match(/[^()]+(?=\))/)[0]
          # ["Date", "Exercise", "Category", "Weight (lbs)", "Reps", "Distance", "Distance Unit", "Time"]
          _.each csv, (entry) ->
            date = entry[0]
            name = entry[1]
            weight = entry[3]
            reps = entry[4]
            distance = entry[5]
            distance_units = entry[6]

            # Convert '1:00:00', '1:00', or '' to seconds
            duration = 0
            multiplier = 1
            split = entry[7].split(':')
            split.reverse()
            _.each split, (time) ->
              duration += time * multiplier
              multiplier *= 60

            if !_.isEmpty(distance) and Number(distance) > 0
              value = Number(distance)
              units = distance_units
            else if !_.isEmpty weight
              value = Number(weight)
              units = weight_units

            reps = Number(reps)

            if name of name_override_map
              name = name_override_map[name]

            Meteor.call 'createMeasurementType', name, units, 'exercise'
            Meteor.call 'createMeasurement', name, value, reps, date, duration, data_source
            return
          return
        reader.readAsText file

    return
