#创建一个目录，先检测是否存在，删掉后再创建
define :create_dir, :dirname =>nil do	
	Chef::Log.warn("create_dir : #{params[:dirname]}")
	directory params[:dirname] do
		recursive true
		action :delete
		only_if{File.exists?(params[:dirname])}
	end

	directory params[:dirname] do
		recursive true
		action :create
		owner 'dhcd'
		group 'dhcd'
	end
end

