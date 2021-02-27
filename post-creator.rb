#! /usr/bin/ruby

require 'io/console'
require 'open-uri'
 
def yesno
  case $stdin.getch
    when "y" then true
    when "Y" then true
    when "n" then false
    when "N" then false
    else raise "Invalid character."
  end
end


## Gloal Variables
$youtubeString = %q(
<div class="video-container">
    <iframe
      width="560"
      height="315"
      src="https://www.youtube.com/embed/{{ page.youtube-url }}"
      srcdoc="<style>*{padding:0;margin:0;overflow:hidden}html,body{height:100%}img,span{position:absolute;width:100%;top:0;bottom:0;margin:auto}span{height:1.5em;text-align:center;font:48px/1.5 sans-serif;color:white;text-shadow:0 0 0.5em black}</style><a 
             href=https://www.youtube.com/embed/{{ page.youtube-url }}?autoplay=1><img src=https://img.youtube.com/vi/{{ page.youtube-url }}/hqdefault.jpg alt='Video The Dark Knight Rises: What Went Wrong? – Wisecrack Edition'><span>▶</span></a>"
      frameborder="0"
      allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
      allowfullscreen
  ></iframe>
</div>
)

$listTag = %q(<li class="video-list">)
$titleTag = %q(<p class="list-title">FILLER</p>)
$listSubtitleTag = %q(<p class="list-subtitle">FILLER</p>)

$playlistRegexStartString = "videoId\":"

$youtubeLink = "https://www.youtube.com/playlist?app=desktop&list=PLhmmqlNElV690CdwkegnFP7m0cL1jB6Lk"



def createHtmlFromId(youtubeID) 
    youtubeHtml = $youtubeString
    return youtubeHtml.gsub("{{ page.youtube-url }}", youtubeID)
end



def parsePlaylist(url)
    source = open(url).read
    youtubeIDs = source.scan /(?<=videoId\":\")(.*?)\"/

    return youtubeIDs.uniq
end



def parseNameAndTitle(youtubeID)
    url = "https://www.youtube.com/watch?v=" + youtubeID
    source = open(url).read

    title = source.match /(?<=<meta name="title" content=")(.*?\")/
    return title[0].sub("\"", "")
end


def createPost(youtubeIDs)
    htmlSnippets = []

    for youtubeID in youtubeIDs
        subtitle = $listSubtitleTag.sub("FILLER", parseNameAndTitle(youtubeID[0])) 
        snippet = $listTag + "\n" + $titleTag + "\n" + subtitle + "\n" + createHtmlFromId(youtubeID[0]) + "\n" + "</li>"

        htmlSnippets.append(snippet)
    end

    return htmlSnippets.join("\n\n\n") 
end



def createFile(content, name)
  name = name.sub(" ", "-")
  time = Time.new
  date = time.strftime("%Y-%m-%d")

  file = File.new(date + "-" + name + ".txt", "w")
  if file
    file.syswrite(content)
  else
    puts "Could not create or write to file."
  end
end



def main
    # puts "Do you want to parse playlist? y/n"
    # isPlaylist = yesno
    
    # if !isPlaylist
    #     puts "Enter youtube-id"
    #     youtubeID = gets.strip
    #     puts createHtmlFromId(youtubeID)
    #     return
    # end
    
    # puts "Enter playlist link"
    # playlistLink = gets.strip

    # puts "Enter post title"
    # title = gets
    title = "test"
    
    # puts "Enter author"
    # author = gets

    content = createPost(parsePlaylist($youtubeLink))
    createFile(content, title)
end 

main()

# https://www.youtube.com/playlist?app=desktop&list=PLhmmqlNElV690CdwkegnFP7m0cL1jB6Lk