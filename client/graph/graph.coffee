Meteor.subscribe 'measurement_types'
Meteor.subscribe 'measurements'

Template.graph.helpers

  'renderGraph': () ->
    points = Measurements.find {'measurement_type': 'Barbell Back Squat'}
    points = points.fetch()
    max_per_day = {}
    for point in points
      do (point) ->
        one_rep_max = point['value']
        if point['reps'] > 1
          one_rep_max = Math.round point['value'] * (1 + (point['reps'] / 30.0))
        date = point['start_time'].valueOf()
        if date of max_per_day
          if one_rep_max > max_per_day[date][1]
            max_per_day[date] = [date, one_rep_max]
        else
          max_per_day[date] = [date, one_rep_max]
        return

    data = []
    for date in Object.keys(max_per_day).sort()
      data.push max_per_day[date]

    graph_div = $('#squat-graph')
    if data.length > 0 and !_.isEmpty(graph_div)
      renderTo = $('<div>')
      graph_div.html renderTo
      renderTo.highcharts(
        title:
          text: 'Estimated One Rep Max'
        legend:
          enabled: false
        height: 400
        type: 'line'
        xAxis:
          type: 'datetime'
        series: [
          data: data
        ]
      )

    return
