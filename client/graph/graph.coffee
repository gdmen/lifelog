Meteor.subscribe 'measurement_types'
Meteor.subscribe 'measurements'


# Milliseconds in a day
ONE_DAY = 86400000
START_DATE = new Date('May 22, 2012')


getCalorieDisplayData = () ->
  datapoints = Measurements.find {'measurement_type': 'Calories', 'start_time': { $gte : START_DATE } }, sort: 'start_time': 1
  datapoints = datapoints.fetch()
  display_data = []
  for point in datapoints
    do (point) ->
      display_data.push [point['start_time'].valueOf(), point['value']]
  return display_data


getSleepDurationDisplayData = () ->
  datapoints = Measurements.find {'measurement_type': 'Sleep', 'start_time': { $gte : START_DATE } }, sort: 'start_time': 1
  datapoints = datapoints.fetch()
  display_data = []
  for point in datapoints
    do (point) ->
      hours = Number (point['duration'] / 3600).toFixed(1)
      display_data.push [point['start_time'].valueOf(), hours]
  return display_data


getBodyMetricDisplayData = (name) ->
  datapoints = Measurements.find {'measurement_type': name, 'start_time': { $gte : START_DATE } }, sort: 'start_time': 1
  datapoints = datapoints.fetch()
  display_data = []
  for point in datapoints
    do (point) ->
      display_data.push [point['start_time'].valueOf(), point['value']]
  return display_data


getLiftDisplayData = (name) ->
  datapoints = Measurements.find {'measurement_type': name, 'start_time': { $gte : START_DATE } }
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

  days_max_persists = ONE_DAY * 30
  # Moving window of maxes over the past <days_max_persists> days
  window = []
  window_dates = []
  display_data = []
  for key in Object.keys(max_per_day).sort()
    [date, one_rep_max] = max_per_day[key]
    window.push one_rep_max
    window_dates.push date
    for wdate in window_dates
      if date - days_max_persists > wdate
        window.shift()
      else
        break
    while window_dates.length > window.length
      window_dates.shift()
    window_max = _.max window
    display_data.push [date, window_max]

  return display_data


getCombinedLiftDisplayData = (lift_data_array) ->
  display_data = []
  lift_maxes = []
  for i in [0...lift_data_array.length] by 1
    lift_maxes.push 0
  days_interval = ONE_DAY * 30
  date_to_check = START_DATE.getTime()
  current_date = (new Date()).getTime()
  # Add a max to the graph for every <days_interval> days since START_DATE
  while date_to_check < current_date
    for i of lift_data_array
      lift_data = lift_data_array[i]
      for entry in lift_data
        if entry[0] <= date_to_check
          lift_maxes[i] = Math.max(lift_maxes[i], entry[1])
    total_max = _.reduce lift_maxes, ((sum, el) -> sum + el), 0
    display_data.push [date_to_check, total_max]
    date_to_check += days_interval

  date_to_check = current_date
  for i of lift_data_array
    lift_data = lift_data_array[i]
    for entry in lift_data
      if entry[0] <= date_to_check
        lift_maxes[i] = Math.max(lift_maxes[i], entry[1])
  total_max = _.reduce lift_maxes, ((sum, el) -> sum + el), 0
  display_data.push [date_to_check, total_max]

  return display_data


