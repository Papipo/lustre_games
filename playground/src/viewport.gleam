import games.{type Frontend, type PlayerId}
import gleam/dict.{type Dict}
import gleam/list
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

pub type Msg(a) {
  ClientMsg(player_id: PlayerId, msg: a)
}

pub type Model(props, model, msg) {
  Model(
    player_ids: List(PlayerId),
    client_props: fn(PlayerId) -> props,
    frontend: Frontend(props, model, msg),
    clients: Dict(PlayerId, model),
  )
}

pub fn app() {
  lustre.simple(init, update, view)
}

fn init(model: Model(props, model, msg)) -> Model(props, model, msg) {
  let clients =
    {
      use player_id <- list.map(model.player_ids)
      #(player_id, model.client_props(player_id) |> model.frontend.init())
    }
    |> dict.from_list

  Model(..model, clients: clients)
}

fn update(
  model: Model(props, model, msg),
  msg: Msg(msg),
) -> Model(props, model, msg) {
  let state = client(model, msg.player_id)
  // TODO handle effect
  let #(new, _effect) = model.frontend.update(state, msg.msg)

  let clients = model.clients |> dict.insert(msg.player_id, new)
  Model(..model, clients: clients)
}

fn view(model: Model(props, model, msg)) -> Element(Msg(msg)) {
  html.div(
    [attribute.class("flex gap-4 justify-evenly h-full p-4")],
    list.map(model.player_ids, fn(player_id) {
      html.div([attribute.class("border h-full w-full flex flex-col gap2")], [
        html.h1([attribute.class("text-center bg-teal-400")], [
          html.text("Player #" <> player_id),
        ]),
        html.div([attribute.class("flex-1")], [
          element.text("Client view here"),
          model
            |> client(player_id)
            |> model.frontend.view()
            |> element.map(ClientMsg(player_id, _)),
        ]),
      ])
    }),
  )
}

fn client(model: Model(props, model, msg), player_id) -> model {
  let assert Ok(state) = dict.get(model.clients, player_id)
  state
}
