
FROM tomsmithokta/nginx-oss-lua

RUN apt-get update
RUN apt-get install -y luarocks

# install prerequisites for lua-resty-openidc
RUN luarocks install lua-cjson
RUN luarocks install lua-resty-http
RUN luarocks install lua-resty-jwt
RUN luarocks install lua-resty-session
RUN luarocks install lua-resty-string

# install lua-resty-openidc
RUN luarocks install lua-resty-openidc

WORKDIR /usr/local/share/lua/5.1/resty

RUN wget https://raw.githubusercontent.com/zmartzone/lua-resty-openidc/master/lib/resty/openidc.lua

WORKDIR /

# COPY conf/nginx.conf /etc/nginx/nginx.conf