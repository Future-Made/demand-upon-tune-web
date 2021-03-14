defmodule Tune.Demands.OnlineConcertDemand do
  use Ecto.Schema
  import Ecto.Changeset

  schema "online_concert_demands" do
    field(:artist_id, :string)  # artists' spotify user id
    field(:artist_name, :string)
    field(:user_id, :string)    # same as spotify user id (username), for now.
    field(:spotify_profile_img_url, :string)

    field(:charitable_percentage, :integer)
    field(:demand_as_multipass, :boolean, default: false)
    field(:have_slow_internet, :boolean, default: false)
    field(:will_support_causes, {:array, :string})

    field(:event_related_helps_offered, {:array, :string})
    field(:skills_offered_for_public, {:array, :string})
    field(:time_offer_for_skills_in_mins, :integer)

    field(:willing_to_pay_min, :integer)
    field(:willing_to_pay_max, :integer)

    field(:note_to_artist, :string)
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
        :spotify_profile_img_url,
        :event_related_helps_offered,
        :skills_offered_for_public,
        :time_offer_for_skills_in_mins,
        :have_slow_internet,
        :will_support_causes,
        :willing_to_pay_min,
        :willing_to_pay_max,
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
