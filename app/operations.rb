"""
seleniumのweb操作に関するメソッドを配置する、モジュール
"""
require 'selenium-webdriver'
require './consts'

module Operations
  MAX_WAIT_TIME = Consts::MAX_WAIT_TIME

  def get_text(driver, xpath)
    """
    xpathを指定した位置からtextを取得する
    """
    element = Selenium::WebDriver::Wait.new(:timeout => MAX_WAIT_TIME).until {
      driver.find_element(:xpath, xpath)
    }  # 指定した要素が出現するまで最大MAX_WAIT_TIME秒待つ
    return element.text
  end

  def click(driver, xpath)
    """
    指定したxpathの要素をクリックする
    """
    element = Selenium::WebDriver::Wait.new(:timeout => MAX_WAIT_TIME).until {
      driver.find_element(:xpath, xpath)
    }  # 指定した要素が出現するまで最大MAX_WAIT_TIME秒待つ
    element.click
  end

  def select_option(driver, text)
    """
    #select要素のoptionを選択する(クリックとは方法が異なる)
    """
    #element = Selenium::WebDriver::Wait.new(:timeout => MAX_WAIT_TIME).until {
    #  Selenium::WebDriver::Support::Select.new(driver.find_element(:xpath, xpath)
    #}
    #element.select_by(:text, text)
  end

  def get_attribute(driver, xpath, attribute = 'src')
    """
    xpathが指定する位置からattributeで指定した属性値を取得する
    """
    element = Selenium::WebDriver::Wait.new(:timeout => MAX_WAIT_TIME).until {
      driver.find_element(:xpath, xpath)
    }  # 指定した要素が出現するまで最大MAX_WAIT_TIME秒待つ
    return element.get_attribute(attribute)
  end
end