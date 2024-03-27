import gleam/dict
import shellout.{type Lookups}

pub fn get_style() {
  let style =
    shellout.display(["bold", "normal"])
    |> dict.merge(from: shellout.color(["pink"]))
  style
}

pub fn get_style_error() {
  let error_style =
    shellout.display(["bold", "italic"])
    |> dict.merge(from: shellout.color(["red"]))
    |> dict.merge(from: shellout.background(["brightblack"]))
  error_style
}

pub const lookups: Lookups = [
  #(
    ["color", "background"],
    [
      #("buttercup", ["252", "226", "174"]),
      #("mint", ["182", "255", "234"]),
      #("pink", ["255", "175", "243"]),
    ],
  ),
]
