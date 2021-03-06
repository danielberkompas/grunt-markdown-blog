Layout = null
SandboxedModule = require('sandboxed-module')

describe "Layout", ->
  Given -> @templatePath = "somePath.us"
  Given -> @templateContents = "someFileContents"
  Given -> @extendedContext = jasmine.createSpy("extendedContext")
  Given -> @layout = jasmine.createSpy("layout").andReturn(@html = jasmine.createSpy("html"))
  Given -> Layout = SandboxedModule.require '../lib/layout',
    requires:
      'grunt': @grunt =
        file:
          read: jasmine.createSpy("grunt.file.read").andReturn(@templateContents)
      'underscore': @_ = do =>
        _ = jasmine.createSpy("underscore")
        _.mixin = ->
        _.extend = jasmine.createSpy("extend").andReturn(@extendedContext)
        _.template = jasmine.createSpy("template").andReturn(@layout)
        _.andReturn(_)

  When -> @subject = new Layout @templatePath, @context

  describe "#constructor", ->
    describe "reads template file", ->
      Then -> expect(@grunt.file.read).toHaveBeenCalledWith @templatePath

    describe "parses file as underscore template", ->
      Then -> expect(@_).toHaveBeenCalledWith @templateContents
      Then -> expect(@_.template).toHaveBeenCalled()


  describe "#htmlFor", ->
    When -> @resultHtml = @subject.htmlFor(@specificContext)

    describe "merges contexts", ->
      Given -> @context = jasmine.createSpy("context")
      Given -> @specificContext = jasmine.createSpy("specificContext")
      Then -> expect(@_).toHaveBeenCalledWith {}
      Then -> expect(@_.extend).toHaveBeenCalledWith @context, @specificContext

    describe "hydrates template with context", ->
      Then -> expect(@layout).toHaveBeenCalledWith @extendedContext
      Then -> @resultHtml == @html
