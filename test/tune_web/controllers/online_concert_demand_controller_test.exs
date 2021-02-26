defmodule TuneWeb.OnlineConcertDemandControllerTest do
  use TuneWeb.ConnCase

  alias Tune.Tune.Demands

  @create_attrs %{artist_id: "some artist_id", can_offer_help: true, charitable_percentage: 42, demand_as_multipass: true, demand_on_air_months: 42, have_slow_internet: true, note_to_artist: "some note_to_artist", requested_songs: [], user_id: 42, will_support_causes: [], willing_to_pay_max: 42, willing_to_pay_min: 42}
  @update_attrs %{artist_id: "some updated artist_id", can_offer_help: false, charitable_percentage: 43, demand_as_multipass: false, demand_on_air_months: 43, have_slow_internet: false, note_to_artist: "some updated note_to_artist", requested_songs: [], user_id: 43, will_support_causes: [], willing_to_pay_max: 43, willing_to_pay_min: 43}
  @invalid_attrs %{artist_id: nil, can_offer_help: nil, charitable_percentage: nil, demand_as_multipass: nil, demand_on_air_months: nil, have_slow_internet: nil, note_to_artist: nil, requested_songs: nil, user_id: nil, will_support_causes: nil, willing_to_pay_max: nil, willing_to_pay_min: nil}

  def fixture(:online_concert_demand) do
    {:ok, online_concert_demand} = Demands.create_online_concert_demand(@create_attrs)
    online_concert_demand
  end

  describe "index" do
    test "lists all online_concert_demands", %{conn: conn} do
      conn = get(conn, Routes.online_concert_demand_path(conn, :index))
      assert html_response(conn, 200) =~ "your online concert demands"
    end
  end

  describe "new online_concert_demand" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.online_concert_demand_path(conn, :new))
      assert html_response(conn, 200) =~ "New Online concert demand"
    end
  end

  describe "create online_concert_demand" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.online_concert_demand_path(conn, :create), online_concert_demand: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.online_concert_demand_path(conn, :show, id)

      conn = get(conn, Routes.online_concert_demand_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Online concert demand"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.online_concert_demand_path(conn, :create), online_concert_demand: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Online concert demand"
    end
  end

  describe "edit online_concert_demand" do
    setup [:create_online_concert_demand]

    test "renders form for editing chosen online_concert_demand", %{conn: conn, online_concert_demand: online_concert_demand} do
      conn = get(conn, Routes.online_concert_demand_path(conn, :edit, online_concert_demand))
      assert html_response(conn, 200) =~ "Update your demand"
    end
  end

  describe "update online_concert_demand" do
    setup [:create_online_concert_demand]

    test "redirects when data is valid", %{conn: conn, online_concert_demand: online_concert_demand} do
      conn = put(conn, Routes.online_concert_demand_path(conn, :update, online_concert_demand), online_concert_demand: @update_attrs)
      assert redirected_to(conn) == Routes.online_concert_demand_path(conn, :show, online_concert_demand)

      conn = get(conn, Routes.online_concert_demand_path(conn, :show, online_concert_demand))
      assert html_response(conn, 200) =~ "some updated artist_id"
    end

    test "renders errors when data is invalid", %{conn: conn, online_concert_demand: online_concert_demand} do
      conn = put(conn, Routes.online_concert_demand_path(conn, :update, online_concert_demand), online_concert_demand: @invalid_attrs)
      assert html_response(conn, 200) =~ "Update your demand"
    end
  end

  describe "delete online_concert_demand" do
    setup [:create_online_concert_demand]

    test "deletes chosen online_concert_demand", %{conn: conn, online_concert_demand: online_concert_demand} do
      conn = delete(conn, Routes.online_concert_demand_path(conn, :delete, online_concert_demand))
      assert redirected_to(conn) == Routes.online_concert_demand_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.online_concert_demand_path(conn, :show, online_concert_demand))
      end
    end
  end

  defp create_online_concert_demand(_) do
    online_concert_demand = fixture(:online_concert_demand)
    %{online_concert_demand: online_concert_demand}
  end
end
