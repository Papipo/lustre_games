import games.{type PlayerId}
import games/rock_card_scissors/backend
import games/rock_card_scissors/frontend
import gleam/dict.{type Dict}
import gleam/list
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element
import lustre/element/html

pub fn main() {
  let assert Ok(_) = lustre.start(app(), "#app", ["1", "2"])
}

pub type Msg {
  Msg(player_id: PlayerId, wrapped: frontend.Msg)
}

pub type Model {
  Model(
    player_ids: List(PlayerId),
    clients: Dict(PlayerId, frontend.Model),
    backend: backend.State,
  )
}

pub fn app() {
  lustre.application(init, update, view)
}

fn init(player_ids) {
  let backend_state = backend.init(player_ids)
  let clients =
    {
      use player_id <- list.map(player_ids)
      #(
        player_id,
        backend_state |> backend.view_props(player_id) |> frontend.init(),
      )
    }
    |> dict.from_list

  #(
    Model(player_ids: player_ids, backend: backend_state, clients: clients),
    effect.none(),
  )
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  let #(new_state, effect) =
    client_state(model, msg.player_id)
    |> frontend.update(msg.wrapped)

  let clients = model.clients |> dict.insert(msg.player_id, new_state)
  #(Model(..model, clients: clients), effect |> wrap_effect(msg.player_id))
}

fn view(model: Model) {
  html.div(
    [attribute.class("flex gap-4 justify-evenly h-full p-4")],
    list.map(model.player_ids, client_view(model, _)),
  )
}

fn client_view(model: Model, player_id) {
  html.div([attribute.class("border h-full w-full flex flex-col gap2")], [
    html.h1([attribute.class("text-center bg-teal-400")], [
      html.text("Player #" <> player_id),
    ]),
    html.div([attribute.class("flex-1")], [
      model
      |> client_state(player_id)
      |> frontend.view()
      |> wrap_element(player_id),
    ]),
  ])
}

fn client_state(model: Model, player_id) {
  let assert Ok(state) = dict.get(model.clients, player_id)
  state
}

fn wrap_element(e, player_id) {
  use wrapped <- element.map(e)
  Msg(wrapped: wrapped, player_id: player_id)
}

fn wrap_effect(e, player_id) {
  effect.map(e, Msg(player_id, _))
}
