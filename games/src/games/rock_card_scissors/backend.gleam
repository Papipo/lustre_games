import games.{type PlayerId}
import games/rock_card_scissors/shared.{
  type Card, Opponent, Paper, Props, Rock, Scissors,
}
import gleam/dict
import gleam/list
import gleam/option.{None}

pub type Deck =
  List(Card)

pub type Decks =
  dict.Dict(PlayerId, Deck)

pub type Hand =
  List(Card)

pub type Hands =
  dict.Dict(PlayerId, Hand)

pub type ChosenCards =
  dict.Dict(PlayerId, Int)

pub opaque type State {
  State(
    player_ids: List(PlayerId),
    decks: Decks,
    hands: Hands,
    chosen_cards: ChosenCards,
  )
}

pub fn to_frontend(state: State, player_id: PlayerId) {
  let opponent_id = opponent_id(state, player_id)
  let opponent =
    Opponent(
      hand_size: hand(state, opponent_id) |> list.length(),
      deck_size: deck(state, opponent_id) |> list.length(),
    )

  Props(
    selected_card: None,
    hand: hand(state, player_id),
    deck_size: deck(state, player_id) |> list.length(),
    opponent: opponent,
  )
}

pub fn init(player_ids: List(PlayerId)) {
  State(
    player_ids: list.shuffle(player_ids),
    decks: initialize_decks(player_ids),
    hands: initialize_hands(player_ids),
    chosen_cards: dict.new(),
  )
  |> draw_initial_hands
}

fn initialize_decks(player_ids: List(PlayerId)) -> Decks {
  player_ids
  |> list.map(fn(id) { #(id, initialize_deck()) })
  |> dict.from_list
}

fn initialize_deck() -> Deck {
  [Rock, Paper, Scissors]
  |> list.repeat(3)
  |> list.flatten
  |> list.shuffle
}

fn initialize_hands(player_ids: List(PlayerId)) -> Hands {
  player_ids
  |> list.map(fn(id) { #(id, []) })
  |> dict.from_list
}

fn draw_initial_hands(state: State) -> State {
  state
  |> each_player(draw)
  |> each_player(draw)
  |> each_player(draw)
}

fn draw(state: State, player_id: PlayerId) -> State {
  case deck(state, player_id) {
    [] -> state
    [card, ..deck] -> {
      let hand = hand(state, player_id)
      let new_decks = dict.insert(state.decks, player_id, deck)
      let new_hands = dict.insert(state.hands, player_id, [card, ..hand])

      State(..state, decks: new_decks, hands: new_hands)
    }
  }
}

// Utilities

fn deck(state: State, player_id: PlayerId) -> Deck {
  let assert Ok(deck) = dict.get(state.decks, player_id)
  deck
}

fn hand(state: State, player_id: PlayerId) -> Hand {
  let assert Ok(hand) = dict.get(state.hands, player_id)
  hand
}

fn opponent_id(state: State, player_id) {
  let assert Ok(id) = list.find(state.player_ids, fn(id) { id != player_id })
  id
}

fn each_player(state: State, fun) {
  list.fold(state.player_ids, state, fun)
}
