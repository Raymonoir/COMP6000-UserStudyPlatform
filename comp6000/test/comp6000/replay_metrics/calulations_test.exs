defmodule Comp6000.ReplayMetrics.CalculationsTest do
  use Comp6000.DataCase, async: true
  alias Comp6000.ReplayMetrics.Calculations

  describe "get_total_time/1" do
    test "returns total time taken in seconds" do
      assert [
               %{
                 "start" =>
                   DateTime.to_unix(
                     DateTime.from_naive!(~N[2022-09-20 00:00:00.000], "Etc/UTC"),
                     :millisecond
                   )
               },
               %{
                 "end" =>
                   DateTime.to_unix(
                     DateTime.from_naive!(~N[2022-09-21 00:00:00.000], "Etc/UTC"),
                     :millisecond
                   )
               }
             ]
             |> Calculations.get_total_time() == 86_400
    end
  end

  describe "get_character_count/2" do
    test "returns number of inserted characters" do
      assert [
               %{
                 "events" => [
                   [
                     1,
                     %{
                       "action" => "insert",
                       "lines" => [
                         "w"
                       ]
                     }
                   ],
                   [
                     1,
                     %{
                       "action" => "insert",
                       "lines" => [
                         "o"
                       ]
                     }
                   ]
                 ]
               },
               %{
                 "events" => [
                   [
                     1,
                     %{
                       "action" => "insert",
                       "lines" => [
                         "w"
                       ]
                     }
                   ]
                 ]
               }
             ]
             |> Calculations.get_character_count("insert") == 3
    end

    test "returns number of removed characters" do
      assert [
               %{
                 "events" => [
                   [
                     1,
                     %{
                       "action" => "remove",
                       "lines" => [
                         "w"
                       ]
                     }
                   ],
                   [
                     1,
                     %{
                       "action" => "remove",
                       "lines" => [
                         "o"
                       ]
                     }
                   ]
                 ]
               },
               %{
                 "events" => [
                   [
                     1,
                     %{
                       "action" => "remove",
                       "lines" => [
                         "w"
                       ]
                     }
                   ]
                 ]
               }
             ]
             |> Calculations.get_character_count("remove") == 3
    end
  end

  describe "get_idle_time/1" do
    test "returns sum of time between keypresses over 1 second in seconds" do
      assert [
               %{
                 "events" => [
                   [
                     1001,
                     %{}
                   ],
                   [
                     2001,
                     %{}
                   ]
                 ]
               },
               %{
                 "events" => [
                   [
                     1,
                     %{}
                   ]
                 ]
               }
             ]
             |> Calculations.get_idle_time() == 1.002
    end
  end

  describe "get_words_pasted/1" do
    test "gets the number of words pasted" do
      assert [
               %{
                 "events" => [
                   [
                     1,
                     %{
                       "action" => "remove",
                       "lines" => [
                         "i",
                         "pasted",
                         "this"
                       ]
                     }
                   ],
                   [
                     1,
                     %{
                       "action" => "remove",
                       "lines" => [
                         "o"
                       ]
                     }
                   ]
                 ]
               },
               %{
                 "events" => [
                   [
                     1,
                     %{
                       "action" => "remove",
                       "lines" => [
                         "i",
                         "also",
                         "pasted",
                         "this"
                       ]
                     }
                   ]
                 ]
               }
             ]
             |> Calculations.get_words_pasted() == 7
    end
  end

  describe "get_word_count/1" do
    test "gets the number of words" do
      assert [
               %{
                 "events" => [
                   [
                     1,
                     %{
                       "action" => "remove",
                       "lines" => [
                         "i ",
                         "pasted ",
                         "this"
                       ]
                     }
                   ],
                   [
                     1,
                     %{
                       "action" => "remove",
                       "lines" => [
                         " "
                       ]
                     }
                   ]
                 ]
               },
               %{
                 "events" => [
                   [
                     1,
                     %{
                       "action" => "remove",
                       "lines" => [
                         "i ",
                         "also ",
                         "pasted ",
                         "this"
                       ]
                     }
                   ]
                 ]
               }
             ]
             |> Calculations.get_word_count() == 7
    end
  end

  describe "get_most_common_error/2" do
    test "returns most common error name" do
      assert [
               %{
                 "userCodeError" => "seen.contains is not a function"
               },
               %{
                 "userCodeError" => "some different error"
               },
               %{
                 "userCodeError" => "seen.contains is not a function"
               }
             ]
             |> Calculations.get_most_common_error("userCodeError") ==
               {"seen.contains is not a function", 2}
    end
  end

  describe "get_times_run/2" do
    test "returns the number of times code was run" do
      assert [
               %{
                 "userCodeError" => "seen.contains is not a function"
               },
               %{
                 "userCodeError" => "some different error"
               },
               %{
                 "userCodeError" => "seen.contains is not a function"
               }
             ]
             |> Calculations.get_times_run() ==
               3
    end
  end

  describe "get_words_per_minute/1" do
    test "returns average words per minute" do
      assert [
               %{
                 "start" =>
                   DateTime.to_unix(
                     DateTime.from_naive!(~N[2022-09-20 01:00:00.000], "Etc/UTC"),
                     :millisecond
                   ),
                 "events" => [
                   [
                     1,
                     %{
                       "action" => "remove",
                       "lines" => [
                         "i ",
                         "pasted ",
                         "this"
                       ]
                     }
                   ],
                   [
                     1,
                     %{
                       "action" => "remove",
                       "lines" => [
                         " "
                       ]
                     }
                   ]
                 ]
               },
               %{
                 "end" =>
                   DateTime.to_unix(
                     DateTime.from_naive!(~N[2022-09-20 01:14:00.000], "Etc/UTC"),
                     :millisecond
                   ),
                 "events" => [
                   [
                     1,
                     %{
                       "action" => "remove",
                       "lines" => [
                         "i ",
                         "also ",
                         "pasted ",
                         "this"
                       ]
                     }
                   ]
                 ]
               }
             ]
             |> Calculations.get_words_per_minute() == 0.5
    end
  end

  describe "get_line_count" do
    test "returns number of lines" do
      assert [
               %{
                 "events" => [
                   [
                     1001,
                     %{
                       "end" => %{
                         "row" => 1,
                         "column" => 0
                       }
                     }
                   ],
                   [
                     1001,
                     %{
                       "end" => %{
                         "row" => 5,
                         "column" => 0
                       }
                     }
                   ]
                 ]
               }
             ]
             |> Calculations.get_line_count() == 5
    end
  end
end
