defmodule Helper.Html.Sanitize do
  def strip_tags(html) do
    case Floki.parse_fragment(html) do
      {:ok, html_tree} -> Floki.text(html_tree)
      {:error, string} -> string
    end
  end
end