Template.graph.helpers

  renderGraphs: () ->
    one_rep_max_graph_div = $('#one-rep-max')
    if !_.isEmpty(one_rep_max_graph_div)
      deadlift_data = getLiftDisplayData 'Conventional Barbell Deadlift'
      squat_data = getLiftDisplayData 'Barbell Back Squat'
      bench_data = getLiftDisplayData 'Flat Barbell Bench Press'
      ohp_data = getLiftDisplayData 'Standing Barbell Shoulder Press (OHP)'

      renderTo = $('<div>')
      one_rep_max_graph_div.html renderTo
      renderTo.highcharts(
        chart:
          type: 'spline'
        title:
          text: 'Estimated One Rep Max'
        tooltip:
          formatter: ->
            '<b>' + @y + ' lbs</b> ' + @series.name + '<br/>' + Highcharts.dateFormat('%b %e, %Y', new Date(@x))
        plotOptions:
          series:
            marker:
              enabled: false
              symbol: 'circle'
              radius: 2
            fillOpacity: 0.5
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
          }, {
            name: 'ohp'
            data: ohp_data
          }
        ]
      )

    bw_graph_div = $('#body-weight')
    if !_.isEmpty(bw_graph_div)
      bw_data = getBodyMetricDisplayData 'Body Weight'
      renderTo = $('<div>')
      bw_graph_div.html renderTo
      renderTo.highcharts(
        chart:
          type: 'spline'
        title:
          text: 'Body Weight'
        legend:
          enabled: false
        tooltip:
          formatter: ->
            '<b>' + @y + ' lbs</b> ' + @series.name + '<br/>' + Highcharts.dateFormat('%b %e, %Y', new Date(@x))
        height: 400
        xAxis:
          type: 'datetime'
          min: START_DATE.getTime()
        yAxis:
          units: 'lbs'
        series: [
          name: 'body weight'
          data: bw_data
        ]
      )

    sleep_duration_graph_div = $('#sleep-duration')
    if !_.isEmpty(sleep_duration_graph_div)
      sleep_duration_data = getSleepDurationDisplayData()
      renderTo = $('<div>')
      sleep_duration_graph_div.html renderTo
      renderTo.highcharts(
        chart:
          type: 'scatter'
        title:
          text: 'Sleep Duration'
        legend:
          enabled: false
        tooltip:
          formatter: ->
            '<b>' + @y + ' hours</b> ' + @series.name + '<br/>' + Highcharts.dateFormat('%b %e, %Y', new Date(@x))
        height: 400
        xAxis:
          type: 'datetime'
          min: START_DATE.getTime()
        yAxis:
          units: 'hours'
        series: [
          name: 'sleep'
          data: sleep_duration_data
        ]
      )

    calorie_graph_div = $('#calories')
    if !_.isEmpty(calorie_graph_div)
      calorie_data = getCalorieDisplayData()
      renderTo = $('<div>')
      calorie_graph_div.html renderTo
      renderTo.highcharts(
        chart:
          type: 'scatter'
        title:
          text: 'Calories'
        legend:
          enabled: false
        tooltip:
          formatter: ->
            '<b>' + @y + ' calories</b> ' + @series.name + '<br/>' + Highcharts.dateFormat('%b %e, %Y', new Date(@x))
        height: 400
        xAxis:
          type: 'datetime'
          min: START_DATE.getTime()
        yAxis:
          units: 'calories'
        series: [
          name: 'calories eaten'
          data: calorie_data
        ]
      )

    timeline_graph_div = $('#timeline')
    if !_.isEmpty(timeline_graph_div)
      total_max_data = getCombinedLiftDisplayData [deadlift_data, squat_data, bench_data]
      renderTo = $('<div>')
      timeline_graph_div.html renderTo
      renderTo.highcharts(
        title:
          text: 'Timeline'
        tooltip:
          formatter: ->
            @series.name + ': <b>' + @y + ' lbs</b><br/>' + Highcharts.dateFormat('%b %e, %Y', new Date(@x))
        plotOptions:
          series:
            marker:
              enabled: false
              symbol: 'circle'
              radius: 2
            fillOpacity: 0.5
        height: 800
        xAxis:
          type: 'datetime'
          min: START_DATE.getTime()
        yAxis: [
          {
            title:
              text: 'Total 1RM'
              style:
                color: Highcharts.getOptions().colors[2]
            labels:
              format: '{value} lbs'
              style:
                color: Highcharts.getOptions().colors[2]
            min: 0
          }, {
            title:
              text: 'Body Weight'
              style:
                color: Highcharts.getOptions().colors[0]
            labels:
              format: '{value} lbs'
              style:
                color: Highcharts.getOptions().colors[0]
            opposite: true
          }
        ]
        series: [
          {
            name: 'Total 1RM'
            type: 'line'
            dashStyle: 'dash'
            color: Highcharts.getOptions().colors[2]
            data: total_max_data
            step: true
          }, {
            name: 'Body Weight'
            type: 'spline'
            data: bw_data
            color: Highcharts.getOptions().colors[0]
            yAxis: 1
          }
        ]
      )

    return
