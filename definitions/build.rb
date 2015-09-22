#从repo中获取旧版本和新版本完整包，打升级包
define :build, :app_name=>nil, :old_version=>nil, :new_version=>nil, :work_dir=>nil do
	gitPath = "#{params[:work_dir]}/source/#{params[:app_name]}"
	
	ruby_block "copy repo" do
		block do
			FileUtils.cp_r("#{params[:work_dir]}/repo/#{params[:app_name]}_#{params[:new_version]}", "#{gitPath}/rel/#{params[:app_name]}")
			FileUtils.cp_r("#{params[:work_dir]}/repo/#{params[:app_name]}_#{params[:old_version]}", "#{gitPath}/rel/")
		end
	end
	execute "appups" do
		command <<-EOH
			cd #{gitPath}/rel
			../rebar generate-appups previous_release=#{params[:app_name]}_#{params[:old_version]}
		EOH
		returns [0]
	end

	execute "upgrade" do
		command <<-EOH
			cd #{gitPath}/rel
			../rebar generate-upgrade previous_release=#{params[:app_name]}_#{params[:old_version]}
		EOH
		returns [0]
	end

	ruby_block "copy upgrade" do
		block do
			FileUtils.mv("#{params[:work_dir]}/source/#{params[:app_name]}/rel/#{params[:app_name]}_#{params[:new_version]}.tar.gz", "#{params[:work_dir]}/upgrade/")
		end
	end
end
