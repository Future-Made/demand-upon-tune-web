defmodule Tune.Repo.Migrations.AddArtistNameToDemand do
  use Ecto.Migration

  def change do
    alter table(:online_concert_demands) do
      add :artist_name, :string
    end
  end
end
