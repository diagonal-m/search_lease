FROM ruby:2.6

# デフォルトの locale `C` を `C.UTF-8` に変更する
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# タイムゾーンを日本時間に変更
ENV TZ Asia/Tokyo

# /tmpにコピー
COPY . /tmp

# 相対パスの基準ディレクトリ
WORKDIR /tmp

RUN apt-get update && apt-get install -y firefox-esr vim

RUN wget https://github.com/mozilla/geckodriver/releases/download/v0.26.0/geckodriver-v0.26.0-linux64.tar.gz
RUN tar xf geckodriver-v0.26.0-linux64.tar.gz && mv geckodriver /usr/local/bin && chmod 755 /usr/local/bin/geckodriver && rm -f geckodriver-v0.26.0-linux64.tar.gz

RUN gem install nokogiri selenium-webdriver
