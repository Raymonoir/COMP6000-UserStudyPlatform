defmodule Comp6000.Contexts.StudiesTest do
  use Comp6000.DataCase, async: true
  alias Comp6000.Contexts.{Studies, Users}
  alias Comp6000.Schemas.Study

  @valid_study_params1 %{
    username: "Ray123",
    title: "A Valid Study Title",
    task_count: 6,
    tasks: []
  }
  @valid_study_params2 %{
    username: "Mais123",
    title: "Another Valid Study Title",
    task_count: 23,
    tasks: []
  }

  @invalid_study_params %{
    username: "Doesn't Exist",
    title: "Invalid Title",
    task_count: 0
  }

  setup do
    Users.create_user(%{username: "Ray123", email: "Ray@email.com", password: "password12345"})
    Users.create_user(%{username: "Mais123", email: "Mais@email.com", password: "password12345"})

    :ok
  end

  describe "create_study/1" do
    test "valid parameters creates study with participant_code and appends to database" do
      {:ok, study} = Studies.create_study(@valid_study_params1)
      assert study.participant_code != nil
      assert study == Repo.get_by(Study, id: study.id) |> Repo.preload(:tasks)
    end

    test "invalid parameters does not create study and does not append to database" do
      {:error, _changeset} = Studies.create_study(@invalid_study_params)
      refute Repo.get_by(Study, title: @invalid_study_params[:title])
    end
  end

  describe "change_study/2" do
    test "valid parameters changes a study within the database" do
      {:ok, study} = Studies.create_study(@valid_study_params1)
      assert {:ok, changed_study} = Studies.update_study(study, %{title: "Updated Title"})
      assert nil == Studies.get_study_by(title: @valid_study_params1[:title])
      assert changed_study == Studies.get_study_by(title: "Updated Title") |> Repo.preload(:tasks)
      assert changed_study.task_count == @valid_study_params1[:task_count]
    end

    test "invalid parameters does not change a study within the database" do
      {:ok, study} = Studies.create_study(@valid_study_params1)
      assert {:error, _changeset} = Studies.update_study(study, %{username: "123"})
      assert nil == Studies.get_study_by(username: "123")

      assert study ==
               Studies.get_study_by(username: @valid_study_params1[:username])
               |> Repo.preload(:tasks)
    end
  end

  test "get_study_by/1 returns study with the associated params" do
    assert nil == Studies.get_study_by(title: @valid_study_params1[:title])

    {:ok, study} = Studies.create_study(@valid_study_params1)

    assert study ==
             Studies.get_study_by(title: @valid_study_params1[:title]) |> Repo.preload(:tasks)

    assert study ==
             Studies.get_study_by(task_count: @valid_study_params1[:task_count])
             |> Repo.preload(:tasks)

    assert study ==
             Studies.get_study_by(username: @valid_study_params1[:username])
             |> Repo.preload(:tasks)
  end

  test "list_all_studies/0 lists all created studies" do
    assert [] == Studies.get_all_studies()
    {:ok, study1} = Studies.create_study(@valid_study_params1)
    {:ok, study2} = Studies.create_study(@valid_study_params2)

    assert [study1, study2] ==
             Enum.map(Studies.get_all_studies(), fn study -> Repo.preload(study, :tasks) end)
  end

  test "delete_study/1 deletes a study from the database" do
    {:ok, study} = Studies.create_study(@valid_study_params1)

    assert study ==
             Studies.get_study_by(title: @valid_study_params1[:title]) |> Repo.preload(:tasks)

    {:ok, _study} = Studies.delete_study(study)
    refute study == Studies.get_study_by(title: @valid_study_params1[:title])
    refute study == Studies.get_study_by(task_count: @valid_study_params1[:task_count])
  end

  describe "increment_participant_count/1" do
    test "increments the participant_count on a study" do
      {:ok, study} = Studies.create_study(@valid_study_params1)
      assert study.participant_count == 0
      Studies.increment_participant_count(study)

      study = Studies.get_study_by(title: @valid_study_params1[:title])
      assert study.participant_count == 1
    end

    test "if increment makes participant count equal to participant max, sets participant code to nil" do
      {:ok, study} = Studies.create_study(@valid_study_params1)
      {:ok, study} = Studies.update_study(study, %{participant_max: 10, participant_count: 9})
      assert study.participant_code != nil
      {:ok, study} = Studies.increment_participant_count(study)

      assert study.participant_count == 10
      assert study.participant_code == nil
    end
  end
end
