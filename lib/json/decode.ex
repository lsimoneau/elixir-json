
defmodule JSON.Decode.Error, do: defexception([message: "Invalid JSON - unknown error"])

defmodule JSON.Decode.UnexpectedEndOfBufferError, do: defexception([message: "Invalid JSON - unexpected end of buffer"])

defmodule JSON.Decode.UnexpectedTokenError do
  defexception [token: nil]
  def message(exception), do: "Invalid JSON - unexpected token >>#{exception.token}<<"
end

defprotocol JSON.Decode do
  @moduledoc """
  Defines the protocol required for converting raw JSON into Elixir terms
  """

  @doc """
  Returns an atom and an Elixir term
  """
  @spec from_json(any) :: { atom, term }
  def from_json(bitstring_or_char_list)

end

defimpl JSON.Decode, for: BitString do
  def from_json(bitstring) do
    case JSON.Parser.Bitstring.trim(bitstring)
          |> JSON.Parser.Bitstring.parse
    do
      { :error, error_info } -> { :error, error_info }
      { :ok, value, rest }   ->
        case JSON.Parser.Bitstring.trim(rest) do
          << >> -> { :ok, value }
          _     -> { :error, { :unexpected_token, rest } }
        end
    end
  end
end

defimpl JSON.Decode, for: List do
  def from_json(charlist) do
    case JSON.Parser.Charlist.trim(charlist)
          |> JSON.Parser.Charlist.parse
    do
      { :error, error_info } -> { :error, error_info }
      { :ok, value, rest }   ->
        case JSON.Parser.Charlist.trim(rest) do
          [] -> { :ok, value }
          _  -> { :error, { :unexpected_token, rest } }
        end
    end
  end
end
