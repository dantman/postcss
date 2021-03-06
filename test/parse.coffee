Root  = require('../lib/root')
parse = require('../lib/parse')

fs   = require('fs')
read = (file) -> fs.readFileSync(__dirname + '/cases/parse/' + file)

describe 'postcss.parse()', ->

  it 'works with file reads', ->
    file = fs.readFileSync(__dirname + '/cases/parse/atrule-empty.css')
    parse(file).should.be.instanceOf(Root)

  describe 'empty file', ->

    it 'parses UTF-8 BOM', ->
      parse('\uFEFF@host { a {\f} }')

    it 'parses empty file', ->
      parse('').should.eql { type: 'root', rules: [], after: '' }

    it 'parses spaces', ->
      parse(" \n ").should.eql { type: 'root', rules: [], after: " \n " }

  fs.readdirSync(__dirname + '/cases/parse/').forEach (file) ->
    return unless file.match(/\.css$/)

    it "parses #{ file }", ->
      css  = parse(read(file))
      fs.writeFileSync(__dirname + '/cases/parse/' + file.replace(/\.css$/, '.json'), JSON.stringify(css, null, 4) + "\n")
      json = read(file.replace(/\.css$/, '.json')).toString().trim()
      JSON.stringify(css, null, 4).should.eql(json)

  it 'saves source file', ->
    css = parse('a {}', from: 'a.css')
    css.rules[0].source.file.should.eql('a.css')

  it 'sets parent node', ->
    css = parse(read('atrule-rules.css'))

    support   = css.rules[0]
    keyframes = support.rules[0]
    from      = keyframes.rules[0]
    decl      = from.decls[0]

    decl.parent.should.exactly(from)
    from.parent.should.exactly(keyframes)
    keyframes.parent.should.exactly(support)
    support.parent.should.exactly(css)

  describe 'errors', ->

    it 'throws on unclosed blocks', ->
      ( -> parse("\na {\n") ).should.throw(/Unclosed block at line 2:1/)

    it 'throws on unclosed blocks', ->
      ( -> parse("a {{}}") ).should.throw(/Unexpected \{/)

    it 'throws on property without value', ->
      ( -> parse("a { b;}") ).should.throw(/Missing property value/)
      ( -> parse("a { b }") ).should.throw(/Missing property value/)

    it 'throws on unclosed comment', ->
      ( -> parse('\n/*\n\n ') ).should.throw(/Unclosed comment at line 2:1/)

    it 'throws on unclosed quote', ->
      ( -> parse('\n"\n\n ') ).should.throw(/Unclosed quote at line 2:1/)

    it 'throws on nameless at-rule', ->
      ( -> parse('@') ).should.throw(/At-rule without name/)

    it 'throw on rules in declarations at-rule', ->
      ( -> parse('@page { a { } }') ).should.throw(/Unexpected \{/)

    it 'adds properties to error', ->
      error = null
      try
        parse('a {')
      catch e
        error = e

      error.line.should   == 1
      error.column.should == 1
      error.source.should == 'a {'
