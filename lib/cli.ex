defmodule Helper.CLI do
  @moduledoc false

  @doc """
  Output blue text
  """
  def blue(text) do
    IO.ANSI.blue() <> text <> IO.ANSI.reset()
  end

  @doc """
  Output cyan text
  """
  def cyan(text) do
    IO.ANSI.cyan() <> text <> IO.ANSI.reset()
  end

  @doc """
  Output green text
  """
  def green(text) do
    IO.ANSI.green() <> text <> IO.ANSI.reset()
  end

  @doc """
  Output red text
  """
  def red(text) do
    IO.ANSI.red() <> text <> IO.ANSI.reset()
  end

  @doc """
  Output yellow text
  """
  def yellow(text) do
    IO.ANSI.yellow() <> text <> IO.ANSI.reset()
  end
end
