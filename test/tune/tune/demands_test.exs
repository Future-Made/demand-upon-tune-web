defmodule Tune.Tune.DemandsTest do
  use Tune.DataCase

  alias Tune.Tune.Demands

  describe "online_concert_demands" do
    alias Tune.Tune.Demands.OnlineConcertDemand

    @valid_attrs %{artist_id: "some artist_id", can_offer_help: true, charitable_percentage: 42, demand_as_multipass: true, demand_on_air_months: 42, have_slow_internet: true, note_to_artist: "some note_to_artist", requested_songs: [], user_id: 42, will_support_causes: [], willing_to_pay_max: 42, willing_to_pay_min: 42}
    @update_attrs %{artist_id: "some updated artist_id", can_offer_help: false, charitable_percentage: 43, demand_as_multipass: false, demand_on_air_months: 43, have_slow_internet: false, note_to_artist: "some updated note_to_artist", requested_songs: [], user_id: 43, will_support_causes: [], willing_to_pay_max: 43, willing_to_pay_min: 43}
    @invalid_attrs %{artist_id: nil, can_offer_help: nil, charitable_percentage: nil, demand_as_multipass: nil, demand_on_air_months: nil, have_slow_internet: nil, note_to_artist: nil, requested_songs: nil, user_id: nil, will_support_causes: nil, willing_to_pay_max: nil, willing_to_pay_min: nil}

    def online_concert_demand_fixture(attrs \\ %{}) do
      {:ok, online_concert_demand} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Demands.create_online_concert_demand()

      online_concert_demand
    end

    test "list_online_concert_demands/0 returns all online_concert_demands" do
      online_concert_demand = online_concert_demand_fixture()
      assert Demands.list_online_concert_demands() == [online_concert_demand]
    end

    test "get_online_concert_demand!/1 returns the online_concert_demand with given id" do
      online_concert_demand = online_concert_demand_fixture()
      assert Demands.get_online_concert_demand!(online_concert_demand.id) == online_concert_demand
    end

    test "create_online_concert_demand/1 with valid data creates a online_concert_demand" do
      assert {:ok, %OnlineConcertDemand{} = online_concert_demand} = Demands.create_online_concert_demand(@valid_attrs)
      assert online_concert_demand.artist_id == "some artist_id"
      assert online_concert_demand.can_offer_help == true
      assert online_concert_demand.charitable_percentage == 42
      assert online_concert_demand.demand_as_multipass == true
      assert online_concert_demand.demand_on_air_months == 42
      assert online_concert_demand.have_slow_internet == true
      assert online_concert_demand.note_to_artist == "some note_to_artist"
      assert online_concert_demand.requested_songs == []
      assert online_concert_demand.user_id == 42
      assert online_concert_demand.will_support_causes == []
      assert online_concert_demand.willing_to_pay_max == 42
      assert online_concert_demand.willing_to_pay_min == 42
    end

    test "create_online_concert_demand/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Demands.create_online_concert_demand(@invalid_attrs)
    end

    test "update_online_concert_demand/2 with valid data updates the online_concert_demand" do
      online_concert_demand = online_concert_demand_fixture()
      assert {:ok, %OnlineConcertDemand{} = online_concert_demand} = Demands.update_online_concert_demand(online_concert_demand, @update_attrs)
      assert online_concert_demand.artist_id == "some updated artist_id"
      assert online_concert_demand.can_offer_help == false
      assert online_concert_demand.charitable_percentage == 43
      assert online_concert_demand.demand_as_multipass == false
      assert online_concert_demand.demand_on_air_months == 43
      assert online_concert_demand.have_slow_internet == false
      assert online_concert_demand.note_to_artist == "some updated note_to_artist"
      assert online_concert_demand.requested_songs == []
      assert online_concert_demand.user_id == 43
      assert online_concert_demand.will_support_causes == []
      assert online_concert_demand.willing_to_pay_max == 43
      assert online_concert_demand.willing_to_pay_min == 43
    end

    test "update_online_concert_demand/2 with invalid data returns error changeset" do
      online_concert_demand = online_concert_demand_fixture()
      assert {:error, %Ecto.Changeset{}} = Demands.update_online_concert_demand(online_concert_demand, @invalid_attrs)
      assert online_concert_demand == Demands.get_online_concert_demand!(online_concert_demand.id)
    end

    test "delete_online_concert_demand/1 deletes the online_concert_demand" do
      online_concert_demand = online_concert_demand_fixture()
      assert {:ok, %OnlineConcertDemand{}} = Demands.delete_online_concert_demand(online_concert_demand)
      assert_raise Ecto.NoResultsError, fn -> Demands.get_online_concert_demand!(online_concert_demand.id) end
    end

    test "change_online_concert_demand/1 returns a online_concert_demand changeset" do
      online_concert_demand = online_concert_demand_fixture()
      assert %Ecto.Changeset{} = Demands.change_online_concert_demand(online_concert_demand)
    end
  end
end
