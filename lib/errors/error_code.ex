defmodule Helper.ErrorCode do
  @moduledoc """
  Error code mapping
  """
  @default_base 000
  @client_base 400
  @server_base 500

  # Default errors
  def ecode, do: @default_base
  def ecode(:custom), do: @default_base + 1
  def ecode(:changeset), do: @default_base + 2
  def ecode(:already_exists), do: @default_base + 3
  def ecode(:create_failed), do: @default_base + 4
  def ecode(:update_failed), do: @default_base + 5
  def ecode(:delete_failed), do: @default_base + 6
  def ecode(:pagination), do: @default_base + 7

  # Client errors
  def ecode(:bad_request), do: @client_base
  def ecode(:unauthorized), do: @client_base + 1
  def ecode(:payment_required), do: @client_base + 2
  def ecode(:forbidden), do: @client_base + 3
  def ecode(:not_found), do: @client_base + 4
  def ecode(:method_not_allowed), do: @client_base + 5
  def ecode(:not_acceptable), do: @client_base + 6
  def ecode(:proxy_auth_required), do: @client_base + 7
  def ecode(:request_timeout), do: @client_base + 8
  def ecode(:conflict), do: @client_base + 9
  def ecode(:gone), do: @client_base + 10
  def ecode(:unsupported_media_type), do: @client_base + 15
  def ecode(:unprocessable_entity), do: @client_base + 22
  def ecode(:locked), do: @client_base + 23
  def ecode(:too_many_requests), do: @client_base + 29
  def ecode(:legal_reasons), do: @client_base + 51

  # Server errors
  def ecode(:internal_server_error), do: @server_base
  def ecode(:not_implemented), do: @server_base + 1
  def ecode(:bad_gateway), do: @server_base + 2
  def ecode(:service_unavailable), do: @server_base + 3
end
