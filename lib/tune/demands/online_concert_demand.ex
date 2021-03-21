defmodule Tune.Demands.OnlineConcertDemand do
  use Ecto.Schema
  import Ecto.Changeset

  schema "online_concert_demands" do
    field(:artist_id, :string)  # for now, artists' spotify user id.
    field(:artist_name, :string)

    field(:artist_thumbnail_small, :string)
    field(:artist_thumbnail_medium, :string)
    field(:artist_thumbnail_large, :string)

    field(:is_tributable, :boolean) # in case artist or band is not active in their careers.

    field(:user_id, :string)    # same as spotify user id (username), for now.
    field(:spotify_profile_img_url, :string)

    field(:charitable_percentage, :integer, default: 0)
    field(:demand_as_multipass, :boolean)
    field(:have_slow_internet, :boolean)
    field(:will_support_causes, {:array, :string})

    field(:event_related_helps_offered, {:array, :string})
    field(:skills_offered_for_public, {:array, :string})
    field(:other_skills_offered, :string)
    field(:time_offer_for_skills_in_mins, :integer, default: 0)

    field(:willing_to_pay_min, :integer, default: 0)
    field(:willing_to_pay_max, :integer, default: 0)

    field(:note_to_artist, :string)


    field(:preferred_broadcasters, {:array, :string})
    field(:streaming_platforms, {:array, :string})

    field(:suggested_streaming_platforms, :string)
    field(:suggested_radios, :string)


    field(:requested_songs, {:array, :string})

    field(:demand_on_air_months, :integer)
    timestamps()
  end

  @spec changeset(
          {map, map}
          | %{
              :__struct__ => atom | %{:__changeset__ => map, optional(any) => any},
              optional(atom) => any
            },
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(online_concert_demand, attrs) do
    online_concert_demand
    |> cast(
      attrs,
      [
        :user_id,
        :artist_id,
        :artist_name,
        :artist_thumbnail_small,
        :artist_thumbnail_medium,
        :artist_thumbnail_large,
        :is_tributable,
        :spotify_profile_img_url,
        :event_related_helps_offered,
        :skills_offered_for_public,
        :other_skills_offered,
        :time_offer_for_skills_in_mins,
        :have_slow_internet,
        :will_support_causes,
        :willing_to_pay_min,
        :willing_to_pay_max,
        :preferred_broadcasters,
        :streaming_platforms,
        :suggested_streaming_platforms,
        :suggested_radios,
        :charitable_percentage,
        :demand_as_multipass,
        :demand_on_air_months,
        :note_to_artist,
      ]
    )
    |> validate_required([
      :user_id,
      :artist_name,
      :willing_to_pay_min,
      :willing_to_pay_max,
      :demand_on_air_months,
    ])
  end
end
