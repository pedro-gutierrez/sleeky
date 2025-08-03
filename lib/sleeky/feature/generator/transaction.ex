defmodule Sleeky.Feature.Generator.Transaction do
  @moduledoc false
  @behaviour Diesel.Generator

  def generate(_, _) do
    quote do
      def transaction(fun) do
        with {:ok, _} <-
               @repo.transaction(fn ->
                 case fun.() do
                   {:error, reason} -> @repo.rollback(reason)
                   _ -> :ok
                 end
               end),
             do: :ok
      end
    end
  end
end
