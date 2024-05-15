# frozen_string_literal: true

require 'English'

namespace :eb do
  desc 'Deploys current version of the app to elastic beanstalk'
  task deploy: :environment do
    run_tests
    current_version = find_current_version
    version = request_new_version(current_version)
    build_docker_image(version)
    push_docker_image(version)
    update_dockerrun(version)
    commit_changes(version)
    deploy_to_eb(version)
  end
end

def run_tests
  puts 'Running tests...'
  errors = `bundle exec rspec | grep '#'`.split("\n")
  confirm_failing_tests(errors) if errors.any?
end

def confirm_failing_tests(errors)
  puts "Found #{errors.count / 2} failing #{'test'.pluralize(errors.count / 2)}"
  errors.each do |error|
    puts error
  end
  puts 'Are you sure you want to deploy with these tests failing? (y/n)'
  ok = $stdin.gets.chomp
  if ok == 'y'
    puts 'Continuing...'
  else
    puts 'Aborting'
    exit
  end
end

def find_current_version
  puts 'Querying elastic beanstalk for current version...'
  `eb status | grep 'Deployed Version' | cut -d':' -f2 | tr -d '[:space:]'`
end

def request_new_version(current_version)
  puts "Current version is: #{current_version}"
  print 'Enter the new version: '
  version = $stdin.gets.chomp
  puts "Current version is: #{current_version}"
  puts "Will deploy version: #{version}"
  puts 'Is this ok? (y/n/change)'
  ok = $stdin.gets.chomp
  case ok
  when 'n'
    puts 'Aborting'
    exit
  when 'y'
    puts 'Building Docker image...'
    version
  when 'change'
    puts 'Retrying...'
    raise ArgumentError, 'Input wrong version'
  else
    puts "You struggle with reading comprehension, don't you"
    raise ArgumentError, "Can't read"
  end
rescue ArgumentError
  retry
end

def build_docker_image(version)
  puts "Tag will be 'thatbballguy/materials:#{version}'"
  system("docker build . -t thatbballguy/materials:#{version}")
  return if $CHILD_STATUS.exitstatus.zero?

  puts 'Docker build failed. Aborting'
  exit
end

def push_docker_image(version)
  puts "Pushing 'thatbballguy/materials:#{version}' to docker hub..."
  system("docker push thatbballguy/materials:#{version}")
  return if $CHILD_STATUS.exitstatus.zero?

  puts 'Docker push failed. Aborting'
  exit
end

def update_dockerrun(version)
  puts "Updating dockerrrun.aws.json with 'thatbballguy/materials:#{version}' as image"
  data = File.open('dockerrun.aws.json') do |file|
    JSON.parse(file.read)
  end
  data['Image']['Name'] = "thatbballguy/materials:#{version}"
  File.write('dockerrun.aws.json', JSON.pretty_generate(data))
end

def commit_changes(version)
  puts 'Committing changes...'
  `git add .`
  `git commit -m "Deploy #{version}"`
end

def deploy_to_eb(version)
  puts "Deploying version #{version} to AWS"
  system("eb deploy -l #{version}")
end
