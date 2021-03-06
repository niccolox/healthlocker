defmodule Healthlocker.Analytics.PropertiesBuilder do
  @moduledoc """
  Used for building a properties map from a model.
  """

  def build(model), do: properties(model)

  defp properties(%Healthlocker.Goal{} = goal) do
    %{
      important: goal.important
    }
  end

  defp properties(%Healthlocker.Post{}), do: %{}
  defp properties(%Healthlocker.SleepTracker{} = sleep_data) do
    %{
      notes: !!sleep_data.notes
    }
  end
end
