defmodule Sleeky.Entity.Dsl do
  use Diesel.Dsl,
    otp_app: :sleeky,
    root: Sleeky.Entity.Dsl.Entity,
    tags: [
      Sleeky.Entity.Dsl.Attribute,
      Sleeky.Entity.Dsl.Unique,
      :belongs_to,
      :has_many,
      :action,
      :key,
      :primary_key,
      Sleeky.Entity.Dsl.Role,
      Sleeky.Entity.Dsl.Scope,
      Sleeky.Entity.Dsl.One,
      Sleeky.Entity.Dsl.All,
      Sleeky.Entity.Dsl.Task,
      Sleeky.Entity.Dsl.On,
      Sleeky.Entity.Dsl.OnConflict
    ]
end
