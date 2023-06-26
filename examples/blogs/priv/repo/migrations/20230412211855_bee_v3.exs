defmodule Bee.Migration.V3 do
  use Ecto.Migration

  def up do
    create(table(:cases, primary_key: false)) do
      add(:display, :string, [])
      add(:id, :uuid, primary_key: true)
      add(:name, :string, [])
      add(:user_id, :uuid, [])
      timestamps()
    end

    alter(table(:cases)) do
      modify(:user_id, references(:users, type: :uuid, null: false, on_delete: :nothing))
    end

    create(unique_index(:cases, [:name], name: :cases_name_idx))
    drop_if_exists(constraint(:comments, :comments_post_id_fkey))
    drop_if_exists(constraint(:comments, :comments_user_id_fkey))
    drop_if_exists(constraint(:posts, :posts_user_id_fkey))
    drop_if_exists(constraint(:tags, :tags_post_id_fkey))
    drop_if_exists(constraint(:votes, :votes_comment_id_fkey))
    drop_if_exists(constraint(:votes, :votes_user_id_fkey))
    drop_if_exists(index(:posts, [], name: :posts_slug_idx))
    drop_if_exists(index(:posts, [], name: :posts_user_id_subject_idx))
    drop_if_exists(table(:comments))
    drop_if_exists(table(:countries))
    drop_if_exists(table(:posts))
    drop_if_exists(table(:tags))
    drop_if_exists(table(:votes))
    execute("drop type sentiment")
  end

  def down do
    []
  end
end