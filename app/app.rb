"""
suumo(賃貸)より路線名と駅名を指定し検索を行う。
各種絞込み条件を指定して検索し、賃貸情報をCSVファイルにまとめて出力する(物件名, 住所, 駅情報, 築年数, 賃料, 間取り, 専有面積, 詳細ページurl)
絞込み条件：賃料(下限, 上限), 間取りタイプ
※絞込み条件を指定して検索後はurlを取得できればopen-uriとnokogiriで対応可能
"""
require 'open-uri'  # URLにアクセスするためのライブラリ
require 'nokogiri'  # Nokogiriライブラリ
require 'selenium-webdriver'

require './consts'
require './operations'

include Consts

LINES = [
  'ＪＲ山手線', 'ＪＲ埼京線', '東京メトロ銀座線', '東京メトロ副都心線', '京王井の頭線', '東急東横線', '東急田園都市線', '東京メトロ千代田線', '東京メトロ半蔵門線'
]
STATIONS = [
  '渋谷', '原宿', '代々木', '目黒', '恵比寿', '大崎', '池袋', '表参道', '外苑前', '青山一丁目', '明治神宮前', '北参道', '神泉', '駒場東大前', '代官山', '中目黒', '池尻大橋', '三軒茶屋',
  '代々木公園', '乃木坂', '赤坂', '永田町'
]


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


class SearchLease
  include Operations

  attr_accessor :lines, :stations, :lower, :upper, :madori

  def initialize(lines, stations, lower='', upper='', madori='')
    @lines = lines
    @stations = stations
    @lower = lower
    @upper = upper
    @madori = madori

  end

  def create_driver
    """
    urlにアクセスしてドライバーのオブジェクトを作成する
    """
    options = Selenium::WebDriver::Firefox::Options.new(args: ['-headless'])
    driver = Selenium::WebDriver.for(:firefox, options: options)

    driver.get(BASE_URL)
    sleep 1
    return driver
  end

  def check_lines(driver)
    """
    指定した路線名のチェックリストにチェックを入れて
    「チェックした沿線の駅を絞り込む」をクリックする
    """
    doc = get_nokogiri(driver.current_url)

    line_xpath_hash = Hash.new()  # {"路線名" => "xpath"}
    doc.css('td.searchtable-box').each do |company|
      company.css('li').each do |line|
        line_xpath_hash[line.css('a').text] = line.css('input').to_s[/id="(.*?)"/, 1]
      end
    end

    # 指定した路線のチェックボックにチェックを入れていく
    @lines.each do |line|
      # 10.times do
      [100, 100, 500, 500, 800, 800, 1200, 1200, 1600, 1600, 2000, 2000, 3000, 3000, 5000, 5000, 7000, 7000].each do |sc|
        begin
          puts line
          driver.save_screenshot('line.png')
          click(driver, "//*[@id='#{line_xpath_hash[line]}']")
          break
        rescue => exception
          #driver.execute_script('window.scroll(0,500);')
          driver.execute_script("window.scroll(0,#{sc});")
          sleep 5
        end
      end
    end
    # チェックした沿線の駅を絞り込むを押下
    click(driver, '//*[@id="js-gotoEkiBtn2"]')
    sleep 1
  end

  def check_stations(driver)
    """
    指定した駅名のチェックリストにチェックを入れて
    「この条件で検索する」をクリックする
    """
    doc = get_nokogiri(driver.current_url)

    station_xpath_hash = Hash.new()  # {"駅名" => "xpath"}
    doc.css('td.searchtable-box').each do |line|
      line.css('li').each do |station|
        station_xpath_hash[station.css('span')[0].text] = station.css('input').to_s[/id="(.*?)"/, 1]
      end
    end

    # 指定した駅名のチェックボックスにチェックを入れていく
    @stations.each do |station|
      # 10.times do
      [100, 100, 500, 500, 800, 800, 1200, 1200, 1600, 1600, 2000, 2000, 3000, 3000, 5000, 5000, 7000, 7000].each do |sc|
        begin
          puts station
          driver.save_screenshot('line.png')
          click(driver, "//*[@id='#{station_xpath_hash[station]}']")
          break
        rescue => exception
          # driver.execute_script('window.scroll(0,300);')
          driver.execute_script("window.scroll(0,#{sc});")
          sleep 1
        end
      end
    end

    # この条件で検索するを押下
    click(driver, '//*[@id="js-searchpanel"]/div/div/a')
    sleep 1
  end

  def setting_option(driver)
    """
    賃料(下限金額・上限金額)、間取りタイプのオプションを設定するメソッド
    """
    if @lower
      select_option(driver, '//*[@id="js-conditionbox"]/div[2]/div/dl[2]/dd/dl[1]/dd/div/div[1]/select[1]', @lower)
    end
    if @upper
      select_option(driver, '//*[@id="js-conditionbox"]/div[2]/div/dl[2]/dd/dl[1]/dd/div/div[1]/select[2]', @upper)
    end
    madori_hash = {
    'ワンルーム' => '//*[@id="md0"]', '1K' => '//*[@id="md1"]', '1DK' => '//*[@id="md2"]',
    '1LDK' => '//*[@id="md3"]', '2K' => '//*[@id="md4"]'
    }
    if @madori.length >= 1
      @madori.each do |madori|
        click(driver, madori_hash[madori])
      end
    end

    click(driver, '//*[@id="js-conditionbox"]/div[2]/div/dl[2]/dd/div/div/ul/li[2]/a')

  end

  def search_lease
    """
    このクラスのメイン関数
    """
    # suumoにアクセスしてドライバーオブジェクトを取得する
    driver = create_driver
    # 指定した路線のチェックボックスにチェックを入れて絞り込み検索
    check_lines(driver)
    # 指定した駅名のチェックボックスにチェックを入れて検索
    check_stations(driver)
    # オプションを設定する
    setting_option(driver)
    puts driver.current_url
    driver.quit
  end
end

if $0 == __FILE__
  sl = SearchLease.new(LINES, STATIONS, nil, '9万円', ['ワンルーム', '1K', '1DK', '2K'])
  sl.search_lease
end
