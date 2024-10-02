import gleam/option.{type Option}

pub type Card {
  Rock
  Paper
  Scissors
}

pub type Opponent {
  Opponent(hand_size: Int, deck_size: Int)
}

pub type Props {
  Props(
    selected_card: Option(Int),
    hand: List(Card),
    deck_size: Int,
    opponent: Opponent,
  )
}

pub type FrontendMsg {
  UserClickedCard(index: Int)
  CardSelected(index: Int)
}
