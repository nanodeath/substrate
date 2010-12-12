canvas_enabled = document.createElement('canvas').getContext
css_key_map =
  "x": "left"
  "y": "top"

jQuery(($) ->

  class HTMLSubstrate
    constructor: (@dom, opts) ->
      @autopaint = if opts.autopaint? then opts.autopaint else true
      @grid_size = if opts.grid_size? then opts.grid_size else 1

    # Draw a rectangle!
    drawRectangle: (opts={}) ->
      r = new Rectangle this, opts
      if @autopaint && opts.paint != false
        r.painted = true
        @_appendDom r.dom
      r
      
    # Draws an image to the canvas
    # In addition to the regular options,
    # special options include:
    # - src: can either be a URI for an image, an Image() object, or an <img> tag.  In the latter two cases, the src attribute is copied to a new Image.
    drawImage: (opts={}) ->
      i = new Image this, opts
      if @autopaint && opts.paint != false
        i.painted = true
        @_appendDom i.dom
      i

    _appendDom: (dom) ->
      @dom.append dom
    
  class HTMLSubstrate.Shape
    constructor: ->
      # whether the element has ever been painted (and appended to the dom)
      @painted = false 
      
      # whether there are pending changes to the view
      @dirty = false 
      
      # whether this view has been flagged for removal
      @condemned = false
      
      # whether this view has finally been removed from the canvas
      @removed = false;
    set: (key, value, paint="auto") ->
      if typeof key == "string"
        css_key = css_key_map[key]
        if !css_key then css_key = key

        value = @_calculateValueFor(key, value)
        @css[css_key] = value
        @dirty = true
        
        if paint == "auto"
          @paint() if @substrate.autopaint
        else if paint
          @paint()
      else # is an object
        keyMap = key
        for key, value of keyMap
          @set(key, value, false)
        if paint == "auto"
          @paint() if @substrate.autopaint
        else if paint
          @paint()
    paint: ->
      if @condemned
        unless @removed
          @dom.remove()
          @removed = true
      else
        if @dirty
          @dirty = false
          @dom.css @css
          @css = {}
        unless @painted
          @painted = true
          @substrate._appendDom @dom
    _calculateValueFor: (key, value) ->
        value = switch key
          when "x", "y" then value * @substrate.grid_size
          else value
    _parseOptions: (opts) ->
      grid_size = @substrate.grid_size
      strokeWidth = opts.strokeWidth || 0
      opacity = opts.opacity || 1.0
      z_index = opts.z || 1
      @css =
        "position": "absolute"
        "left": @_calculateValueFor("x", opts.x)
        "top": @_calculateValueFor("y", opts.y)
        "width": opts.width * grid_size - strokeWidth*2
        "height": opts.height * grid_size - strokeWidth*2
        "opacity": opacity
        "background-color": opts.fillColor
        "border-style": "solid"
        "border-color": "red"
        "border-width": strokeWidth
        "z-index": z_index
    destroy: ->
      @condemned = true

  class HTMLSubstrate.Rectangle extends Shape
    constructor: (@substrate, opts) ->
      super
      @dom = $ "<div>"
      @_parseOptions opts
      @dom.css @css
      
  class HTMLSubstrate.Image extends Shape
    constructor: (@substrate, opts) ->
      super
      if typeof opts.src == "string"
        @img = new window.Image
        @img.src = opts.src
      else if opts.src instanceof Image
        @img = opts.src
      else if opts.src instanceof HTMLImageElement
        @img = new Image
        @img.src = opts.src.src
      else
        throw new Error "Invalid source for Image (was #{opts.src})"
      @dom = $ "<img>"
      @dom.attr "src", @img.src
      @_parseOptions opts
      @dom.css @css


  $.fn.substrate = (opts={}) ->
    s = if this.is "div"
      new HTMLSubstrate this, opts
    else if this.is "canvas"
      if canvas_enabled
        throw new Error("Canvas substrate isn't supported yet")
      else
        throw new Error("The <canvas> tag isn't supported on this browser")
    else
      throw new Error("Substrate only works on divs (for HTML mode) and canvas")

    this.css
      "position": "relative"
      "-webkit-user-select": "none"
      "-moz-user-select": "none"
    
    this.data "substrate", s
    this
)
