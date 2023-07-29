defmodule Sleeky.Entity.Aliases do
  @moduledoc false

  def new(%{aliases: _} = field) do
    duck_cased = to_string(field.name)
    camel_cased = Inflex.camelize(field.name, :lower)
    aliases = Enum.uniq([duck_cased, camel_cased, field.name])

    Map.put(field, :aliases, aliases)
  end
end
