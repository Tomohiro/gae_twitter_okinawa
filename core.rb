require 'rubygems'
require 'sinatra'
require 'appengine-apis/urlfetch'

$KCODE = 'u'

template :layout do
<<-LAYOUT
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="viewport" content="width=320, initial-scale=1.0, maximum-scale=1.0, user-scalable=yes /">
        <meta http-equiv="Content-Script-Type" content="text/javascript" />
        <meta http-equiv="Content-Style-Type" content="text/css" />
        <link rel="stylesheet" type="text/css" href="/styles/reset-min.css" />
        <link rel="stylesheet" type="text/css" href="/styles/fonts-min.css" /> 
        <link rel="stylesheet" type="text/css" href="/styles/design.css" /> 
        <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
        <title>TwitterOkinawa IRC Logs Viewer</title>
    </head>
    <body>
      <%= yield %>
    </body>
</html>
LAYOUT
end

get '/' do
  response = Net::HTTP.start('kotatsumikan.ddo.jp').get('/cgi-bin/twitterokinawa.cgi')
  lines = []
  
  response.body.each do |line|
    case line
    when /^\(.+?\)/
      lines.push notice(line)
    when /^&lt;.+?&gt;/
      lines.push message(line)
    end
  end

  erb %{
  <ul>#{lines.to_s}</ul>
  }
end

def notice(line)
  line[/^\(#(.+?)\) (.+) (.+?$)/]
  nick, content, timestamp = $1, $2, $3

  list_template(:notice, nick, content, timestamp)
end

def message(line)
  line[/^&lt;(.+?)&gt; (.+) (.+$)/]
  nick, content, timestamp = $1, $2, $3

  list_template(:message, nick, content, timestamp)
end

def list_template(type, nick, content, timestamp)
  <<-LIST
<li class="#{type}">
<span class="nick">#{nick}</span>
<span class="content">#{content}</span>
</li>
  LIST
end
