defmodule Tune.Repo.Migrations.AddSpotifyImgUrl do
  use Ecto.Migration

  def change do
    alter table(:online_concert_demands) do
      add :spotify_profile_img_url, :string
    end
  end
end
