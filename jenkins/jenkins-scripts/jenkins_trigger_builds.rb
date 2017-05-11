#!/usr/bin/env ruby

# This script triggers the YaST job builds for the master branch at 
# the publis Jenkins.
#
# Pass the Jenkins credentials via "JENKINS_USER" and "JENKINS_PASSWORD"
# environment variables.

require_relative "jenkins_scripts"
jenkins_setup

jenkins = jenkins_client

# get only the master branch YaST jobs
jenkins_jobs = jenkins.job.list_all.select { |j| j.match(/^yast|^libyui/) && j.end_with?("-master")}
puts "Found #{jenkins_jobs.size} Jenkins jobs"

jenkins_jobs.each_with_index do |job, index|
  # wait until the YaST queue is empty
  while !jenkins.queue.list.select { |j| j.match(/^yast|^libyui/) }.empty? do
    puts "Some job already queued, sleeping for a while... "
    sleep(30)
  end

  puts "[#{index}/#{jenkins_jobs.size}] Starting job #{job}..."
  jenkins.job.build(job)
  sleep(30)
end
