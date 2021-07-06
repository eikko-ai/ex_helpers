defmodule Helper do
  def otp_app, do: Application.get_env(:helpers, :otp_app)

  def repo, do: Application.get_env(:helpers, :repo)

  def endpoint, do: Application.get_env(:helpers, :endpoint)

  def translator, do: Application.get_env(:helpers, :translator)
end
