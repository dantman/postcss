Declaration  = require('./declaration')
Comment      = require('./comment')
AtRule       = require('./at-rule')
Result       = require('./result')
Rule         = require('./rule')
Root         = require('./root')

# List of functions to process CSS
class PostCSS
  constructor: (@processors = []) ->

  # Add another function to CSS processors
  use: (processor) ->
    @processors.push(processor)
    this

  # Process CSS throw installed processors
  process: (css, opts = { }) ->
    parsed = if css instanceof Root
      css
    else if css instanceof Result
      parsed = css.root
    else
      postcss.parse(css, opts)

    for processor in @processors
      returned = processor(parsed)
      parsed   = returned if returned instanceof Root

    parsed.toResult(opts)

# Framework for CSS postprocessors
#
#   var processor = postcss(function (css) {
#       // Change nodes in css
#   });
#   processor.process(css)
postcss = (processors...) ->
  new PostCSS(processors)

# Compile CSS to nodes
postcss.parse = require('./parse')

# Nodes shortcuts
postcss.comment = (defaults) ->
  new Comment(defaults)
postcss.atRule = (defaults) ->
  new AtRule(defaults)
postcss.decl = (defaults) ->
  new Declaration(defaults)
postcss.rule = (defaults) ->
  new Rule(defaults)
postcss.root = (defaults) ->
  new Root(defaults)

module.exports = postcss
