defmodule Healthlocker.CopingStrategyView do
  use Healthlocker.Web, :view

  def markdown(body) do
    body
    |> Earmark.as_html!
    |> raw
  end
end
