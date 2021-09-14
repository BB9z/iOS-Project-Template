#! /usr/bin/env ruby
# Copyright © 2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.

# Usage:
# ruby ./MBBuildCount.rb $BUILD_COUNT_RECORD_PLIST $USER [$BRANCH_NAME]

# require 'rubygems'
require 'plist'

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

plist_path  = ARGV[0]
user_name   = ARGV[1]
branch_name = ARGV[2]

# 脚本打印最后一行是编译数

# 处理参数
if plist_path == nil
    puts "参数错误，没传文件路径"
    puts -1
    exit 1
end

if user_name == nil
    puts "参数错误，没传用户名"
    puts -1
    exit 1
end

branch_name = "default" if branch_name == nil
branch_name = branch_name.dup.force_encoding("UTF-8")

plist = Plist::parse_xml(plist_path)
plist = { "Version" => 1 } if plist == nil

# 写一个最简单的版本检查
record_version = plist["Version"]
if !record_version
    puts "Unknown record file."
    puts -1
    exit 1
elsif record_version > 1
    puts "Not support: The record file is create by a higher version."
    puts -1
    exit 1
end

# 先更下记录
user_build_records = plist["UserBuildRecords"]
user_build_records = {} unless user_build_records.kind_of? Hash
    user_record = user_build_records[user_name]
    user_record = {} unless user_record.kind_of? Hash
        count = user_record[branch_name]
        count = 0 unless count.is_a? Integer
        user_record[branch_name] = (count + 1)
    user_build_records[user_name] = user_record
plist["UserBuildRecords"] = user_build_records

# 统计
total_count = 0
user_build_records.each do |user, record|
    record.each do |branch, count|
        total_count += count
    end
end

puts total_count.to_i

Plist::Emit.save_plist(plist, plist_path)
