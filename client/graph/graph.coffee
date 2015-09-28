Meteor.subscribe 'measurement_types'
Meteor.subscribe 'measurements'

getLiftDisplayData = (name) ->
  datapoints = Measurements.find {'measurement_type': name}
  datapoints = datapoints.fetch()
  # Highest calculated 1rm per day
  max_per_day = {}
  for point in datapoints
    do (point) ->
      one_rep_max = point['value']
      if point['reps'] > 1
        one_rep_max = Math.floor point['value'] * (1 + (point['reps'] / 30.0))
      date = point['start_time'].valueOf()
      if date of max_per_day
        if one_rep_max > max_per_day[date][1]
          max_per_day[date] = [date, one_rep_max]
      else
        max_per_day[date] = [date, one_rep_max]
      return
  current_timestamp = new Date()
  current_timestamp = current_timestamp.getTime()
  if !(current_timestamp of max_per_day)
    max_per_day[current_timestamp] = [current_timestamp, 0]

  # Milliseconds days
  one_day = 86400000
  thirty_days = one_day * 30
  # Moving window of maxes over the past 30 days
  window = []
  window_dates = []
  display_data = []
  for key in Object.keys(max_per_day).sort()
    [date, one_rep_max] = max_per_day[key]
    window.push one_rep_max
    window_dates.push date
    for wdate in window_dates
      if date - thirty_days > wdate
        window.shift()
      else
        break
    while window_dates.length > window.length
      window_dates.shift()
    window_max = _.max window
    # Backfill maxes
    most_recent = display_data[display_data.length - 1]
    if !_.isUndefined most_recent
      increments = (date - most_recent[0]) / one_day
      value_diff = window_max - most_recent[1]
      i = 1
      while i < increments
        display_data.push [most_recent[0] + i * one_day, Math.floor window_max - (increments - i) / increments * value_diff]
        ++i

    display_data.push [date, window_max]

  return display_data

Template.graph.helpers

  renderGraphs: () ->

    graph_div = $('#one-rep-max')
    if !_.isEmpty(graph_div)
      deadlift_data = getLiftDisplayData 'Conventional Barbell Deadlift'
      squat_data = getLiftDisplayData 'Barbell Back Squat'
      bench_data = getLiftDisplayData 'Flat Barbell Bench Press'
      renderTo = $('<div>')
      graph_div.html renderTo
      renderTo.highcharts(
        chart:
          type: 'line'
        title:
          text: 'Estimated One Rep Max'
        tooltip:
          formatter: ->
            '<b>' + @y + ' lbs</b> ' + @series.name + '<br/>' + Highcharts.dateFormat('%b %e, %Y', new Date(@x))
        height: 400
        xAxis:
          type: 'datetime'
        yAxis:
          min: 0
          units: 'lbs'
        series: [
          {
            name: 'deadlift'
            data: deadlift_data
          }, {
            name: 'squat'
            data: squat_data
          }, {
            name: 'bench'
            data: bench_data
          }
        ]
      )

    return
