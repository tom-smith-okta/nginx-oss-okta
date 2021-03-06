# NGINX with Okta for authentication #

## Overview ##

With the Okta + NGINX OIDC integration, NGINX can force users to authenticate vs. Okta before passing on a request to an upstream resource.

NGINX will look for an id token in every request, and if it does not find a valid id token, it will redirect the user to authenticate against Okta and get an id token.

This github repo contains two items:

1. An example nginx.conf file that you can use with your own NGINX server. See the instructions below for the values that you need to update, and how to get them.
2. An example Dockerfile that builds a complete NGINX server with the nginx.conf file. See the instructions below for how to build.

There is also a [pre-built docker image on dockerhub](https://hub.docker.com/r/tomsmithokta/nginx-oss-okta).

This repo and docker image are built on the OIDC capabilities of [lua-resty-openidc](https://github.com/zmartzone/lua-resty-openidc), where you can find fuller documentation about the OIDC options.

When a user successfully authenticates, NGINX will receive an id token from Okta. NGINX will parse the id token and add some relevant user attributes as headers to the request it passes to the downstream application.

By default, this setup proxies a public web application: [http://okta-headers.herokuapp.com/](http://okta-headers.herokuapp.com/). The app just displays headers, so you can visit it now to see what it looks like without authentication and proxy by NGINX. After you authenticate with Okta, the app will display the additional headers it has parsed from the Okta id token.

## Setup and installation

### Okta setup
To sign up for a free-forever Okta tenant, visit [developer.okta.com](https://developer.okta.com/).

To set up your OIDC client in Okta, follow the quickstart guide [here](https://developer.okta.com/quickstart/#/okta-sign-in-page/nodejs/express) and follow the instructions for "Okta Sign-In Page Quickstart".

You need to add the redirect_uri (http://localhost:8126/redirect_uri) to your OIDC client, and your hostname (http://localhost:8126) to the Trusted Origins for your Okta tenant. I am just using 8126 as an example port; you can use any port you wish.

The hostname of the redirect_uri should be the hostname of your NGINX server.

Assign the OIDC app to Everyone for now, and add a user to your Okta tenant so you can test authentication.

### NGINX setup

A sample nginx.conf file is included in this repo. These are some of the essential parameters that need to be updated to enable authentication vs. Okta. Update these values with values from your own Okta tenant:

```
discovery = "https://partnerpoc.oktapreview.com/.well-known/openid-configuration"

client_id = "0oagfbbn3gHhSxJWL0h7"

client_secret = "{{my_client_secret}}"
```

There are of course many other parameters that you can adjust. In a production environment you should certainly change the value for 

```
ssl_verify = "no"
```

After you have updated your `nginx.conf` file with the settings from your Okta tenant, you can run the NGINX container.

### Run the Docker container
Run the container:

```
docker run -d -p 8126:80 -v /host/path/nginx.conf:/etc/nginx/nginx.conf tomsmithokta/nginx-oss-okta nginx -g 'daemon off;'
```

Change the path `/host/path/nginx.conf` to the appropriate path on your local filesystem. Note: you may need to update your Docker settings to allow access to the directory on your local filesystem.

At this point you can put the following address in your browser:

```
http://localhost:8126
```

You will be redirected to Okta to authenticate.

### Authentication
When you authenticate, NGINX will parse the id token it receives from Okta, create some new headers, and load the upstream site, which just displays headers.

### Handy commands
If you want to launch the docker container in command-line mode, use this command:

```
docker run -it tomsmithokta/nginx-oss-okta /bin/bash
```

If you want to launch the docker container as a web server and see the logs, use this command:

```
docker run -d -p 8126:80 \
	-v /host/path/nginx.conf:/etc/nginx/nginx.conf \
	-v /host/path/logs:/var/log/nginx \
	tomsmithokta/nginx-oss-okta nginx -g 'daemon off;'
```

Where `/host/path/logs` is a valid path on your local filesystem that Docker has access to.
