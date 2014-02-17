require 'rubygems'
require 'nokogiri'
require 'restclient'
require 'oauth'
require 'open-uri'

$links
Key=[]
Secret=[]
Token=[]
TokenSecret=[]

def prepare_access_token(key,secret,oauth_token, oauth_token_secret)
    consumer = OAuth::Consumer.new(key, secret,
                                   { :site => "http://api.twitter.com",
                                   :scheme => :header
                                   })
                                   # now create the access token object from passed values
                                   token_hash = { :oauth_token => oauth_token,
                                       :oauth_token_secret => oauth_token_secret
                                   }
                                   access_token = OAuth::AccessToken.from_hash(consumer, token_hash )
                                   return access_token
end

def extractWiki
  page = Nokogiri::HTML(RestClient.get("http://en.wikipedia.org/wiki/List_of_American_film_actresses"))   
  $links = page.css("div[class = 'div-col columns column-width']").css('a')
end

def verifyTwitter
    fname = "test_final.txt"
    myfile = File.open(fname, "w")
    for i in 0 .. $links.length-1
        puts i
        str = '"' + $links[i].text + '"'
        access_token = prepare_access_token(Key[i%Key.length],Secret[i%Secret.length],Token[i%Token.length],TokenSecret[i%TokenSecret.length])
        response = access_token.request(:get,"https://api.twitter.com/1.1/users/search.json?q="+CGI::escape(str)+"&count=1")
        users=JSON.parse(response.body)
        myfile.print($links[i].text)
        myfile.print ','
        if users.length > 0
            if users[0]["verified"]
                myfile.print("https://twitter.com/"+users[0]["screen_name"])
            end
        end
        myfile.puts
    end
    myfile.close
end


extractWiki
verifyTwitter



