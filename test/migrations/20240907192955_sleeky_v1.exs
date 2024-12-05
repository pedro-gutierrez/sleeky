defmodule Sleeky.Migration.V1 do
  use Ecto.Migration

  def up do
    execute("CREATE SCHEMA accounts")
    execute("CREATE SCHEMA notifications")
    execute("CREATE SCHEMA publishing")

    create(table(:users, prefix: :accounts, primary_key: false)) do
      add(:email, :string, null: false)
      add(:id, :binary_id, primary_key: true, null: false)
      add(:public, :boolean, null: false)
      timestamps(type: :utc_datetime_usec)
    end

    create(table(:authors, prefix: :publishing, primary_key: false)) do
      add(:id, :binary_id, primary_key: true, null: false)
      add(:name, :string, null: false)
      timestamps(type: :utc_datetime_usec)
    end

    create(table(:blogs, prefix: :publishing, primary_key: false)) do
      add(:author_id, :binary_id, null: false)
      add(:id, :binary_id, primary_key: true, null: false)
      add(:name, :string, null: false)
      add(:published, :boolean, null: false)
      add(:theme_id, :binary_id, null: true)
      timestamps(type: :utc_datetime_usec)
    end

    create(table(:comments, prefix: :publishing, primary_key: false)) do
      add(:author_id, :binary_id, null: false)
      add(:body, :string, null: false)
      add(:id, :binary_id, primary_key: true, null: false)
      add(:post_id, :binary_id, null: false)
      timestamps(type: :utc_datetime_usec)
    end

    create(table(:posts, prefix: :publishing, primary_key: false)) do
      add(:author_id, :binary_id, null: false)
      add(:blog_id, :binary_id, null: false)
      add(:deleted, :boolean, null: false)
      add(:id, :binary_id, primary_key: true, null: false)
      add(:locked, :boolean, null: false)
      add(:published, :boolean, null: false)
      add(:published_at, :utc_datetime, null: true)
      add(:title, :string, null: false)
      timestamps(type: :utc_datetime_usec)
    end

    create(table(:themes, prefix: :publishing, primary_key: false)) do
      add(:id, :binary_id, primary_key: true, null: false)
      add(:name, :string, null: false)
      timestamps(type: :utc_datetime_usec)
    end

    alter(table(:blogs, prefix: :publishing)) do
      modify(:author_id, references(:authors, type: :binary_id, on_delete: :nothing))
    end

    alter(table(:blogs, prefix: :publishing)) do
      modify(:theme_id, references(:themes, type: :binary_id, on_delete: :nothing))
    end

    alter(table(:comments, prefix: :publishing)) do
      modify(:author_id, references(:authors, type: :binary_id, on_delete: :nothing))
    end

    alter(table(:comments, prefix: :publishing)) do
      modify(:post_id, references(:posts, type: :binary_id, on_delete: :nothing))
    end

    alter(table(:posts, prefix: :publishing)) do
      modify(:author_id, references(:authors, type: :binary_id, on_delete: :nothing))
    end

    alter(table(:posts, prefix: :publishing)) do
      modify(:blog_id, references(:blogs, type: :binary_id, on_delete: :nothing))
    end

    create(
      unique_index(:blogs, [:author_id, :name],
        name: :blogs_author_id_name_idx,
        prefix: :publishing
      )
    )

    create(unique_index(:themes, [:name], name: :themes_name_idx, prefix: :publishing))
  end

  def down do
    []
  end
end
