  #!/usr/bin/env ruby
require 'rubygems'
require 'nokogiri'
require 'open-uri'

BASE_WIKITREE_URL = "http://www.wikitree.com"
SEARCH_TEXT = "Puerto Rico Unconnected Profiles"
@category = URI.escape("Category:" + SEARCH_TEXT)
@next_page = ""

def crawl_category(category)
  category_url = "#{BASE_WIKITREE_URL}/index.php?title=#{category}"

  page = Nokogiri::HTML(open(category_url))
  items = page.css('div.sixteen.columns div#mw-pages table tr td ul li')

  items[1..-2].each do |item|
    hrefs = item.css("a").map{ |a|
      a['href'] if a['href'].match("/wiki/")
    }.compact.uniq

    hrefs.each do |href|
      # puts href
      @remote_url = BASE_WIKITREE_URL + href
      begin
        wiki_content = open(@remote_url).read
      rescue Exception=>e
        puts "Error: #{e}"
        sleep 5
      else
        if wiki_content.include? SEARCH_TEXT
          if wiki_content.include? "Kevin Bacon"
            puts @remote_url
          end
        end
      ensure
        sleep 1.0 + rand
        @next_page = '&from=' + href.tr('/wiki/', '')
      end
    end # done hrefs.each
  end # done: items.each
  puts "Last profile inspected: " + @remote_url
end

if !(@start_from == @next_page)
    @start_from = @next_page
    crawl_category(@category + @start_from)
end
