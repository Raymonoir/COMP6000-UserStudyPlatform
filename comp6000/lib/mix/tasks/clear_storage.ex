defmodule Mix.Tasks.ClearStorage do
  use Mix.Task

  def run(args) do
    if hd(args) == "study" do
      Enum.map(tl(args), fn study_id -> Mix.shell().cmd("rm -r local-storage/#{study_id}") end)
    else
      Mix.shell().cmd("rm -r local-storage/*")
    end
  end
end
