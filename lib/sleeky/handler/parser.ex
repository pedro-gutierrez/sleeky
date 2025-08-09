defmodule Sleeky.Handler.Parser do
  @moduledoc false
  @behaviour Diesel.Parser

  alias Sleeky.Handler

  import Sleeky.Feature.Naming

  def parse({:handler, _attrs, _children}, opts) do
    caller = Keyword.fetch!(opts, :caller_module)
    feature = feature_module(caller)

    %Handler{
      feature: feature
    }
  end
end
