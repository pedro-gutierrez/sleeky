defmodule Sleeky.Model.Dsl do
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.Model.Dsl.Model,
    tags: [
      :attribute,
      :belongs_to,
      :has_many,
      :action,
      :key,
      :primary_key,
      Sleeky.Model.Dsl.Allow
    ]
end
