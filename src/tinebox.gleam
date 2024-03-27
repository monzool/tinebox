import gleam/io
import gleam/result
import gleam/list
import shellout
import simplifile
import birl
import tinebox/svn

fn list_updated() {
  svn.svn_list_updated()
  |> io.debug

  // TODO: split out new directories, so they can be added with metadata also
  // splitting: https://hexdocs.pm/filepath/filepath.html#split

  0
}

type MetaData {
  MetaData(filename: String, mtime: Result(String, simplifile.FileError))
}

fn get_file_mtime(file) {
  let file_info = simplifile.file_info(file)
  file_info
  |> result.map(fn(file_info) {
    let mtime =
      file_info.mtime_seconds
      |> birl.from_unix
      |> birl.to_iso8601
    mtime
  })
  |> result.map_error(fn(error) { error })
}

fn get_file_info(files) {
  io.debug(files)

  let metadata =
    files
    |> list.fold_until(Ok([]), fn(acc, i) {
      let mtime = get_file_mtime(i)

      case mtime {
        Ok(mtime) ->
          list.Continue(
            result.map(acc, fn(values) {
              list.append(values, [MetaData(i, Ok(mtime))])
            }),
          )
        Error(file_error) -> list.Stop(Error([MetaData(i, Error(file_error))]))
      }
    })

  metadata
}

pub fn main() {
  let rc = case shellout.arguments() {
    ["list"] -> svn.svn_list()
    ["status"] -> svn.svn_status()
    ["add", ..rest] -> svn.svn_add(rest)
    ["info", ..rest] ->
      fn() {
        let info = get_file_info(rest)
        io.debug("info: ")
        io.debug(info)
        0
      }()
    ["changed"] -> list_updated()
    _ -> 1
  }
  rc
  |> shellout.exit
}
