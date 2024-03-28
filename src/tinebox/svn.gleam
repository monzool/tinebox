import gleam/io
import gleam/list
import gleam/result
import gleam/string
import shellout
import tinebox/print

fn print_svn(svn_result: Result(String, #(Int, String))) {
  svn_result
  |> result.map(with: fn(output) {
    output
    |> shellout.style(with: print.get_style(), custom: print.lookups)
    |> io.print
    0
  })
  |> result.map_error(with: fn(detail) {
    let #(status, message) = detail
    message
    |> shellout.style(with: print.get_style_error(), custom: print.lookups)
    |> io.print_error
    status
  })
  |> result.unwrap_both
}

pub fn svn_list(repo) {
  shellout.command(run: "svn", with: ["ls"], in: repo, opt: [])
  |> print_svn
}

pub fn svn_status(repo) {
  shellout.command(run: "svn", with: ["st", "-q"], in: repo, opt: [])
  |> print_svn
}

pub fn svn_add(repo, files) {
  shellout.command(
    run: "svn",
    with: ["add", "--non-interactive", ..files],
    in: repo,
    opt: [],
  )
  |> print_svn
}

pub fn svn_list_updated(repo) {
  let f =
    shellout.command(
      run: "bash",
      with: [
        "-euc", "-o", "pipefail",
        "svn st -q | sed -E 's/^[[:space:]]*[AM][[:space:]]+//'",
      ],
      in: repo,
      opt: [],
    )
    |> result.map(fn(raw) {
      let lines = string.split(raw, on: "\n")
      let items = list.filter(lines, fn(item) { !string.is_empty(item) })
      items
    })
  f
}
