Meteor.subscribe 'tasks'

Template.dashboard.helpers
  tasks: ->
    Tasks.find { state: $ne: 'DELETED' }, sort: created: -1

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
    
