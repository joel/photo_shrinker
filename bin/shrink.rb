#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/photo_shrinker'

require 'pry'

instance = PhotoShrinker::Cli.new
instance.call
