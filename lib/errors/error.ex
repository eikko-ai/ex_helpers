defmodule Helper.Error do
  @moduledoc """
  Standardize errors by using an Error struct and attaching
  more information when not available (like status codes, error message, etc.).
  This is useful specially when consuming errors in the Web
  layer (Phoenix controllers and Absinthe resolvers).
  """

  alias __MODULE__

  require Logger
  import Helper.ErrorCode

  defstruct [:code, :message, :status_code]

  # Regular errors
  def normalize({:error, reason}) do
    handle(reason)
  end

  # Ecto transaction errors
  def normalize({:error, _operation, reason, _changes}) do
    handle(reason)
  end

  # Unhandled errors
  def normalize(other) do
    handle(other)
  end

  defp handle(code) when is_atom(code) do
    {status, message} = metadata(code)

    %Error{
      code: code,
      message: message,
      status_code: status
    }
  end

  defp handle(errors) when is_list(errors) do
    Enum.map(errors, &handle/1)
  end

  defp handle(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {err, _opts} -> err end)
    |> Enum.map(fn {k, v} ->
      %Error{
        code: :validation,
        message: String.capitalize("#{k} #{v}"),
        status_code: ecode(:unprocessable_entity)
      }
    end)
  end

  # ... Handle other error types here ...

  defp handle(other) do
    Logger.error("Unhandled error term:\n#{inspect(other)}")
    handle(:unknown)
  end

  # Build Error Metadata
  # --------------------

  defp metadata(:unknown_resource), do: {ecode(:bad_request), "Unknown Resource"}
  defp metadata(:invalid_argument), do: {ecode(:bad_request), "Invalid arguments passed"}
  defp metadata(:unauthorized), do: {ecode(:unauthorized), "You need to be logged in"}
  defp metadata(:incorrect_credentials), do: {ecode(:unauthorized), "Invalid credentials"}
  defp metadata(:forbidden), do: {ecode(:forbidden), "You don't have permission to do this"}
  defp metadata(:not_found), do: {ecode(:not_found), "Resource not found"}
  defp metadata(:user_not_found), do: {ecode(:not_found), "User not found"}
  defp metadata(:unknown), do: {ecode(:internal_server_error), "Something went wrong"}

  defp metadata(code) do
    Logger.warn("Unhandled error code: #{inspect(code)}")
    {ecode(:unprocessable_entity), to_string(code)}
  end
end
