Meteor.subscribe 'measurement_types'
Meteor.subscribe 'measurements'

Template.graph.helpers

  'renderGraph': () ->
    points = Measurements.find {'measurement_type': 'Barbell Back Squat'}
    points = points.fetch()
    max_per_day = {}
    date_per_day = {}
    for point in points
      do (point) ->
        one_rep_max = point['value']
        if point['reps'] > 1
          one_rep_max = Math.round point['value'] * (1 + (point['reps'] / 30.0))
        date = point['start_time']
        if date of max_per_day
          if one_rep_max > max_per_day[date]
            max_per_day[date] = one_rep_max
            date_per_day[date] = date
        else
          max_per_day[date] = one_rep_max
          date_per_day[date] = date
        return

    data = []
    for date, value of max_per_day
      data.push(
        'date': date_per_day[date]
        'value': value
      )

    if data.length > 0
      MG.data_graphic
        title: "Line Chart"
        data: data
        width: 1000
        height: 400
        right: 40
        target: document.getElementById('squat-graph')
        #interpolate: 'linear'
        missing_is_zero: true
        area: false
        x_accessor: 'date'
        y_accessor: 'value'
        #target: '#missing-y'
        #mouseover: (d, i) ->
        #  df = d3.time.format('%b %d, %Y')
        #  date = df(d.date)
        #  y_val = if d.value == 0 then 'no data' else d.value
        #  d3.select('#missing-y svg .mg-active-datapoint').text date + '   ' + y_val
        #  return

    return
