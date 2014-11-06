# Generated on 2013-08-07 using generator-webapp 0.2.7
LIVERELOAD_PORT = 34794
CONNECT_PORT = 8000
HEADER_CONFIG_FILE = 'config/headers.json'

lrSnippet = require('connect-livereload')({port: LIVERELOAD_PORT})
gateway_rw = require 'gateway-rewrite'
gateway = require 'gateway'
fs = require 'fs'

localconfig = require './config/local.json'

mountFolder = (connect, dir)->
	return connect.static(require('path').resolve(dir))

corsMiddleware = (req, res, next)->
	res.setHeader 'Access-Control-Allow-Origin', '*'
	res.setHeader 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
	res.setHeader 'Access-Control-Allow-Headers', 'Content-Type'
	next()

headerMiddleware = (req, res, next)->
	headers = JSON.parse fs.readFileSync(HEADER_CONFIG_FILE) # don't 'require' file to reload it on each request.

	for key, value of headers
		req.headers[key] = value
	next()

rwGateway =  (dir)->
	gateway_rw require('path').resolve(dir),
		ignoreExistingFiles: true
		rules: [
			rule: '^/.*$'
			cgi:  localconfig.phpCgiPath
			to:   '/index.php'
			query: 'q={{URI}}&{{QUERY}}'
		]

gatewayMiddleware = (dir)->
	gateway dir,
		'.php': localconfig.phpCgiPath

# # Globbing
# for performance reasons we're only matching one level down:
# 'test/spec/{,*/}*.js'
# use this if you want to recursively match all subfolders:
# 'test/spec/**/*.js'

module.exports = (grunt)->
	# show elapsed time at the end
	require('time-grunt')(grunt)
	# load all grunt tasks
	require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks)

	# configurable paths
	CONFIG =
		public: 'htdocs'

	grunt.initConfig
		config: CONFIG
		watch:
			livereload:
				options:
					livereload: LIVERELOAD_PORT
				files: [
					'<%= config.public %>/**/*.php'
				]

		connect:
			options:
				port: CONNECT_PORT
				# change this to '0.0.0.0' to access the server from outside
				#hostname: 'localhost'
				hostname: '0.0.0.0'

			livereload:
				options:
					middleware: (connect)->
						[
							headerMiddleware
							corsMiddleware
							lrSnippet
							# rwGateway(CONFIG.public)
							gatewayMiddleware CONFIG.public
							mountFolder(connect, CONFIG.public)
						]

		open:
			server:
				path: 'http://localhost:<%= connect.options.port %>'

		symlink:
			config:
				dest: 'htdocs/conf/dokuwiki.php'
				relativeSrc: '../../config/dokuwiki.php'

	grunt.registerTask 'serve', [
		'symlink:config'
		'connect:livereload'
		'open'
		'watch'
	]
