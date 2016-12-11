{parse, stringify} = JSON
{writeFileSync} = require 'fs'
{sync} = require 'glob'

module.exports =
	package: require './package.json'
	#config: -> atom.config.get 'modular-snippets'

	project: atom.project.getPaths()[0]
	#editor: -> atom.workspace.getActiveTextEditor()
	#pattern: 'snippets/**'
	#backup: 'sync-settings.extraFiles'

	subs: null
	activate: ->
		require 'require-cson'
		{CompositeDisposable} = require 'atom' #Disposable
		@subs = new CompositeDisposable

#-------------------------------------------------------------------------------
		@reload()

		# TODO break Gist sync into sync-snippets-gists package?
		#if atom.config.get 'modular-snippets.syncSnippets'
			#

		# Backup snippets with sync-settings if installed
		#if atom.packages.isPackageLoaded 'sync-settings'
			#atom.config.pushAtKeyPath 'sync-settings.syncSnippets', false
			#unless @pattern in atom.config.get @backup
				#atom.config.pushAtKeyPath @backup, @pattern

#-------------------------------------------------------------------------------

		@subs.add atom.commands.add 'atom-workspace', #body
			'modular-snippets:open': =>
				@open sync "#{atom.configDirPath}/snippets{,.cson}"
			#application:open-your-snippets
			'modular-snippets:reload': => @reload() #@cache = false

		# Automatically reload modified snippets
		@subs.add atom.workspace.observeTextEditors (editor) =>
			path = editor.getPath()
			tab = editor.getTitle()
			folder = /// (#{atom.configDirPath}|#{@project})/snippets(/.+)+\.cson ///
			editor.onDidSave =>
				match = @package.config?.local?.filter (file) -> ///#{tab}///.test file

				@reload() if path.startsWith(@project) and match[0]? or folder.test path

#-------------------------------------------------------------------------------

	# API
	provide: ->
		load: (snippets) =>
			@cache = true
			@read snippets

	reload: ->
		if @cache #or @config()?.cacheSnippets
			@scopes ?= []
			@snippets ?= {}
		else
			@scopes = []
			@snippets = {}

		@read "#{atom.configDirPath}/snippets" #@pattern

		# Project local snippets
		try delete require.cache[require.resolve "#{@project}/package.json"]
		local = =>
			for item in @package.config?.local #when
				item = sync "#{@project}/#{item}", {dot: true} #cwd: @project
				try if @file = item[0]
					{snippets} = read = require @file
					return snippets if snippets
					return read for key of read when /\.(source|text)/.test key
				catch
					return @file #unless /\.[cj]son$/.test @file
		@read local() # snippets

	read: (snippets) ->
		if typeof snippets is 'object'
			@load snippets
		else if snippets
			snippets = "#{snippets}/**/*.cson" unless /\.[cj]son$/.test snippets

			for @file in sync snippets
				try {snippets} = read = require @file
				@load snippets ? read

	valid: (snippet) ->
		if parse stringify snippet
			true if snippet.prefix? and snippet.body?

	load: (snippets = {}) ->
		for scope in Object.keys snippets
			scopes = {}
			@snippets[scope] = scopes[scope] = {}
			{resolve} = require 'path'
			prefix = atom.project.relativizePath @file#.split('/').pop()
			prefix = prefix[1].replace atom.configDirPath,'ATOM_HOME'
			#uid = -> Math.random().toString(16).substr 2,4
			for name of snippets[scope]
				snippet = snippets[scope][name]
				if @valid snippet
					snippet.rightLabelHTML ?= name
					scopes[scope]["#{prefix}.#{name}"] = snippet #[uid()]
					@scopes?.push scopes

		for @scope in @scopes
			scope = Object.keys @scope
			snippets = Object.keys @scope[scope]

			for snippet in snippets
				@snippets[scope][snippet] = @scope[scope][snippet]

		writeFileSync "#{atom.configDirPath}/snippets.json", stringify @snippets
			#stringify @snippets#, null, @editor().getTabText()

	open: (snippets) -> # folder
		atom.open pathsToOpen: snippets

#-------------------------------------------------------------------------------
	deactivate: -> @subs.dispose()
