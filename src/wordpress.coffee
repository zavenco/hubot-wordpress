# Description
#   Wordpress search integration for Hubot.
#
# Configuration:
#   HUBOT_WORDPRESS_URL=http://yourwordpressblog.com
#   HUBOT_WORDPRESS_QUERY_URL=http://yourwordpressblog.com/?json=get_search_results&s=
#   HUBOT_WORDPRESS_QUERY_MIN_CHARS=3
#   HUBOT_WORDPRESS_QUERY_MAX_RESULTS=5
#   HUBOT_WORDPRESS_RESPOND_TRIGGER=wp
#   HUBOT_WORDPRESS_HEAR_TRIGGERS="where is;where are"
#   HUBOT_WORDPRESS_SITE_NAME="knowledge base"
#
# Commands:
#   hubot wp <query> - Search wordpress site using query
#   <hear_trigger> <query>? - Search wordpress site using query without asking Hubot directly
#
# Notes:
#   Requires WP JSON API: https://pl.wordpress.org/plugins/json-api/
#
# Author:
#   Arthur Krupa <arthur.krupa@gmail.com>

module.exports = (robot) ->

	#
	# Process environment variables
	#
	
	if process.env.HUBOT_WORDPRESS_URL
		WORDPRESS_URL = process.env.HUBOT_WORDPRESS_URL
	else
		console.log "Please specify HUBOT_WORDPRESS_URL environment variable"
		return
		
	if process.env.HUBOT_WORDPRESS_QUERY_URL
		QUERY_URL = process.env.HUBOT_WORDPRESS_QUERY_URL
	else
		console.log "Please specify HUBOT_WORDPRESS_QUERY_URL environment variable"
		return
	
	QUERY_MIN_CHARS = if process.env.HUBOT_WORDPRESS_QUERY_MIN_CHARS then parseInt(process.env.HUBOT_WORDPRESS_QUERY_MIN_CHARS) else 3;
	QUERY_MAX_RESULTS = if process.env.HUBOT_WORDPRESS_QUERY_MAX_RESULTS then parseInt(process.env.HUBOT_WORDPRESS_QUERY_MAX_RESULTS) else 5;
	
	if process.env.HUBOT_WORDPRESS_RESPOND_TRIGGER
		RESPOND_TRIGGER = process.env.HUBOT_WORDPRESS_RESPOND_TRIGGER
	else
		RESPOND_TRIGGER = "wp"
	
	if process.env.HUBOT_WORDPRESS_HEAR_TRIGGERS
		HEAR_TRIGGERS = HUBOT_WORDPRESS_HEAR_TRIGGERS.split(";")
	else
		HEAR_TRIGGERS = []
		console.log "No hear triggers defined, Hubot will only react to direct messages"
	
	if process.env.HUBOT_WORDPRESS_SITE_NAME
		SITE_NAME = process.env.HUBOT_WORDPRESS_SITE_NAME
	else
		SITE_NAME = "wordpress"
		
	#
	# Perform search
	#	
	
	re = new RegExp("\("+HEAR_TRIGGERS.join("|")+"\) (.*)\\?", "i");
	prevQuery = ""
	prevQueryResults = 0

	getAnswers = (msg, query, reportFailure) ->
		prevQuery = query
		
		# remove English articles from beginning of query
		query = query.replace(/^((the|a|an|my|your|his|her|our|their)\s)/, '');

		if query.length < QUERY_MIN_CHARS
			msg.reply "sorry, but the phrase you're looking for is too short (should be at least #{QUERY_MIN_CHARS} characters)"
			return

		else if query == SITE_NAME
			msg.reply "here: #{WORDPRESS_URL}"
			return

		else
			url = QUERY_URL+query
			robot.http(url)
				.header('Accept', 'application/json')
				.get() (err, res, body) ->

					if err
						console.log "Error connecting to Wordpress JSON API at #{WORDPRESS_URL}:\n#{err}"
						return

					if reportFailure and res.statusCode isnt 200
						msg.send "sorry, but I can't connect to #{WORDPRESS_URL} :("
						return

					else
						data = null
						try
							data = JSON.parse body
						catch error
						 console.log "Ran into an error parsing JSON"
						 return

						prevQueryResults = data.count

						if data.status == "ok" && data.count > 0
							message = "check here:"
							count = 0;
							for post, index in data.posts
								if index < QUERY_MAX_RESULTS
									count = index + 1
									if data.count == 1
										message += "\n#{post.title} (#{post.url})"
									else
										message += "\n#{count}. #{post.title} (#{post.url})"

							msg.send message
						else
							if reportFailure
								msg.send "I have no idea..."


	robot.hear re, (msg) ->
		query = msg.match[2]

		if query is prevQuery and prevQueryResults == 0
			# answer with error messages if question is repeated despite no results
			getAnswers(msg,query,true)
		else if query is prevQuery and prevQueryResults > 0
			# don't answer if question is repeated despite having received results
			return
		else
			# answer without error messages if question isn't repeated
			getAnswers(msg,query,false)

	robot.respond /pomoc (.*)/i, (msg) ->
		# respond with error messages if
		query = msg.match[1]
		getAnswers(msg,query,true)
