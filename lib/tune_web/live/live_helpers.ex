defmodule TuneWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  @doc """
  Renders a component inside the `TuneWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, TuneWeb.OnlineConcertDemandLive.FormComponent,
        id: @online_concert_demand.id || :new,
        action: @live_action,
        online_concert_demand: @online_concert_demand,
        return_to: Routes.online_concert_demand_index_path(@socket, :index) %>
  """
  def live_modal(socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(socket, TuneWeb.ModalComponent, modal_opts)
  end
end
