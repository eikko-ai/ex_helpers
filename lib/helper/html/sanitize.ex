defmodule Helper.Html.Sanitize do
  def strip_tags(html),
    do: HtmlSanitizeEx.strip_tags(html)
end
