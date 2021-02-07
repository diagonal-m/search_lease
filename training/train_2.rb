"""
日経電子版のホームページから、カテゴリー名を指定することで、そのカテゴリーの記事のタイトルとリンクを取得して表示するスクリプト
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


def get_nikkei_news(category)
  """
  記事カテゴリーを指定して日経電子版のホームページをクローリング
  @param category: カテゴリー名シンボル
  @return: 記事タイトルがキー、リンクが値のハッシュ
  """
  category = {'テクノロジー'=> "technology", 'ビジネス'=> 'business'}[category]
  base_html = "https://www.nikkei.com/#{category}/archive/"
  # urlを元にNokogiriオブジェクトを取得
  doc = get_nokogiri(base_html)

  # 記事の数を取得
  article_num = doc.xpath('//*[@id="CONTENTS_MAIN"]/div').to_a.length - 2
  nikkei_hash = Hash.new()

  (1..article_num).each do |i|
    title_xpath = "//*[@id='CONTENTS_MAIN']/div[#{i}]/h3/a/span"  # 記事タイトルのベースxpath
    link_xpath = "//*[@id='CONTENTS_MAIN']/div[#{i}]/h3/a"  # 記事リンクのベースxpath
    nikkei_hash[doc.xpath(title_xpath).text] = NIKKEI + doc.xpath(link_xpath).attribute('href').value
  end

  return nikkei_hash

  end

if $0 == __FILE__
  get_nikkei_news('テクノロジー').each do |k, v|
    puts "#{k}: #{v}"
  end
end