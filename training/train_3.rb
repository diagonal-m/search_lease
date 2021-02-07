"""
日経電子版より、カテゴリーとページ数を指定し、指定したカテゴリーの指定したページ数分の
記事ジャンルがそれぞれ何件あるのかをカウントするスクリプト
"""
require 'open-uri'  # URLにアクセスするためのライブラリ
require 'nokogiri'  # Nokogiriライブラリ

NIKKEI = "https://www.nikkei.com/"


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


def count_genre_nikkei(category, page)
  """
  指定カテゴリーの指定ページ数のジャンルとその記事数をハッシュ型で返す関数
  """
  news = Hash.new()
  category = {'テクノロジー'=> "technology", 'ビジネス'=> 'business'}[category]

  page.times do |p|
    url = "#{NIKKEI}#{category}/archive/?bn=#{p}1"
    # urlを元にNokogiriオブジェクトを取得
    doc = get_nokogiri(url)
    sleep 1

    article_num = doc.xpath("//*[@id='CONTENTS_MAIN']/div").to_a.length - 2

    (1..article_num).each do |i|
      tags = doc.xpath("//*[@id='CONTENTS_MAIN']/div[#{i}]/div[2]/a")
      tags.each do |tag|
        t = tag.attribute('title').value
        if news.keys.include?(t)  # Array内に値があるかどうか
            news[t] += 1
        else
            news[t] = 1
        end
      end
    end
  end

  return news
  end

if $0 == __FILE__
  puts count_genre_nikkei('テクノロジー', 1)
end