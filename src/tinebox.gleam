import gleam/dict
import gleam/io
import gleam/result
import shellout.{type Lookups}

const svn_repo = "/home/jsso/tmp/repo_checkout"

fn get_style() {
  let style =
    shellout.display(["bold", "normal"])
    |> dict.merge(from: shellout.color(["pink"]))
  style
}

fn get_style_error() {
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

fn print_svn(svn_result: Result(String, #(Int, String))) {
  svn_result
  |> result.map(with: fn(output) {
    output
    |> shellout.style(with: get_style(), custom: lookups)
    |> io.print
    0
  })
  |> result.map_error(with: fn(detail) {
    let #(status, message) = detail
    message
    |> shellout.style(with: get_style_error(), custom: lookups)
    |> io.print_error
    status
  })
  |> result.unwrap_both
}

fn svn_list() {
  shellout.command(run: "svn", with: ["ls"], in: svn_repo, opt: [])
  |> print_svn
}

fn svn_status() {
  shellout.command(run: "svn", with: ["st"], in: svn_repo, opt: [])
  |> print_svn
}

pub fn main() {
  let rc = case shellout.arguments() {
    ["list"] -> svn_list()
    ["status"] -> svn_status()
    _ -> 0
  }
  rc
  |> shellout.exit
}
