defmodule TuneWeb.OnlineConcertDemandLiveTest do
  use TuneWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Tune.Demands

  @create_attrs %{
    can_offer_help: true,
    charitable_percentage: 42,
    demand_as_multipass: true,
    demand_on_air_months: 42,
    have_slow_internet: true,
    note_to_artist: "some note_to_artist",
    requested_songs: [],
    supported_causes: [],
    will_support_causes: [],
    willing_to_pay_max: 42,
    willing_to_pay_min: 42
  }
  @update_attrs %{
    can_offer_help: false,
    charitable_percentage: 43,
    demand_as_multipass: false,
    demand_on_air_months: 43,
    have_slow_internet: false,
    note_to_artist: "some updated note_to_artist",
    requested_songs: [],
    supported_causes: [],
    will_support_causes: [],
    willing_to_pay_max: 43,
    willing_to_pay_min: 43
  }
  @invalid_attrs %{
    can_offer_help: nil,
    charitable_percentage: nil,
    demand_as_multipass: nil,
    demand_on_air_months: nil,
    have_slow_internet: nil,
    note_to_artist: nil,
    requested_songs: nil,
    supported_causes: nil,
    will_support_causes: nil,
    willing_to_pay_max: nil,
    willing_to_pay_min: nil
  }

  defp fixture(:online_concert_demand) do
    {:ok, online_concert_demand} = Demands.create_online_concert_demand(@create_attrs)
    online_concert_demand
  end

  defp create_online_concert_demand(_) do
    online_concert_demand = fixture(:online_concert_demand)
    %{online_concert_demand: online_concert_demand}
  end

  describe "Index" do
    setup [:create_online_concert_demand]

    test "lists all online_concert_demands", %{
      conn: conn,
      online_concert_demand: online_concert_demand
    } do
      {:ok, _index_live, html} = live(conn, Routes.online_concert_demand_index_path(conn, :index))

      assert html =~ "Listing Online concert demands"
      assert html =~ online_concert_demand.note_to_artist
    end

    test "saves new online_concert_demand", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.online_concert_demand_index_path(conn, :index))

      assert index_live |> element("a", "New Online concert demand") |> render_click() =~
               "New Online concert demand"

      assert_patch(index_live, Routes.online_concert_demand_index_path(conn, :new))

      assert index_live
             |> form("#online_concert_demand-form", online_concert_demand: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#online_concert_demand-form", online_concert_demand: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.online_concert_demand_index_path(conn, :index))

      assert html =~ "Online concert demand created successfully"
      assert html =~ "some note_to_artist"
    end

    test "updates online_concert_demand in listing", %{
      conn: conn,
      online_concert_demand: online_concert_demand
    } do
      {:ok, index_live, _html} = live(conn, Routes.online_concert_demand_index_path(conn, :index))

      assert index_live
             |> element("#online_concert_demand-#{online_concert_demand.id} a", "Edit")
             |> render_click() =~
               "Edit Online concert demand"

      assert_patch(
        index_live,
        Routes.online_concert_demand_index_path(conn, :edit, online_concert_demand)
      )

      assert index_live
             |> form("#online_concert_demand-form", online_concert_demand: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#online_concert_demand-form", online_concert_demand: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.online_concert_demand_index_path(conn, :index))

      assert html =~ "Online concert demand updated successfully"
      assert html =~ "some updated note_to_artist"
    end

    test "deletes online_concert_demand in listing", %{
      conn: conn,
      online_concert_demand: online_concert_demand
    } do
      {:ok, index_live, _html} = live(conn, Routes.online_concert_demand_index_path(conn, :index))

      assert index_live
             |> element("#online_concert_demand-#{online_concert_demand.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#online_concert_demand-#{online_concert_demand.id}")
    end
  end

  describe "Show" do
    setup [:create_online_concert_demand]

    test "displays online_concert_demand", %{
      conn: conn,
      online_concert_demand: online_concert_demand
    } do
      {:ok, _show_live, html} =
        live(conn, Routes.online_concert_demand_show_path(conn, :show, online_concert_demand))

      assert html =~ "Show Online concert demand"
      assert html =~ online_concert_demand.note_to_artist
    end

    test "updates online_concert_demand within modal", %{
      conn: conn,
      online_concert_demand: online_concert_demand
    } do
      {:ok, show_live, _html} =
        live(conn, Routes.online_concert_demand_show_path(conn, :show, online_concert_demand))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Online concert demand"

      assert_patch(
        show_live,
        Routes.online_concert_demand_show_path(conn, :edit, online_concert_demand)
      )

      assert show_live
             |> form("#online_concert_demand-form", online_concert_demand: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#online_concert_demand-form", online_concert_demand: @update_attrs)
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.online_concert_demand_show_path(conn, :show, online_concert_demand)
        )

      assert html =~ "Online concert demand updated successfully"
      assert html =~ "some updated note_to_artist"
    end
  end
end
