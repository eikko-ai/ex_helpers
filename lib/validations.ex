defmodule Helper.Validations do
  @moduledoc """
  Several utilities / helpers to validate data, like email format, etc.
  """

  @doc """
  This is just a simple check to validate if the basic format of an email is
  present `user@host.domain`. Email validation using regex can become very complex, so the best
  way to validate an email still is to send an actual email to the user.
  For this reason, this is just a simple shape validation.
  """
  def is_email?(email) when is_binary(email) do
    case Regex.run(email_regex(), email) do
      nil -> {:error, "Invalid email"}
      [_] -> true
    end
  end

  def is_email?(_), do: {:error, "Invalid email / No argument"}

  def email_regex do
    ~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/i
  end
end
