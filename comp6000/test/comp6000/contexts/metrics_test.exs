defmodule Comp6000.Contexts.MetricsTest do
  use Comp6000.DataCase, async: true
  alias Comp6000.Contexts.{Studies, Users, Tasks, Metrics}
  alias Comp6000.Schemas.{Study}

  setup do
    {:ok, user} =
      Users.create_user(%{username: "Ray123", email: "Ray@email.com", password: "password12345"})

    {:ok, study} =
      Studies.create_study(%{username: user.username, title: "A Study Title", task_count: 0})

    {:ok, task} =
      Tasks.create_task(%{content: "What is 2*2?", task_number: 1, study_id: study.id})

    valid_metrics_params = %{
      study_id: study.id,
      participant_uuid: "567f56d67s67as76d7s8",
      content: "metrics"
    }

    invalid_metrics_params = %{
      content: "No upid"
    }

    %{
      study: study,
      valid_metrics_params: valid_metrics_params,
      invalid_metrics_params: invalid_metrics_params
    }
  end

  describe "create_metrics/1" do
    test "valid parameters creates result and appends to database, study participant count is increased, participant is associated with study",
         %{
           valid_metrics_params: valid_metrics_params,
           study: study
         } do
      {:ok, metrics} = Metrics.create_metrics(valid_metrics_params)
      assert metrics == Repo.get_by(Comp6000.Schemas.Metrics, id: metrics.id)

      study = Repo.get_by(Study, id: study.id)
      assert study.participant_count == 1
      assert study.participant_list == [valid_metrics_params.participant_uuid]
    end

    test "invalid parameters does not create answer and does not append to database, study participant count is not increased",
         %{
           invalid_metrics_params: invalid_metrics_params,
           study: study
         } do
      {:error, _changeset} = Metrics.create_metrics(invalid_metrics_params)
      refute Repo.get_by(Comp6000.Schemas.Metrics, content: invalid_metrics_params[:content])

      study = Repo.get_by(Study, id: study.id)
      assert study.participant_count == 0
      assert study.participant_list == []
    end
  end

  test "get_result_by/1 returns a result with the associated params", %{
    valid_metrics_params: valid_metrics_params
  } do
    assert nil == Metrics.get_metrics_by(content: valid_metrics_params[:content])

    {:ok, metrics} = Metrics.create_metrics(valid_metrics_params)

    assert metrics ==
             Metrics.get_metrics_by(content: valid_metrics_params[:content])

    assert metrics ==
             Metrics.get_metrics_by(study_id: valid_metrics_params[:study_id])
  end

  test "delete_result/1 deletes a result from the database", %{
    valid_metrics_params: valid_metrics_params
  } do
    {:ok, metrics} = Metrics.create_metrics(valid_metrics_params)

    assert metrics ==
             Metrics.get_metrics_by(content: valid_metrics_params[:content])

    {:ok, _result} = Metrics.delete_result(metrics)
    refute metrics == Metrics.get_metrics_by(content: valid_metrics_params[:content])
    refute metrics == Metrics.get_metrics_by(study_id: valid_metrics_params[:study_id])
  end

  test "get_study_for_result/1 returns the study associated with a result", %{
    valid_metrics_params: valid_metrics_params,
    study: study
  } do
    {:ok, metrics} = Metrics.create_metrics(valid_metrics_params)
    assert Metrics.get_study_for_metrics(metrics).id == study.id
  end

  test "increment_participant_count increments study participant count", %{
    valid_metrics_params: valid_metrics_params,
    study: study
  } do
    {:ok, _metrics} = Metrics.create_metrics(valid_metrics_params)
    study = Repo.get_by(Study, id: study.id)
    assert study.participant_count == 1

    {:ok, _metrics} = Metrics.create_metrics(valid_metrics_params)
    study = Repo.get_by(Study, id: study.id)
    assert study.participant_count == 2
  end
end
