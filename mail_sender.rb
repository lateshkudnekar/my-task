#!/usr/bin/env ruby
# encoding: utf-8

require 'pony'
require 'yaml'


class MailSender

  def initialize(config, contacts, subject, message, attachment=nil)
    @config = YAML.load_file(config)
    @recipients = contacts
    @subject = subject
    # Path to text file
    @message = message
    # Path to attachment file
    @attachment = attachment unless attachment.nil?
  end

  def handle
    Pony.options = pony_options
    send_emails unless emails.empty?
  end

  def pony_options
    mail_opts = mail_options
    mail_opts.merge!(authed_options) if @config['authenticate']
    mail_opts[:subject] = @subject
    mail_opts[:body] = @message
    unless @attachment.nil?
      mail_opts[:attachments] =
      {File.basename(@attachment) => File.read(@attachment)}
    end
    return mail_opts
  end

  def emails
    @mails ||= @recipients.each_with_object([]) do |to, res|
      tmp = Hash.new
      tmp[:to] = to
      res << tmp
    end
    return @mails
  end

  def send_emails
    emails.each do |email|
      begin
        Timeout.timeout 10 do
          Pony.mail(email)
          puts "Sent an email to #{email[:to]}"
        end
      rescue Timeout::Error
        puts "Failed to send an emial to #{email[:to]}"
      end
    end
  end

  def mail_options
  {
    :from => "#{@config['fromname']} <#{@config['account']['username']}>",
    :via => @config['via'],
    :charset => 'UTF-8',
    :text_part_charset => 'UTF-8',
    :sender => @config['account']['username'],
  }
  end

  def authed_options
  {
    via_options: {
      :address => @config['account']['hostname'],
      :port => @config['account']['port'],
      :enable_starttls_auto => @config['account']['tls'],
      :user_name => @config['account']['username'],
      :password => @config['account']['password'],
      :authentication => :plain
      }
    }
  end
end
