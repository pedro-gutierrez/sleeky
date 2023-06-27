defmodule Bee.Migration.V1 do
  use Ecto.Migration

  def up do
    create(table(:blogs, primary_key: false)) do
      add(:display, :string, [])
      add(:id, :uuid, primary_key: true)
      add(:name, :string, [])
      add(:user_id, :uuid, [])
      timestamps()
    end

    create(table(:comments, primary_key: false)) do
      add(:display, :string, [])
      add(:id, :uuid, primary_key: true)
      add(:post_id, :uuid, [])
      add(:text, :string, [])
      timestamps()
    end

    create(table(:posts, primary_key: false)) do
      add(:blog_id, :uuid, [])
      add(:display, :string, [])
      add(:id, :uuid, primary_key: true)
      add(:slug, :string, [])
      add(:title, :string, [])
      timestamps()
    end

    create(table(:users, primary_key: false)) do
      add(:display, :string, [])
      add(:email, :string, [])
      add(:id, :uuid, primary_key: true)
      timestamps()
    end

    alter(table(:blogs)) do
      modify(:user_id, references(:users, type: :uuid, null: false, on_delete: :nothing))
    end

    alter(table(:comments)) do
      modify(:post_id, references(:posts, type: :uuid, null: false, on_delete: :nothing))
    end

    alter(table(:posts)) do
      modify(:blog_id, references(:blogs, type: :uuid, null: false, on_delete: :nothing))
    end

    create(unique_index(:blogs, [:name], name: :blogs_name_idx))
    create(index(:posts, [:blog_id, :title], name: :posts_blog_id_title_idx))
    create(unique_index(:posts, [:slug], name: :posts_slug_idx))
    create(unique_index(:users, [:email], name: :users_email_idx))
  end

  def down do
    []
  end
end