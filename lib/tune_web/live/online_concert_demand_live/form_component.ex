defmodule TuneWeb.OnlineConcertDemandLive.FormComponent do
  use TuneWeb, :live_component

  alias Tune.Demands

  @impl true
  def update(%{online_concert_demand: online_concert_demand} = assigns, socket) do
    changeset = Demands.change_online_concert_demand(online_concert_demand)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"online_concert_demand" => online_concert_demand_params}, socket) do
    changeset =
      socket.assigns.online_concert_demand
      |> Demands.change_online_concert_demand(online_concert_demand_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"online_concert_demand" => online_concert_demand_params}, socket) do
    save_online_concert_demand(socket, socket.assigns.action, online_concert_demand_params)
  end

  defp save_online_concert_demand(socket, :edit, online_concert_demand_params) do
    case Demands.update_online_concert_demand(
           socket.assigns.online_concert_demand,
           online_concert_demand_params
         ) do
      {:ok, _online_concert_demand} ->
        {:noreply,
         socket
         |> put_flash(:info, "Online concert demand updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_online_concert_demand(socket, :new, online_concert_demand_params) do
    case Demands.create_online_concert_demand(online_concert_demand_params) do
      {:ok, _online_concert_demand} ->
        {:noreply,
         socket
         |> put_flash(:info, "Online concert demand created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
