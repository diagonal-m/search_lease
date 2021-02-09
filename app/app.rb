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

  attr_accessor :lines, :stations, :lower, :upper, :madori, :url

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
      click(driver, "//*[@id='#{line_xpath_hash[line]}']")
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
      click(driver, "//*[@id='#{station_xpath_hash[station]}']")
    end

    # この条件で検索するを押下
    click(driver, '//*[@id="js-searchpanel"]/div/div/a')
    sleep 1
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
    driver.save_screenshot('a.png')
    driver.quit
  end
end

if $0 == __FILE__
  sl = SearchLease.new(['ＪＲ山手線'], ['原宿'])
  sl.search_lease
end