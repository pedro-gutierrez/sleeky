defmodule Sleeky.Model.Dsl do
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.Model.Dsl.Model,
    tags: [
      Sleeky.Model.Dsl.Attribute,
      Sleeky.Model.Dsl.Unique,
      :belongs_to,
      :has_many,
      :action,
      :key,
      :primary_key,
      Sleeky.Model.Dsl.Role,
      Sleeky.Model.Dsl.Scope,
      Sleeky.Model.Dsl.One,
      Sleeky.Model.Dsl.All,
      Sleeky.Model.Dsl.Task,
      Sleeky.Model.Dsl.On,
      Sleeky.Model.Dsl.OnConflict
    ]
end
