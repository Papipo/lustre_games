import games/rock_card_scissors as rcs
import games/rock_card_scissors/backend
import gleam/dict
import lustre
import viewport.{Model}

pub fn main() {
  let player_ids = ["1", "2"]
  let game = rcs.game()
  let state = game.backend.init(player_ids)
  let props =
    Model(
      player_ids: player_ids,
      client_props: fn(player_id) { backend.to_frontend(state, player_id) },
      frontend: game.frontend,
      clients: dict.new(),
    )
  let assert Ok(_) =
    viewport.app()
    |> lustre.start("#app", props)
}
