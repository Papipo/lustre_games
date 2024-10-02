import games/rock_card_scissors/shared.{
  type Card, type Props as Model, Paper, Props as Model, Rock, Scissors,
}
import gleam/int
import gleam/list
import gleam/option.{type Option, Some}
import lustre/attribute.{attribute}
import lustre/attribute as attr
import lustre/effect
import lustre/element/html as h
import lustre/element/svg
import lustre/event

pub type Msg {
  UserClickedCard(index: Int)
  CardSelected(index: Int)
}

pub fn init(props: Model) {
  props
}

pub fn update(model, msg: Msg) {
  case msg {
    UserClickedCard(index) -> #(model, select_card(index))

    CardSelected(index) -> {
      let model = Model(..model, selected_card: Some(index))
      #(model, effect.none())
    }
  }
}

pub fn view(props: Model) {
  h.div([attr.class("flex flex-col justify-between h-full")], [
    h.div([attr.class("grid grid-cols-4 gap-4 p-4")], [
      deck(props.opponent.deck_size),
      h.div([attr.class("col-span-3")], [
        facedown_hand(props.opponent.hand_size),
      ]),
    ]),
    h.div([attr.class("grid grid-cols-4 gap-4 p-4")], [
      h.div([], [deck(props.deck_size)]),
      h.div([attr.class("col-span-3")], [hand(props.hand, props.selected_card)]),
    ]),
  ])
}

fn hand(cards: List(Card), selected: Option(Int)) {
  h.div([attr.class("flex justify-center gap-4 px-4 h-full")], {
    use item, index <- list.index_map(cards)
    card(item, [
      attr.classes([
        #("border-2 border-teal-500", index == option.unwrap(selected, -1)),
      ]),
      event.on_click(UserClickedCard(index)),
    ])
  })
}

fn card(card: Card, attrs) {
  h.div(
    list.concat([
      attrs,
      [
        attr.class("flex flex-col justify-center bg-slate-100"),
        attr.class(card_class()),
      ],
    ]),
    [face(card)],
  )
}

fn facedown_hand(size: Int) {
  h.div(
    [attr.class("flex justify-center gap-4 px-4 h-full")],
    list.repeat(
      h.div(
        [
          attr.class(
            "border flex justify-center items-center text-3xl bg-slate-700 text-white "
            <> card_class(),
          ),
        ],
        [],
      ),
      size,
    ),
  )
}

fn face(card: Card) {
  case card {
    Paper -> icon(scroll)
    Rock -> icon(rock)
    Scissors -> icon(scissors)
  }
}

fn deck(size: Int) {
  h.div(
    [
      attr.class(
        "border flex justify-center items-center text-3xl bg-slate-700 text-white "
        <> card_class(),
      ),
    ],
    {
      case size <= 0 {
        True -> [h.text("0")]
        False -> [h.text(size |> int.to_string())]
      }
    },
  )
}

fn card_class() {
  "border rounded shadow aspect-[25/35] p-4 border-slate-300 w-full"
}

fn icon(path: fn() -> String) {
  svg.svg(
    [
      attr.class("max-w-full max-h-full aspect-square"),
      attribute("fill", "#000000"),
      attribute("viewBox", "0 0 256 256"),
      attribute("xmlns", "http://www.w3.org/2000/svg"),
    ],
    [svg.path([attribute("d", path())])],
  )
}

fn rock() {
  "M200,80H184V64a32,32,0,0,0-56-21.13A32,32,0,0,0,72.21,60.42,32,32,0,0,0,24,88v40a104,104,0,0,0,208,0V112A32,32,0,0,0,200,80ZM152,48a16,16,0,0,1,16,16V80H136V64A16,16,0,0,1,152,48ZM88,64a16,16,0,0,1,32,0v40a16,16,0,0,1-32,0ZM40,88a16,16,0,0,1,32,0v16a16,16,0,0,1-32,0Zm176,40a88,88,0,0,1-175.92,3.75A31.93,31.93,0,0,0,80,125.13a31.93,31.93,0,0,0,44.58,3.35,32.21,32.21,0,0,0,11.8,11.44A47.88,47.88,0,0,0,120,176a8,8,0,0,0,16,0,32,32,0,0,1,32-32,8,8,0,0,0,0-16H152a16,16,0,0,1-16-16V96h64a16,16,0,0,1,16,16Z"
}

fn scroll() {
  "M96,104a8,8,0,0,1,8-8h64a8,8,0,0,1,0,16H104A8,8,0,0,1,96,104Zm8,40h64a8,8,0,0,0,0-16H104a8,8,0,0,0,0,16Zm128,48a32,32,0,0,1-32,32H88a32,32,0,0,1-32-32V64a16,16,0,0,0-32,0c0,5.74,4.83,9.62,4.88,9.66h0A8,8,0,0,1,24,88a7.89,7.89,0,0,1-4.79-1.61h0C18.05,85.54,8,77.61,8,64A32,32,0,0,1,40,32H176a32,32,0,0,1,32,32V168h8a8,8,0,0,1,4.8,1.6C222,170.46,232,178.39,232,192ZM96.26,173.48A8.07,8.07,0,0,1,104,168h88V64a16,16,0,0,0-16-16H67.69A31.71,31.71,0,0,1,72,64V192a16,16,0,0,0,32,0c0-5.74-4.83-9.62-4.88-9.66A7.82,7.82,0,0,1,96.26,173.48ZM216,192a12.58,12.58,0,0,0-3.23-8h-94a26.92,26.92,0,0,1,1.21,8,31.82,31.82,0,0,1-4.29,16H200A16,16,0,0,0,216,192Z"
}

fn scissors() {
  "M157.73,113.13A8,8,0,0,1,159.82,102L227.48,55.7a8,8,0,0,1,9,13.21l-67.67,46.3a7.92,7.92,0,0,1-4.51,1.4A8,8,0,0,1,157.73,113.13Zm80.87,85.09a8,8,0,0,1-11.12,2.08L136,137.7,93.49,166.78a36,36,0,1,1-9-13.19L121.83,128,84.44,102.41a35.86,35.86,0,1,1,9-13.19l143,97.87A8,8,0,0,1,238.6,198.22ZM80,180a20,20,0,1,0-5.86,14.14A19.85,19.85,0,0,0,80,180ZM74.14,90.13a20,20,0,1,0-28.28,0A19.85,19.85,0,0,0,74.14,90.13Z"
}

fn select_card(index) {
  use dispatch <- effect.from()
  dispatch(CardSelected(index))
}
