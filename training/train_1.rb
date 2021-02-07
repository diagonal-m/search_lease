"""
Yahoo!ニュースからトップページの記事タイトルを取得する
"""
require 'open-uri'  # URLにアクセスするためのライブラリ
require 'nokogiri'  # Nokogiriライブラリ

BASE_URL = 'https://news.yahoo.co.jp/'

charset = nil
html = open(BASE_URL) do |f|
  charset = f.charset  # 文字種別を取得
  f.read  # htmlを読み込んで変数htmlに渡す
end

# htmlをパース(解析)してオブジェクトを生成
doc = Nokogiri::HTML.parse(html, nil, charset)

# arrayに変換し長さを取得 -> タイトル数
title_num = doc.xpath('//*[@id="uamods-topics"]/div/div/div/ul/li').to_a.length

# タイトル名称取得
titles = Array.new()
puts titles
title_num.times do |i|
  titles.push(doc.xpath("//*[@id='uamods-topics']/div/div/div/ul/li[#{i + 1}]/a/text()"))
end

titles.each do |title|
  puts title
end
