import lustre/effect.{type Effect}
import lustre/element.{type Element}

pub type PlayerId =
  String

pub type Frontend(props, model, msg) {
  Frontend(
    init: fn(props) -> model,
    update: fn(model, msg) -> #(model, Effect(msg)),
    view: fn(model) -> Element(msg),
  )
}

pub type Backend(opts, state, props) {
  Backend(init: fn(opts) -> state, to_frontend: fn(state, PlayerId) -> props)
}

pub type Game(opts, state, props, model, msg) {
  Game(
    backend: Backend(opts, state, props),
    frontend: Frontend(props, model, msg),
  )
}

pub fn new(
  backend: Backend(opts, state, props),
  frontend: Frontend(props, model, msg),
) -> Game(opts, state, props, model, msg) {
  Game(backend: backend, frontend: frontend)
}
