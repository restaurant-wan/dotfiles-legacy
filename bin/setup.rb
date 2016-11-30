#!/bin/env ruby

class Configuration
  DEPENDENCIES = {
    "base16-shell" => {
      "repo_location" => "chriskempson/base16-shell.git",
      "tag" => "tag-terminal",
      "base_path" => "config",
    },
    "muttdown" => {
      "repo_location" => "Roguelazer/muttdown.git",
      "tag" => "tag-mail-sender",
    },
    "wee-slack" => {
      "repo_location" => "rawdigits/wee-slack.git",
      "tag" => "tag-weechat",
      "copy" => {
        "path" => "tag-weechat/wee-slack/",
        "filename" => "wee_slack.py",
        "destination_path" => "tag-weechat/weechat/python/autoload/",
      },
    },
    "zsh-syntax-highlighting" => {
      "repo_location" => "zsh-users/zsh-syntax-highlighting.git",
      "tag" => "tag-zsh",
    },
  }.freeze
  GIT_PREFIX = "git@github.com:".freeze

  def self.load
    new.run
  end

  def run
    load_dependencies
    rcup
  end

  private

  def load_dependencies
    DEPENDENCIES.each do |name, details|
      base_path = details.dig("base_path")
      repo_location = details.dig("repo_location")
      tag = details.dig("tag")
      copy_details = details.dig("copy")
      dependency_folder_location = [tag, base_path, name].compact.join("/")

      unless folder_exists?(dependency_folder_location)
        clone_repo(repo_location, dependency_folder_location)
      end

      update(dependency_folder_location)
      copy_files(copy_details)
    end
  end

  def folder_exists?(folder)
    File.directory?(folder)
  end

  def clone_repo(repo, folder)
    system("git clone #{GIT_PREFIX}#{repo} #{folder}")
  end

  def copy_files(details)
    details &&
      system(make_directory_command(details)) &&
      system(copy_command(details))
  end

  def update(folder)
    system("cd #{folder} && git checkout master && git pull")
  end

  def rcup
    system("export RCRC='#{home_path}/dotfiles/host-#{hostname}/rcrc'")
    system("rcup")
  end

  def home_path
    ENV.fetch("HOME")
  end

  def hostname
    `hostname`.chomp
  end

  def copy_command(details)
    "cp #{details['path']}#{details['filename']} #{details['destination_path']}"
  end

  def make_directory_command(details)
    "mkdir -p #{details['destination_path']}"
  end
end

Configuration.load