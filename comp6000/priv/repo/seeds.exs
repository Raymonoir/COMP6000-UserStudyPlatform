# # Script for populating the database. You can run it as:
# #
# #     mix run priv/repo/seeds.exs
# #
# # Inside the script, you can read and write to any of your
# # repositories directly:
# #
# #     Comp6000.Repo.insert!(%Comp6000.SomeSchema{})
# #
# # We recommend using the bang functions (`insert!`, `update!`
# # and so on) as they will fail if something goes wrong.

# # Create user seed
# user = %{
#   firstname: "RaySeed",
#   lastname: "WardSeed",
#   username: "Ray123Seed",
#   email: "Ray@SeedEmail.com",
#   password: "RaySeedPassword"
# }

# Comp6000.Contexts.Users.create_user(user)

# # Create study seed
# study = %{
#   title: "RaySeeds Study",
#   username: "Ray123Seed",
#   task_count: 0
# }

# {:ok, study} = Comp6000.Contexts.Studies.create_study(study)

# # Insert task into study seed
# task1 = %{
#   content: "First I want you to test your multiplication, what is 2 * 2?",
#   task_number: 1,
#   study_id: study.id
# }

# {:ok, task1} = Comp6000.Contexts.Tasks.create_task(task1)

# task2 = %{
#   content: "Second I want you to test your addition, what is 3 + 2?",
#   task_number: 2,
#   study_id: study.id
# }

# {:ok, task2} = Comp6000.Contexts.Tasks.create_task(task2)

# # Insert answers to both of those questions
# answer1 = %{
#   content: "The answer is 4",
#   task_id: task1.id
# }

# {:ok, answer1} = Comp6000.Contexts.Answers.create_answer(answer1)

# answer2 = %{
#   content: "The answer is 5",
#   task_id: task2.id
# }

# {:ok, answer2} = Comp6000.Contexts.Answers.create_answer(answer2)

# studies =
#   Comp6000.Contexts.Studies.get_study_by(id: study.id)
#   |> Comp6000.Repo.preload(:tasks)

# tasks = studies.tasks

# # Insert two results for each task
# result1_1 = %{
#   content: "I think the answer is 4",
#   unique_participant_id: "fgh567fgh56",
#   task_id: task1.id
# }

# result1_2 = %{
#   content: "I think the answer is 3",
#   unique_participant_id: "56gf6gygd63g",
#   task_id: task1.id
# }

# {:ok, result1_1} = Comp6000.Contexts.Results.create_result(result1_1)
# {:ok, result1_2} = Comp6000.Contexts.Results.create_result(result1_2)

# result2_1 = %{
#   content: "I think the answer is 5",
#   unique_participant_id: "kasniudw8",
#   task_id: task2.id
# }

# result2_2 = %{
#   content: "I think the answer is 10",
#   unique_participant_id: "87duy8dhiedj",
#   task_id: task2.id
# }

# {:ok, result2_1} = Comp6000.Contexts.Results.create_result(result2_1)
# {:ok, result2_2} = Comp6000.Contexts.Results.create_result(result2_2)
