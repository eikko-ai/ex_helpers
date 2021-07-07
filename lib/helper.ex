defmodule Helper do
  def otp_app, do: Application.get_env(:ex_helpers, :otp_app)

  def repo, do: Application.get_env(:ex_helpers, :repo)

  def endpoint, do: Application.get_env(:ex_helpers, :endpoint)

  def translator, do: Application.get_env(:ex_helpers, :translator)
end
