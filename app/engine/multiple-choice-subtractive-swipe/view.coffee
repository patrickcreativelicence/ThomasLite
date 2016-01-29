SlideView = require("views/slide")
Prefix = require("lib/prefix")
Draggy = require("views/components/draggy")

class MultipleChoiceSubtractiveSwipeView extends SlideView
  template: require("./template")

  afterShow:  ->
    return if @draggy

    @setEl @el.querySelectorAll(".swipe-text"), "swipes"

    @createDraggy()

  createDraggy: ->
    @draggies = []
    for el, i in @getEl("swipes")
      draggy = new Draggy
        el: el
        isParent: false

      @listenTo draggy, "drag", @onDrag
      @listenTo draggy, "drop", @onDrop

      draggy.reset x: 0, y: 0

      @draggies[i] = draggy

    # now that we have all the draggies, create a global centre x anchor point 
    # based on the x-centre of the first draggy
    @draggiesAnchorX = @draggies[0].x + (@draggies[0].offset.width / 2)
    @draggiesWidth = @draggies[0].offset.width
    @draggiesGraceX = (@draggiesWidth / 4)
    @draggiesSnapX = @draggies[0].x + @draggies[0].offset.width + 16

  onDrag: (draggy, isInitial) ->
    draggyCanMove = false
    otherDraggies = _.filter(@draggies, (d) -> d isnt draggy)

    for otherDraggy, i in otherDraggies
      otherDraggyCenter = otherDraggy.x + (otherDraggy.offset.width / 2)
      if otherDraggyCenter == @draggiesAnchorX
        draggyCanMove = true
    
    if draggyCanMove
      @updateBar(draggy)

  onDrop: (draggy, isReset) ->
    draggyCenter = 0
    for draggy, i in @draggies
      draggyCenter = draggy.x + (draggy.offset.width / 2)
      if draggyCenter > @draggiesAnchorX + @draggiesGraceX
        @transformEl draggy.el,
          x: @draggiesSnapX,
          opacity: 1
      else if draggyCenter < @draggiesAnchorX - @draggiesGraceX
        @transformEl draggy.el,
          x: @draggiesSnapX * -1,
          opacity: 1
      else if draggyCenter < @draggiesAnchorX + @draggiesGraceX && draggyCenter > @draggiesAnchorX - @draggiesGraceX
        @transformEl draggy.el,
          x: @draggiesAnchorX - (@draggies[0].offset.width / 2),
          opacity: 1

  updateBar: (draggy) ->
    @transformEl draggy.el,
      x: draggy.x
      opacity: 0.5

  events: ->
    "iostap .btn-next": "next"
    "iostap .btn-exit": "exit"

module.exports = MultipleChoiceSubtractiveSwipeView