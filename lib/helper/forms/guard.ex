defmodule Helper.Forms.Guard do
  def submitted_too_fast?(time_str, diff \\ 3),
    do:
      Time.diff(
        time_from_string(time_str),
        Time.utc_now(),
        :second
      ) < diff

  defp time_from_string(time_str),
    do:
      time_str
      |> Time.from_iso8601()
      |> parse_time_result()

  defp parse_time_result({:ok, time}),
    do: time

  defp parse_time_result(_),
    do: Time.utc_now()

  def honeypot_filled?(honeypot_str),
    do: byte_size(honeypot_str) > 0
end
