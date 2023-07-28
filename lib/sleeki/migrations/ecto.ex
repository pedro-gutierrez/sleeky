defmodule Sleeki.Migrations.Ecto do
  @moduledoc false

  def version({:defmodule, _, [{:__aliases__, _, [:Sleeki, :Migration, v]} | _]}) do
    v |> to_string() |> String.trim_leading("V") |> String.to_integer()
  end

  def steps({:defmodule, _, [{:__aliases__, _, _}, [do: {:__block__, [], steps}]]}) do
    Enum.flat_map(steps, fn
      {:def, _, [{:up, _, _}, [do: {:__block__, _, steps}]]} -> steps
      {:def, _, [{:up, _, _}, [do: {_, _, _} = step]]} -> [step]
      {:use, _, [{:__aliases__, _, [:Ecto, :Migration]}]} -> []
      {:def, _, [{:down, _, _}, [do: _]]} -> []
    end)
  end

  def migration(version, body) do
    name = [:Sleeki, :Migration, String.to_atom("V#{version}")]

    {:defmodule, [line: 1],
     [
       {:__aliases__, [line: 1], name},
       [
         do:
           {:__block__, [],
            [
              {:use, [line: 1], [{:__aliases__, [line: 1], [:Ecto, :Migration]}]},
              {:def, [line: 1],
               [
                 {:up, [line: 1], nil},
                 [
                   do: {:__block__, [], body}
                 ]
               ]},
              {:def, [line: 1],
               [
                 {:down, [line: 1], nil},
                 [do: []]
               ]}
            ]}
       ]
     ]}
  end
end
