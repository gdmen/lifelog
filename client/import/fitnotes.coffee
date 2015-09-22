Template.fitnotes.events

  'change #files': (e) ->
    data_source = 'fitnotes'
    files = e.target.files or e.dataTransfer.files
    i = 0
    file = undefined
    while file = files[i]
      reader = new FileReader
      reader.onloadend = (e) ->
        csv = e.target.result
        all = Papa.parse csv
        all = all['data']
        header = all.shift()
        weight_units = header[3].match(/[^()]+(?=\))/)[0]
        # ["Date", "Exercise", "Category", "Weight (lbs)", "Reps", "Distance", "Distance Unit", "Time"]
        Meteor.call 'deleteMeasurementsWithSource', data_source
        _.each all, (entry) ->
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
          Meteor.call 'createMeasurementType', name, units, 'exercise'
          console.log name + '|' + value + '|' + reps + '|' + date + '|' + duration
          Meteor.call 'createMeasurement', name, value, reps, date, duration, data_source
          return
        return
      reader.readAsText file
      i++

    return


Template.createTask.events

  'submit #create-task': (e) ->
    e.preventDefault()
    Meteor.call 'createTask', e.target.brief.value
    e.target.brief.value = ""
    return

Template.showTask.events

  'click .toggle': (e) ->
    e.preventDefault()
    state = if e.target.checked then 'COMPLETE' else 'QUEUED'
    Meteor.call 'setTaskState', @_id, state
    return

  'click .delete': (e) ->
    e.preventDefault()
    Meteor.call 'deleteTask', @_id
    return

  "click .line": (e) ->
    e.preventDefault()
    e.target.focus()
    priorId = Session.get 'selectedTask'

    Session.set 'selectedTask', event.target.id

  "keydown .line": (e) ->
    selectedId = Session.get 'selectedTask'
    if selectedId != e.target.id
      return
    code = e.keyCode or e.which
    if code == 9
      e.preventDefault()
      console.log "TAB " + selectedId

Template.showTask.helpers

  'isComplete': ->
    return @state == 'COMPLETE'
    
