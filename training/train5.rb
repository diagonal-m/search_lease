require 'open-uri'  # URLにアクセスするためのライブラリ
require 'nokogiri'  # Nokogiriライブラリ


URL = 'https://suumo.jp/jj/chintai/kensaku/FR301FB004/?ar=030&bs=040&ra=013&rn=0005&srch_navi=1'


def get_nokogiri(url)
  """
  urlにアクセスして、nokogiri型を返す
  @param url: url文字列
  """
  charset = nil
  html = open(url) do |f|
    charset = f.charset  # 文字種別を取得
    f.read  # htmlを読み込んで変数htmlに渡す
  end

  # htmlをパース(解析)してオブジェクトを生成
  doc = Nokogiri::HTML.parse(html, nil, charset)

  return doc
  end

doc = get_nokogiri(URL)
# puts doc.css('th')
# puts doc.css('table')[0].css('li')
puts doc.css('td.searchtable-box')[0].css('li')[0].css('input')

line_xpath_hash = Hash.new()
doc.css('td.searchtable-box').each do |company|
  company.css('li').each do |line|
    line_xpath_hash[line.css('span')[0].text] = line.css('input').to_s[/id="(.*?)"/, 1]
  end
end

line_xpath_hash.each do |k, v|
  puts "#{k}: #{v}"
end