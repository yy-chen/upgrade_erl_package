#打包
define :package, :app_name=>nil, :version=>nil, :work_dir=>nil do
	Chef::Log.warn("package appname : #{params[:app_name]} , version : #{params[:version]}")

	gitPath = "#{params[:work_dir]}/source/#{params[:app_name]}"

	git gitPath do#将git切换至指定版本对应的tag
		repo params[:git_url]
		revision "v#{params[:version]}"
		checkout_branch "package"
		action :sync
	end
	ruby_block "change src version" do#将 appName.app.src中的版本号改为当前版本
		block do
			file = Chef::Util::FileEdit.new("#{gitPath}/src/#{params[:app_name]}.app.src")
			file.search_file_replace(/\{vsn,\s*\"([0-9.]+\")\}/, "{vsn, \"#{params[:version]}\"}")
			file.write_file
		end
	end

	#删除生成的old文件
	file "#{gitPath}/src/#{params[:app_name]}.app.src.old" do
		action :delete
		only_if{File.exists?("#{gitPath}/src/#{params[:app_name]}.app.src.old")}
	end

	#./rebar clean
	execute "compile" do#编译代码
		command <<-EOH
			cd #{gitPath}
			./rebar clean
			./rebar compile
		EOH
		returns [0]
	end

	create_dir "create rel" do
		dirname "#{gitPath}/rel"
	end

	execute "createnode" do
		command <<-EOH
			cd #{gitPath}/rel
			../rebar create-node nodeid=#{params[:app_name]}
		EOH
		returns [0]
	end

	#更改reltool.config中
	#	{lib_dirs, []},     
	#    {rel, "be", "1",    
	#    {app, be, [{mod_cond, app}, {incl_cond, include}]}
	#    三处
	ruby_block "change config" do
		block do 
			file = Chef::Util::FileEdit.new("#{gitPath}/rel/reltool.config")
			#file.search_file_replace(/\{lib_dirs.*/, "{lib_dirs, [\"../deps\"]},")
			file.search_file_replace(/\{rel, \"#{params[:app_name]}\", \"([0-9.])+\"/, "\{rel, \"#{params[:app_name]}\", \"#{params[:version]}\"")
			#file.search_file_replace(/\{app,.*/, "{app, #{params[:app_name]}, [{mod_cond, app}, {incl_cond, include}, {lib_dir, \"..\"}]}")
			file.write_file
		end
	end

	file "#{gitPath}/rel/reltool.config.old" do
		action :delete
		only_if{File.exists?("#{gitPath}/rel/reltool.config.old")}
	end

	#rebar generate
	execute "generate" do
		command <<-EOH
			cd #{gitPath}/rel
			../rebar generate
		EOH
		returns [0]
	end
	
	directory "#{params[:work_dir]}/repo/#{params[:app_name]}_#{params[:version]}" do
		action :delete
		recursive true
		only_if{File.exists?("#{params[:work_dir]}/repo/#{params[:app_name]}_#{params[:version]}")}
	end

	ruby_block "move rel" do
		block do
			FileUtils.mv("#{gitPath}/rel/#{params[:app_name]}", "#{params[:work_dir]}/repo/#{params[:app_name]}_#{params[:version]}")
		end
	end
end
