"""
selenium練習用スクリプト
"""
require 'open-uri'  # URLにアクセスするためのライブラリ
require 'nokogiri'  # Nokogiriライブラリ
require 'selenium-webdriver'

MAX_WAIT_TIME = 5


def get_text(driver, xpath)
  """
  xpathを指定した位置からtextを取得する
  """
  element = Selenium::WebDriver::Wait.new(:timeout => MAX_WAIT_TIME).until {
    driver.find_element(:xpath, xpath)
  }
    # 指定した要素が「見える」まで最大MAX_MAX_WAIT_TIME秒待つ
  return element.text
  end

def create_driver(url)
  """
  urlにアクセスしてドライバーオブジェクトを作成する
  """
  options = Selenium::WebDriver::Firefox::Options.new(args: ['-headless'])
  driver = Selenium::WebDriver.for(:firefox, options: options)

  driver.get(url)

  return driver
  end

if $0 == __FILE__
  driver = create_driver('https://www.yahoo.co.jp/')
  puts get_text(driver, '//*[@id="TopLink"]/ul/li[1]/a/span/span')
  driver.quit
end
