canvas_enabled = document.createElement('canvas').getContext

offsetFunction = (obj, opts) ->
    ["background-position", obj._calculateValueFor("offsetX") + "px " + obj._calculateValueFor("offsetY") + "px"]

css_key_map =
  "x": "left"
  "y": "top"
  "z": "z-index"
  "strokeWidth": "border-width"
  "offsetX": offsetFunction
  "offsetY": offsetFunction

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
      i = new HTMLSubstrate.Image this, opts
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
        @opts[key] = value
        
        css_key = css_key_map[key]
        if !css_key then css_key = key
        
        if typeof css_key == "function"
          [css_key, value] = css_key this, @opts
        else
          value = @_calculateValueFor(key)
          
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
        if (paint == "auto" && @substrate.autopaint) || paint
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
    _calculateValueFor: (key) ->
      value = @opts[key]
      switch key
        when "x", "y"
          (value || 0) * @substrate.grid_size
        when "offsetX", "offsetY"
          (-value || 0) * @substrate.grid_size
        when "width", "height"
          (value || 1) * @substrate.grid_size - @_calculateValueFor("strokeWidth")*2
        when "strokeWidth"
          value || 0
        when "z"
          value || 1
        when "opacity"
          value || 1.0
        else value
    _parseOptions: (@opts) ->
      grid_size = @substrate.grid_size
      
      @css =
        "position": "absolute"
        "border-style": "solid"
        "border-color": "red"
        "background-repeat": "no-repeat"
      @css["background-image"] = "url('#{opts.src}')" if opts.src?
        
      for property, value of @opts
        css_key = css_key_map[property] || property
        @css[css_key] = @_calculateValueFor property
        
      required_properties = ["x", "y", "z", "width", "height", "opacity", "strokeWidth"]
      for property in required_properties
        css_key = css_key_map[property] || property
        unless @css[css_key]?
          @css[css_key] = @_calculateValueFor property

      if @opts.offsetX? || @opts.offsetY?
        @css["background-position"] = @_calculateValueFor("offsetX") + "px " + @_calculateValueFor "offsetY" + "px"
        
    destroy: ->
      @condemned = true

  class HTMLSubstrate.Rectangle extends HTMLSubstrate.Shape
    constructor: (@substrate, opts) ->
      super
      @dom = $ "<div>"
      @_parseOptions opts
      @dom.css @css
      
  class HTMLSubstrate.Image extends HTMLSubstrate.Shape
    constructor: (@substrate, opts) ->
      super
      if typeof opts.src == "string"
        img = new window.Image
        img.src = opts.src
      else if opts.src instanceof Image
        img = opts.src
      else if opts.src instanceof HTMLImageElement
        img = new window.Image
        img.src = opts.src.src
        opts.src = opts.src.src
      else
        throw new Error "Invalid source for Image (was #{opts.src})"
      @dom = $ "<div>"
      @_parseOptions opts
      @dom.css @css
    set: (key, value) ->
      if key == "src"
        @dom.attr "src", value
      else
        super

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
      "user-select": "none"
    
    this.data "substrate", s
    this
)
