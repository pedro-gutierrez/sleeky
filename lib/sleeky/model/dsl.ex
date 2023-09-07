defmodule Sleeky.Model.Dsl do
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: :model,
    tags: [
      :attribute,
      :belongs_to,
      :has_many,
      :action,
      :key,
      :primary_key
    ]
end
