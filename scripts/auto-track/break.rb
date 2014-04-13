#!/usr/bin/ruby -w

# Split a mbox file into $year-$month files
# Copyright (C) 2008 Joerg Jaspert 
# BSD style license, on Debian see /usr/share/common-licenses/BSD
require "rubygems"
require 'pathname'
require 'rmail'

count = 0

File.open(Pathname.new(ARGV[0]), 'r') do |mbox|
  RMail::Mailbox.parse_mbox(mbox) do |raw|
    count += 1
    print "#{count} mails\n"
    begin
      File.open(RMail::Parser.read(raw).header.date.strftime("20%y-%m"), 'a') do |out|
        out.write(raw)
        out.write("\n")
      end
    rescue NoMethodError
      print "Couldn't parse date header, ignoring broken spam mail\n"
    end
  end
end
