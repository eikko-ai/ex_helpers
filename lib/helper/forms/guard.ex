defmodule Helper.Forms.Guard do
  def time(),
    do: Time.utc_now()

  def submitted_too_fast?(start_time, min_allowed \\ 2) do
    time_taken =
      start_time
      |> Time.from_iso8601()
      |> parse_time_result()
      |> Time.diff(time(), :second)
      |> abs()

    time_taken < min_allowed
  end

  defp parse_time_result({:ok, time}),
    do: time

  defp parse_time_result(_),
    do: time()

  def honeypot_filled?(honeypot_str),
    do: byte_size(honeypot_str) > 0
end
