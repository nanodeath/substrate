jQuery(($) ->
  css_key_map =
    "x": "left"
    "y": "top"
    
  class Shape
    constructor: ->
      @painted = false
    set: (key, value) ->
      css_key = css_key_map[key]
      
      value = switch css_key
        when "left", "top" then value * @substrate.grid_size
        else value
      
      @css[css_key] = value
      @dirty = true
      @paint() if @substrate.autopaint
    paint: ->
      if @dirty
        @dirty = false
        @dom.css @css
      unless @painted
        @substrate._appendDom @dom
    _parseOptions: (opts) ->
      grid_size = @substrate.grid_size
      strokeWidth = opts.strokeWidth || 0
      opacity = opts.opacity || 1.0
      z_index = opts.z || 1
      @css =
        "position": "absolute"
        "left": opts.x * grid_size
        "top": opts.y * grid_size
        "width": opts.width * grid_size - strokeWidth*2
        "height": opts.height * grid_size - strokeWidth*2
        "opacity": opacity
        "background-color": opts.fillColor
        "border-style": "solid"
        "border-color": "red"
        "border-width": strokeWidth
        "z-index": z_index

  class Rectangle extends Shape
    constructor: (@substrate, opts) ->
      super
      @dom = $ "<div>"
      @_parseOptions opts
      @dom.css @css
      @dirty = false
      
  class Image extends Shape
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
      delete opts.src
      @dom = $ "<img>"
      @dom.attr "src", @img.src
      @_parseOptions opts
      @dom.css @css
      @dirty = false

  class Substrate
    constructor: (@dom, opts) ->
      @autopaint = if opts.autopaint? then opts.autopaint else true
      @grid_size = if opts.grid_size? then opts.grid_size else 1

    drawRectangle: (opts={}) ->
      r = new Rectangle this, opts
      if @autopaint
        r.painted = true
        @_appendDom r.dom
      r
      
    drawImage: (opts={}) ->
      i = new Image this, opts
      if @autopaint
        i.painted = true
        @_appendDom i.dom
      i

    _appendDom: (dom) ->
      @dom.append dom
  
  $.fn.substrate = (opts={}) ->
    this.css "position", "relative"
    s = new Substrate this, opts
    this.data "substrate", s
    this
)
