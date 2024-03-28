import gleam/io
import gleam/result
import gleam/list
import shellout
import simplifile
import birl
import tinebox/svn

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

fn vcs_list(rest) {
  case rest {
    [repo] -> svn.svn_list(repo)
    _ -> 1
  }
}

fn vcs_status(rest) {
  case rest {
    [repo] -> svn.svn_status(repo)
    _ -> 1
  }
}

fn vcs_add(rest) {
  case rest {
    [repo, ..files] -> svn.svn_add(repo, files)
    _ -> 1
  }
}

fn vcs_list_updated(rest) {
  case rest {
    [repo] -> {
      svn.svn_list_updated(repo)
      |> io.debug
      0
    }
    _ -> 1
  }
  // TODO: split out new directories, so they can be added with metadata also
  // splitting: https://hexdocs.pm/filepath/filepath.html#split
}

pub fn main() {
  let rc = case shellout.arguments() {
    ["list", ..rest] -> vcs_list(rest)
    ["status", ..rest] -> vcs_status(rest)
    ["add", ..rest] -> vcs_add(rest)
    ["info", ..rest] -> {
      let info = get_file_info(rest)
      io.debug("info: ")
      io.debug(info)
      0
    }
    ["changed", ..rest] -> vcs_list_updated(rest)
    _ -> 1
  }
  rc
  |> shellout.exit
}
