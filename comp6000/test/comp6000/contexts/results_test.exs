defmodule Comp6000.Contexts.ResultsTest do
  use Comp6000.DataCase, async: true
  alias Comp6000.Contexts.{Studies, Users, Tasks, Results}
  alias Comp6000.Schemas.{Result, Study}

  setup do
    {:ok, user} =
      Users.create_user(%{username: "Ray123", email: "Ray@email.com", password: "password12345"})

    {:ok, study} =
      Studies.create_study(%{username: user.username, title: "A Study Title", task_count: 0})

    {:ok, task} =
      Tasks.create_task(%{content: "What is 2*2?", task_number: 1, study_id: study.id})

    valid_result_params1 = %{
      study_id: study.id,
      unique_participant_id: "567f56d67s67as76d7s8",
      content: "3"
    }

    invalid_result_params = %{
      content: "No upid"
    }

    %{
      study: study,
      valid_result_params1: valid_result_params1,
      invalid_result_params: invalid_result_params
    }
  end

  describe "create_result/1" do
    test "valid parameters creates result and appends to database, study participant count is increased, participant is associated with study",
         %{
           valid_result_params1: valid_result_params1,
           study: study
         } do
      {:ok, result} = Results.create_result(valid_result_params1)
      assert result == Repo.get_by(Result, id: result.id)

      study = Repo.get_by(Study, id: study.id)
      assert study.participant_count == 1
      assert study.participant_list == [valid_result_params1.unique_participant_id]
    end

    test "invalid parameters does not create answer and does not append to database, study participant count is not increased",
         %{
           invalid_result_params: invalid_result_params,
           study: study
         } do
      {:error, _changeset} = Results.create_result(invalid_result_params)
      refute Repo.get_by(Result, content: invalid_result_params[:content])

      study = Repo.get_by(Study, id: study.id)
      assert study.participant_count == 0
      assert study.participant_list == []
    end
  end

  test "get_result_by/1 returns a result with the associated params", %{
    valid_result_params1: valid_result_params1
  } do
    assert nil == Results.get_result_by(content: valid_result_params1[:content])

    {:ok, result} = Results.create_result(valid_result_params1)

    assert result ==
             Results.get_result_by(content: valid_result_params1[:content])

    assert result ==
             Results.get_result_by(study_id: valid_result_params1[:study_id])
  end

  test "delete_result/1 deletes a result from the database", %{
    valid_result_params1: valid_result_params1
  } do
    {:ok, result} = Results.create_result(valid_result_params1)

    assert result ==
             Results.get_result_by(content: valid_result_params1[:content])

    {:ok, _result} = Results.delete_result(result)
    refute result == Results.get_result_by(content: valid_result_params1[:content])
    refute result == Results.get_result_by(study_id: valid_result_params1[:study_id])
  end

  test "get_study_for_result/1 returns the study associated with a result", %{
    valid_result_params1: valid_result_params1,
    study: study
  } do
    {:ok, result} = Results.create_result(valid_result_params1)
    assert Results.get_study_for_result(result).id == study.id
  end

  test "increment_participant_count increments study participant count", %{
    valid_result_params1: valid_result_params1,
    study: study
  } do
    {:ok, _result} = Results.create_result(valid_result_params1)
    study = Repo.get_by(Study, id: study.id)
    assert study.participant_count == 1

    {:ok, _result} = Results.create_result(valid_result_params1)
    study = Repo.get_by(Study, id: study.id)
    assert study.participant_count == 2
  end
end
