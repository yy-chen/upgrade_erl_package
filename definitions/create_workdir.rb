#
# Cookbook Name:: test_package
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
# All rights reserved - Do Not Redistribute
#
define :create_workdir, :work_dir=>nil do
	Chef::Log.warn("create workdir")
	directory "#{params[:work_dir]}" do
		action :create
		owner 'dhcd'
		group 'dhcd'
		not_if{File.exists?(params[:work_dir])}
	end

	directory "#{params[:work_dir]}/source" do
		action :create
		owner 'dhcd'
		group 'dhcd'
		not_if{File.exists?("#{params[:work_dir]}/source")}
	end

	directory "#{params[:work_dir]}/repo" do
		action :create
		owner 'dhcd'
		group 'dhcd'
		not_if{File.exists?("#{params[:work_dir]}/repo")}
	end

	directory "#{params[:work_dir]}/upgrade" do
		action :create
		owner 'dhcd'
		group 'dhcd'
		not_if{File.exists?("#{params[:work_dir]}/upgrade")}
	end
end
