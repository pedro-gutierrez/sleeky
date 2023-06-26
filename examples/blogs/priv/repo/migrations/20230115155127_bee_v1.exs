defmodule Bee.Migration.V1 do
  use Ecto.Migration

  def up do
    execute("create type sentiment as ENUM ('positve','negative')")

    create(table(:comments, primary_key: false)) do
      add(:display, :string, [])
      add(:id, :uuid, primary_key: true)
      add(:post_id, :uuid, [])
      add(:sentiment, :sentiment, [])
      add(:text, :string, [])
      add(:user_id, :uuid, [])
      timestamps()
    end

    create(table(:posts, primary_key: false)) do
      add(:display, :string, [])
      add(:id, :uuid, primary_key: true)
      add(:slug, :string, [])
      add(:subject, :string, [])
      add(:user_id, :uuid, [])
      timestamps()
    end

    create(table(:tags, primary_key: false)) do
      add(:display, :string, [])
      add(:id, :uuid, primary_key: true)
      add(:name, :string, [])
      add(:post_id, :uuid, [])
      timestamps()
    end

    create(table(:users, primary_key: false)) do
      add(:app, :string, [])
      add(:display, :string, [])
      add(:email, :string, [])
      add(:id, :uuid, primary_key: true)
      timestamps()
    end

    create(table(:votes, primary_key: false)) do
      add(:comment_id, :uuid, [])
      add(:display, :string, [])
      add(:id, :uuid, primary_key: true)
      add(:user_id, :uuid, [])
      add(:vote, :integer, [])
      timestamps()
    end

    alter(table(:comments)) do
      modify(:post_id, references(:posts, type: :uuid, null: false, on_delete: :nothing))
    end

    alter(table(:comments)) do
      modify(:user_id, references(:users, type: :uuid, null: false, on_delete: :nothing))
    end

    alter(table(:posts)) do
      modify(:user_id, references(:users, type: :uuid, null: false, on_delete: :nothing))
    end

    alter(table(:tags)) do
      modify(:post_id, references(:posts, type: :uuid, null: false, on_delete: :nothing))
    end

    alter(table(:votes)) do
      modify(:comment_id, references(:comments, type: :uuid, null: false, on_delete: :nothing))
    end

    alter(table(:votes)) do
      modify(:user_id, references(:users, type: :uuid, null: false, on_delete: :nothing))
    end

    create(unique_index(:posts, [:slug], name: :posts_slug_idx))
    create(index(:posts, [:user_id, :subject], name: :posts_user_id_subject_idx))
    create(unique_index(:users, [:email], name: :users_email_idx))
  end

  def down do
    []
  end
end