ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Comp6000.Repo, :manual)

ExUnit.after_suite(fn _ ->
  storage_path = Application.get_env(:comp6000, :storage_path)

  Enum.map(File.ls!("#{storage_path}"), fn study_dir ->
    if File.dir?("#{storage_path}/#{study_dir}") do
      Enum.map(File.ls!("#{storage_path}/#{study_dir}"), fn task_dir ->
        Enum.map(File.ls!("#{storage_path}/#{study_dir}/#{task_dir}"), fn part_dir ->
          Enum.map(File.ls!("#{storage_path}/#{study_dir}/#{task_dir}/#{part_dir}"), fn file ->
            File.rm!("#{storage_path}/#{study_dir}/#{task_dir}/#{part_dir}/#{file}")
          end)

          File.rmdir!("#{storage_path}/#{study_dir}/#{task_dir}/#{part_dir}")
        end)

        File.rmdir!("#{storage_path}/#{study_dir}/#{task_dir}")
      end)

      File.rmdir!("#{storage_path}/#{study_dir}")
    end
  end)
end)
