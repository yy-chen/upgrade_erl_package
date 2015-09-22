#更新git工作目录，如果不存在则新建
define :update_git, :app_name=>nil, :git_uri=>nil, :work_dir=>nil do	
	Chef::Log.warn("update_git : #{params[:app_name]} , #{params[:git_uri]}")
	gitPath = "#{params[:work_dir]}/source/#{params[:app_name]}"
	if !File.exists?(gitPath)
		create_dir "create gitpath" do
			dirname gitPath
		end
	end

	git gitPath do
		repo params[:git_url]
		action :sync
	end

	#execute "get deps" do#更新依赖包
	#	command <<-EOH
	#		cd #{gitPath}
	#		./rebar get-deps
	#	EOH
	#	returns [0]
	#end
end
