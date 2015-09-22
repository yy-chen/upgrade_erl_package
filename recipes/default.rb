#
# Cookbook Name:: test_package
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
# All rights reserved - Do Not Redistribute
#
OLD_VERSION = data_bag_item('application', 'upgrade')['old_version']
NEW_VERSION = data_bag_item('application', 'upgrade')['new_version']
APP_NAME = data_bag_item('application','upgrade')['app']
GIT_URL = data_bag_item('application','appinfo')[APP_NAME]['git_url']
WORK_DIR = "/home/dhcd/boss"


create_workdir "create workdir" do
	work_dir WORK_DIR
end

update_git "update_git" do
	app_name APP_NAME
	git_url GIT_URL
	work_dir WORK_DIR	
end

#execute "sleep 0" do
#	command <<-EOH
#		sleep 60
#	EOH
#end

if !File.exists?("#{WORK_DIR}/repo/#{APP_NAME}_#{OLD_VERSION}")
	package "package old" do
		git_url GIT_URL
		app_name APP_NAME
		version OLD_VERSION
		work_dir WORK_DIR
	end
end

#execute "sleep 1" do
#	command <<-EOH
#		sleep 60
#	EOH
#end

package "package new" do
	git_url GIT_URL
	app_name APP_NAME
	version NEW_VERSION
	work_dir WORK_DIR
end

#execute "sleep 2" do
#	command <<-EOH
#		sleep 60
#	EOH
#end

build "build upgrade" do
	app_name APP_NAME
	old_version OLD_VERSION
	new_version NEW_VERSION
	work_dir WORK_DIR
end
