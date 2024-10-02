import games.{Backend, Frontend}
import games/rock_card_scissors/backend
import games/rock_card_scissors/frontend

pub fn game() {
  games.new(
    Backend(backend.init, backend.to_frontend),
    Frontend(frontend.init, frontend.update, frontend.view),
  )
}
