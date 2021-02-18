defmodule Tune.Demands.OnlineConcertDemand do
  use Ecto.Schema
  import Ecto.Changeset

  schema "online_concert_demands" do
    field(:can_offer_help, :boolean, default: false)
    field(:charitable_percentage, :integer)
    field(:demand_as_multipass, :boolean, default: false)
    field(:demand_on_air_months, :integer)
    field(:have_slow_internet, :boolean, default: false)
    field(:note_to_artist, :string)
    field(:requested_songs, {:array, :string})
    field(:supported_causes, {:array, :string})
    field(:will_support_causes, {:array, :string})
    field(:willing_to_pay_max, :integer)
    field(:willing_to_pay_min, :integer)

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
    |> cast(attrs, [
      :willing_to_pay_min,
      :willing_to_pay_max,
      :have_slow_internet,
      :will_support_causes,
      :charitable_percentage,
      :demand_as_multipass,
      :demand_on_air_months,
      :supported_causes,
      :requested_songs,
      :note_to_artist,
      :can_offer_help
    ])
    |> validate_required([:willing_to_pay_min, :willing_to_pay_max, :demand_on_air_months])
  end
end
