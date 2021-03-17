defmodule Tune.Repo.Migrations.AddThumbnailsToDemandAsMultipleField do
    use Ecto.Migration

    def change do
      alter table(:online_concert_demands) do
        remove :artist_thumbnails, {:array, :string}
        add :artist_thumbnail_small, :string
        add :artist_thumbnail_medium, :string
        add :artist_thumbnail_large, :string
      end
    end

end
