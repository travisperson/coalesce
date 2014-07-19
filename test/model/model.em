`import ModelSet from 'epf/collections/model_set'`

describe 'Model', ->

  App = null
  session = null

  beforeEach ->
    App = Ember.Namespace.create()
    class App.User extends Ep.Model
      name: Ep.attr('string')
      raw: Ep.attr()
      createdAt: Ep.attr('date')
    @container = new Ember.Container()
    Ep.setupContainer(@container)
    @container.register 'model:user', App.User
    session = @container.lookup('session:main')

    Ep.__container__ = @container

  afterEach ->
    delete Ep.__container__


  describe '.isDirty', ->      

    it 'returns false when detached', ->
      expect(App.User.create().isDirty).to.be.false

    it 'returns true when dirty', ->
      user = null
      Object.defineProperty session, 'dirtyModels',
        get: -> ModelSet.fromArray([user])

      user = App.User.create()
      user.session = session
      expect(user.isDirty).to.be.true

    it 'returns false when untouched', ->
      user = null
      Object.defineProperty session, 'dirtyModels',
        get: -> new ModelSet

      user = App.User.create()
      user.session = session
      expect(user.isDirty).to.be.false

    xit 'is observable', ->
      user = session.merge App.User.create
        id: '1'
        name: 'Wes'

      expect(user.isDirty).to.be.false
      observerHit = false

      Ember.addObserver user, 'isDirty', ->
        expect(user.isDirty).to.be.true
        observerHit = true

      user.name = 'Brogrammer'
      expect(user.isDirty).to.be.true
      expect(observerHit).to.be.true


  it 'can use .find', ->
    session.find = (type, id) ->
      expect(type).to.eq(App.User)
      expect(id).to.eq(1)
      Ember.RSVP.resolve(type.create(id: id.toString()))

    App.User.find(1).then (user) ->
      expect(user.id).to.eq("1")

  describe 'typeKey class var', ->
    it 'works with global Ember', ->
      class App.SomeThing extends Ep.Model
      typeKey = Ember.get(App.SomeThing, 'typeKey')
      expect(typeKey).to.eq('some_thing')

    it 'works with modular Ember', ->
      class SomeThing extends Ep.Model
      SomeThing._toString = "my-app@model:some-thing:"
      typeKey = Ember.get(SomeThing, 'typeKey')
      expect(typeKey).to.eq('some_thing')

  describe '.diff', ->

    it 'detects differences in complex object attributes', ->
      left = App.User.create
        raw: {test: 'a'}
      right = App.User.create
        raw: {test: 'b'}

      expect(left.diff(right)).to.eql([ { type: 'attr', name: 'raw' } ])

    it 'detects no difference in complex object attributes', ->
      left = App.User.create
        raw: {test: 'a'}
      right = App.User.create
        raw: {test: 'a'}

      expect(left.diff(right)).to.eql([])


  describe '.copy', ->
  
    it 'copies dates', ->
      
      date = new Date(2014, 7, 22)
      user = App.User.create
        createdAt: date
      copy = user.copy()
      expect(user.createdAt.getTime()).to.eq(copy.createdAt.getTime())
        

    it 'deep copies complex object attributes', ->

      user = App.User.create
        raw: {test: {value: 'a'}}

      copy = user.copy()

      expect(user).to.not.eq(copy)
      expect(user.raw).to.not.eq(copy.raw)
      expect(user.raw.test).to.not.eq(copy.raw.test)
      expect(user.raw).to.eql(copy.raw)

    it 'deep copies array attributes', ->

      user = App.User.create
        raw: ['a', 'b', 'c']

      copy = user.copy()

      expect(user).to.not.eq(copy)
      expect(user.raw).to.not.eq(copy.raw)
      expect(user.raw).to.eql(copy.raw)