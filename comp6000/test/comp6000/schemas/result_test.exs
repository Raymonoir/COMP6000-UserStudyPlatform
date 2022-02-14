defmodule Comp6000.Schemas.ResultTest do
  use Comp6000.DataCase, async: true
  alias Comp6000.Schemas.Result

  @valid_params %{
    content: "I thought the answer was 6",
    unique_participant_id: "678fgh678",
    study_id: 1
  }

  @update_params %{
    content: "Now I think its actually 69"
  }

  @invalid_params %{
    unique_participant_id: nil
  }

  describe "changeset/2" do
    test "valid creation params creates valid changeset" do
      changeset = Result.changeset(%Result{}, @valid_params)
      assert changeset.valid?
      assert changeset.changes.content == "I thought the answer was 6"
      assert changeset.changes.study_id == 1
    end

    test "valid update params creates valid changeset" do
      result = struct(Result, @valid_params)
      changeset = Result.changeset(result, @update_params)

      assert changeset.changes.content == "Now I think its actually 69"

      assert changeset.data.study_id == 1
    end

    test "invalid creation params returns invalid changeset" do
      changeset = Result.changeset(%Result{}, @invalid_params)
      refute changeset.valid?

      assert errors_on(changeset) == %{
               content: ["can't be blank"],
               study_id: ["can't be blank"],
               unique_participant_id: ["can't be blank"]
             }
    end

    test "invalid update params returns invalid changeset" do
      result = struct(Result, @valid_params)
      changeset = Result.changeset(result, @invalid_params)
      refute changeset.valid?

      assert errors_on(changeset) == %{unique_participant_id: ["can't be blank"]}
    end
  end
end
