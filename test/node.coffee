AtRule = require('../lib/at-rule')
Node   = require('../lib/node')
Root   = require('../lib/root')
Rule   = require('../lib/rule')
Raw    = require('../lib/raw')

describe 'Node', ->

  describe '.prop()', ->

    it 'defines virtual property', ->
      class A extends Node
        @prop 'test',
          set: (v) -> @setted = v
          get: -> 1
      a = new A()

      a.test.should.eql(1)

      a.test = 2
      a.setted.should.eql(2)

  describe '.raw()', ->
    class B extends Node
      @raw 'one'

    it 'creates trimmed/raw property', ->
      b = new B()

      (b.one == undefined).should.true

      b.one = new Raw('trim', 'raw')
      b.one.should.eql('trim')
      b._one.toString().should.eql('raw')

      b.one = 'trim1'
      b.one.should.eql('trim1')
      b._one.toString().should.eql('trim1')

    it 'works without magic', ->
      b = new B()

      b.one = '1'
      b.one.should.eql('1')
      b._one.toString().should.eql('1')

  describe 'removeSelf()', ->

    it 'removes node from parent', ->
      rule = new Rule(selector: 'a')
      rule.append(prop: 'color', value: 'black')

      rule.decls[0].removeSelf()
      rule.decls.should.be.empty

  describe 'clone()', ->

    it 'clones nodes', ->
      rule = new Rule(selector: 'a')
      rule.append(prop: 'color', value: '/**/black', before: '')

      clone = rule.clone()
      clone.append(prop: 'display', value: 'none')

      clone.decls[0].parent.should.exactly clone
      rule.decls[0].parent.should.exactly  rule

      rule.toString().should.eql('a {color: /**/black}')
      clone.toString().should.eql('a {color: /**/black;display: none}')

    it 'overrides properties', ->
      clone = ( new Rule(selector: 'a') ).clone(selector: 'b')
      clone.selector.should.eql('b')

  describe 'toJSON()', ->

    it 'cleans parents inside', ->
      rule = new Rule(selector: 'a')
      rule.append(prop: 'color', value: 'b')

      json = rule.toJSON()
      (json.parent == undefined).should.be.true
      (json.decls[0].parent == undefined).should.be.true

      JSON.stringify(rule).should.eql('{"type":"rule","decls":[' +
        '{"type":"decl","prop":"color","_value":"b"}' +
      '],"_selector":"a"}')

  describe 'style()', ->

    it 'uses defaults without parent', ->
      rule = new Rule(selector: 'a')
      rule.style().should.eql { between: ' ', after: '' }

    it 'uses defaults for artificial nodes', ->
      root = new Root()
      root.append(new Rule(selector: 'a'))
      root.first.style().should.eql { between: ' ', after: '' }

    it 'uses nodes style', ->
      root = new Root()
      root.append(new Rule(selector: 'a', between: '', after: ''))
      root.first.style().should.eql { between: '', after: '' }

    it 'clones style from first node', ->
      root = new Root()
      root.append(new Rule(selector: 'a', between: '', after: ' ' ))
      root.append(new Rule(selector: 'b' ))

      root.last.style().should.eql { between: '', after: ' ' }

    it 'uses different style for different node style type', ->
      root = new Root()
      root.append(new AtRule(name: 'page', rules: []))
      root.append(new AtRule(name: 'import'))

      root.first.style().should.eql { between: ' ', after: '' }
      root.last.style().should.eql  { between: '' }
