# hubot-wordpress

Wordpress search integration for Hubot.

See [`src/wordpress.coffee`](src/wordpress.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-wordpress --save`

Then add **hubot-wordpress** to your `external-scripts.json`:

```json
[
  "hubot-wordpress"
]
```

## Requirements

[WP JSON API](https://pl.wordpress.org/plugins/json-api/) plugin has to be installed on your Wordpress site.

## Configuration

###Required environment variables

- `HUBOT_WORDPRESS_URL` - base URL to your wordpress site (e.g. `http://yourwordpressblog`)
- `HUBOT_WORDPRESS_QUERY_URL` - JSON endpoint URL to the wordpress search query (e.g. `http://yourwordpressblog.com/?json=get_search_results&s=`). You can adjust your search parameters with this (e.g. filter post types).

###Required environment variables

- `HUBOT_WORDPRESS_QUERY_MIN_CHARS` - minimum length of search query (default: 3)
- `HUBOT_WORDPRESS_QUERY_MAX_RESULTS` - maximum number of return search results (default: 5)
- `HUBOT_WORDPRESS_RESPOND_TRIGGER` - the phrase that will trigger a search when addressing Hubot directly (default: "wp")
- `HUBOT_WORDPRESS_HEAR_TRIGGERS` - an optional list of phrases Hubot should react to without being directly called (semicolon-separated, e.g. "where is;where are"). For example, writing "where is our knowledge base?" will trigger a search for "knowledge base" (English articles and possesives at the beginning are trimmed). NOTE: a question mark is required at the end.
- `HUBOT_WORDPRESS_SITE_NAME` - base URL to your wordpress site (default: "wordpress")

## Sample Interaction

```
user1>> hubot wp <search_query>
hubot>> check here:
        Post Title (http://yourwordpressblog/link-to-post)
```

## NPM Module

https://www.npmjs.com/package/hubot-wordpress

## License

This script is licensed under the terms of the MIT license.
