ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Comp6000.Repo, :manual)

defmodule Comp6000.TestHelpers do
  # An exceedingly nasty function to delete all files and directories within local-storage once tests are complete
  def clear_local_storage() do
    storage_path = Application.get_env(:comp6000, :storage_directory_path)

    Enum.map(File.ls!("#{storage_path}"), fn study_dir ->
      if File.dir?("#{storage_path}/#{study_dir}") do
        Enum.map(File.ls!("#{storage_path}/#{study_dir}"), fn task_dir ->
          Enum.map(File.ls!("#{storage_path}/#{study_dir}/#{task_dir}"), fn file ->
            File.rm("#{storage_path}/#{study_dir}/#{task_dir}/#{file}")
          end)

          File.rmdir!("#{storage_path}/#{study_dir}/#{task_dir}")
        end)

        File.rmdir!("#{storage_path}/#{study_dir}")
      end
    end)
  end
end
