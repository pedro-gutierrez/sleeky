defmodule(Bee.Migration.V1) do
  use(Ecto.Migration)

  def(up) do
    create(table(:comments, primary_key: false)) do
      add(:id, :uuid, primary_key: true, null: false)
      add(:text, :string, null: false)
      add(:post_id, :uuid, null: false)
      add(:user_id, :uuid, null: false)
      timestamps()
    end

    create(table(:posts, primary_key: false)) do
      add(:id, :uuid, primary_key: true, null: false)
      add(:subject, :string, null: false)
      add(:slug, :string, null: false)
      add(:user_id, :uuid, null: false)
      timestamps()
    end

    create(table(:tags, primary_key: false)) do
      add(:id, :uuid, primary_key: true, null: false)
      add(:name, :string, null: false)
      add(:post_id, :uuid, null: false)
      timestamps()
    end

    create(table(:users, primary_key: false)) do
      add(:id, :uuid, primary_key: true, null: false)
      add(:email, :string, null: false)
      timestamps()
    end

    create(table(:votes, primary_key: false)) do
      add(:id, :uuid, primary_key: true, null: false)
      add(:vote, :integer, null: false)
      add(:comment_id, :uuid, null: false)
      add(:user_id, :uuid, null: false)
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
  end

  def(down) do
    []
  end
end