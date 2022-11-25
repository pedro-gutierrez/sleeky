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
  end

  def(down) do
    []
  end
end