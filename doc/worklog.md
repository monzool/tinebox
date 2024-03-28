

# 2024-02-16

Created the repo [on github](https://github.com/monzool/tinebox).
Generated a gleam project with `gleam new tinebox`

## Libraries

#libraries

Found some libraries that I perhaps would use

### Core

- [shellout](https://github.com/tynanbe/shellout) - Cross-platform shell operations
- [argv](https://github.com/lpil/argv) - A cross platform library for getting the command line arguments
- [path](https://github.com/gleam-community/path) - Path parsing and manipulation
- [birl](https://github.com/massivefermion/birl) - Date/time handling
- [gleam-lang/json](https://github.com/gleam-lang/json) - json

### Accessories
- [ansi](https://github.com/gleam-community/ansi) - ANSI colors, formatting, and control codes
- [spinner](https://github.com/lpil/spinner) - Animated progress spinners for your console

### Development

- [glimt](https://github.com/JohnBjrk/glimt) - Logging
- [glam](https://github.com/giacomocavalieri/glam) - Pretty print of data structures




# 2024-02-27

## File informaion

Huh? Apparently there is no built-in file support in gleam 🤔

Google didn't find much, but a few hits pointed to https://hexdocs.pm/gleam_erlang/. However, that repo didn't seem to have any file handling. After some digging in the history, it was clear that it **had** had some file handling features, but those had been [deprecated](https://github.com/gleam-lang/erlang/commit/9d72bd00caf5ec80ffbafb2a75c6d29b1d1477c5)

```elm
@deprecated("Use the simplifile package instead")
@external(erlang, "gleam_erlang_ffi", "file_info")
```


Could not figure out how file handling works to get file information so resorted to ask on the gleam discord channel


>Hi 
>
>I'm looking for a way to get mtime, ctime and other file details
>
>After some initial confusion I realized that a library is needed for file handling 😅 Alright 😊 I've then learned that file operations was in the gleam/erlang/file library, which then deprecated (https://github.com/gleam-lang/erlang/commit/9d72bd00caf5ec80ffbafb2a75c6d29b1d1477c5) and now simplifile is the recommended library.
>
>In gleam/erlang/file it looks like you use this https://hexdocs.pm/gleam_erlang/0.21.0/gleam/erlang/file.html#file_info to get this https://hexdocs.pm/gleam_erlang/0.21.0/gleam/erlang/file.html#FileInfo
>
>I could have missed it, but I failed to find any equivalent in simplifile 🔍🤷‍♀️ Any pointer to how to get file information?
>
>P.S. I am very new to Gleam and anything BEAM related 😬


I very quickly got a response


>bcpeinhardt#supportgluncle — Today at 17:21
@monzool I’ll add this when I get a chance and let you know here, probably today or tomorrow 😌

[Discord](
https://discord.com/channels/768594524158427167/1212795713633914941)


Nice!

## svn status

#svn/status

### svn status kind

svn do not list the kind (file/directory/symlink) when added

```sh
❱ svn st
A       dir1/dir1_file1.txt
A       dir2

❱ svn st --xml
<?xml version="1.0" encoding="UTF-8"?>
<status>
  <target path=".">
    <entry path="9407031305">
      <wc-status props="none" item="unversioned">
</wc-status>
    </entry>
    <entry path="dir1/dir1_file1.txt">
      <wc-status props="none" item="added" revision="-1">
</wc-status>
    </entry>
    <entry path="dir2">
      <wc-status props="none" item="added" revision="-1">
</wc-status>
    </entry>
    <entry path="–t">
      <wc-status item="unversioned" props="none">
</wc-status>
    </entry>
    <entry path="–tr">
      <wc-status props="none" item="unversioned">
</wc-status>
    </entry>
  </target>
</status>
```

When committed, `svn list` can show the kind


```sh
❱ svn list --xml | xmllint --format -
<?xml version="1.0" encoding="UTF-8"?>
<lists>
  <list path=".">
    <entry kind="dir">
      <name>dir1</name>
      <commit revision="4">
        <author>jsso</author>
        <date>2024-02-29T19:17:02.225074Z</date>
      </commit>
    </entry>
    <entry kind="file">
      <name>first_file.txt</name>
      <size>20</size>
      <commit revision="4">
        <author>jsso</author>
        <date>2024-02-29T19:17:02.225074Z</date>
      </commit>
    </entry>
```


### svn status timestamp

svn status can show the date of when the file was **added** to svn.

```sh
❱ svn add dir2 dir1/dir1_file1.txt
A         dir2
A         dir1/dir1_file1.txt

❱ touch -a -m -t 203801181205.09 dir1/dir1_file1.txt
❱ ll dir1/dir1_file1.txt
Permissions User Group Size      Date Modified              Name
.rw-rw-r--  jsso jsso  0 B  2038-01-18 Mon 12:05:09  dir1/dir1_file1.txt

❱ svn st --xml -v | grep -Ei '(date|path)'
   path=".">
   path=".">
<date>2024-02-29T19:17:02.225074Z</date>
   path="9407031305">
   path="dir1">
<date>2024-02-29T19:17:02.225074Z</date>
   path="dir1/dir1_file1.txt">
   path="dir2">
   path="first_file.txt">
<date>2024-02-29T19:17:02.225074Z</date>
   path="second_file.txt">
<date>2024-02-27T17:33:50.801252Z</date>
```


### svn status conclusions

#conclusion/svn/status

- It cannot determine kind (file/directory/symlink), but it most likely not needed for anything. Alternatively is must be probed manually
- Cannot be used for getting file timestamp
- Use `-q` flag to ignore untracked items
- It can be used for getting a list of files added

    ```sh
    ❱ svn st -q | awk '{ print $2 }'
    dir1/dir1_file1.txt
    dir2
    ```


## svn add

Should probably just simply pass to `svn add` every file added, that resides within the repo


# 2024-03-08

## Iterate a file list

How do I get the first item from a list and unwrap it so I get the actual value?

First tried

```
let file1 = result.unwrap(list.first(files), "")
```

Not awesome. The default value makes no sense. I know that I can pattern match, but as there is not early exit, how do I structure this?

Oh. Pattern matching is going to be weird also

```
case list.first(files) {
  [first, ..rest] -> first
  _ -> "what to do here?"
}
```

Lets just iterate'em all. Then I can use `map`.
Using maps works, excepts that it is not suitable if I want to stop at first error. I think I should just stop first time I get an error where I can't collect the meta data. Failure would probably not be a one off, but instead permission or unmount issue.
Searching a bit, found that javascript use `Some` or `find` for this. Gleam list type has a `find` function


## Getting file information

The `FileInfo` type added in simplifile-1.5.0 is pretty nice.


```elm
let file_info = simplifile.file_info(file)
```
This give me a result wrapped 'FileInfo`.
For now I just store it in a meta record

```elm
type MetaData {
  MetaData(filename: String, mtime: Result(String, simplifile.FileError))
]
```


## Gleam formatting bug

Found a bug in the formatter

```elm
let mtime =
  file_info
  |> result.map(with: fn(info) {
    info.mtime_seconds
    |> birl.from_unix
    |> birl.to_iso8601
    // |> io.debug
    // #(file, info.mtime_seconds)
  })
```

After saving, the formatter changes this by moving the commented lines

```elm
let mtime =
  file_info
  |> result.map(with: fn(info) {
    info.mtime_seconds
    |> birl.from_unix
    |> birl.to_iso8601
  })

// |> io.debug
// #(file, info.mtime_seconds)
```


# 2024-03-13

## Try out `fold_until`

So how to break from a map operation if error? Best fit I could find was `fold_until`. That can return a `list.Continue` in good case, or `list.Stop` in error cases
Looks like the return type is the same for both cases. That won't work directly, as I then can't identify success from error. Have to use a `result` type I figure

So `fold` functions need a starting seed, Guess I can use an empty list for starting.
First basic tryout

```elm
fn get_file_info(files) {
  let metadata =
    files
    |> list.fold_until(Ok([]), fn(acc, i) {
      let meta = MetaData(i, "dummy mtime")
      let res = result.map(acc, fn(values) { list.append(values, [meta]) })

      list.Continue(res)
    })
}
```

Result:
>Ok([MetaData("first_file.txt", "dummy mtime"), MetaData("second_file.txt", "dummy mtime")])


## Using `fold_until`

Okay got a solution. There are some issues...maybe

```elm
fn get_file_info(files) {
  let metadata =
    files
    |> list.fold_until(Ok([]), fn(acc, i) {
      let mtime = get_file_mtime(i)
      case mtime {
        Ok(mtime) ->
          list.Continue(
            result.map(acc, fn(values) {
              list.append(values, [MetaData(i, mtime)])
            }),
          )
        Error(file_error) -> list.Stop(Error(file_error))
      }
    })
}
```

The `acc` is a `result` type, so I need to unwrap it, to append to the boxed list. Here I only use `map` and ignores any errors. As a human I know that this will never error, but the code could look like an only semi-handled situation?

If feeding a list of valid files, it will return a `Ok` result of list. In case of an invalid file, it stops on first error


# 2024-03-18

Settled on the following file instance type

```elm
type MetaData {
  MetaData(filename: String, mtime: Result(String, simplifile.FileError))
}
```

The resulting type from a file traversal will be

```elm
  Result(MetaData(filename: String, mtime: Result(String, simplifile.FileError)))
```

The outer `Result` will inform:
- Ok 🢡 all file operations succeded
- Error 🢡 file of first error

More meta data are to be collected, but for now the following is collected as the `mtime` member:
- Ok 🢡 a iso8601 timestamp (`Ok("2024-02-27T17:33:31.000Z")`)
- Error 🢡 a simplify file error (`Error(Enoent)`)

A success result might be like this

`Ok([MetaData("first_file.txt", Ok("2024-02-27T17:45:53.000Z")), MetaData("second_file.txt", Ok("2024-02-27T17:33:31.000Z"))])`

while an error could be like this

`Error([MetaData("/non/existing/file", Error(Enoent))])`

Both success and failure are list results. In the error case, this might not be needed now, as it stops on first error, but it simplifies the generating code. And if wanting to parallelize it might be easier for collecting errors, and then just presenting the first item 🤷‍♀️


# 2024-03-24

Cannot get gleam shellout working with pipe operators

```elm
shellout.command(run: "svn", with: ["st", "-q", "| wc"], in: svn_repo, opt: [])
|> print_svn
```
This simple command prints nothing?

This is even worse

```elm
shellout.command(run: "ls", with: ["|", "wc"], in: svn_repo, opt: [])
|> print_svn
```

>/usr/bin/ls: cannot access '|': No such file or directory \
/usr/bin/ls: cannot access 'wc': No such file or directory


Found an [example](https://github.com/tynanbe/shellout/issues/4) on the shellout issue site. That example works.

A little modified to capture stdout and print the result in gleam..

```elm
shellout.command(run: "sh", with: ["-euc", "
  echo '" <> "Hello world" <> "' \\
    | cat
  "], in: ".", opt: [])
|> print_svn
```

Hmm, okay using "sh" as command seems to work, but I would have expected, that I wouldn't need to run "advanced" command by passing them to a shell

```elm
shellout.command(run: "sh", with: ["-euc", "ls | wc"], in: svn_repo, opt: [])
|> print_svn
```

## Handling bad commands

My understanding of `result.try` is that it should only run the `fn` in case of successful result. If I run a bogus command (`svn xyz`) with shellout, I still get a `fn` call?

```elm
result.try(
  shellout.command(
      run: "sh",
      with: ["-euc", "svn xyz -q | sed -E 's/^[[:space:]]*[AM][[:space:]]+//'"],
  ),
  fn(data) {
    // data is an error message
  },
)
```

Either I misunderstood `result.try` or shellout is giving ok back on error exit?

Changed to use `result.map` instead, with same result. 
Found that this gives me an `Error` result from shellout

```elm
shellout.command(
    run: "sh",
    with: ["-euc", "false"],
),
```

Then its probably the pipe!

Yes. This gives ok

```elm
shellout.command(
    run: "sh",
    with: ["-euc", "false | echo"],
),
```

But I cant get `-o pipefail` to work with shellout 🤷‍♀️

Found a solution, but had to change to `bash`

```elm
shellout.command(
    run: "bash",
    with: ["-euc", "-o", "pipefail", "false | echo"],
),
```

Think the `with` option is a bit confusing on what it accepts, or how, it accepts its arguments 🤔
Not happy with the `bash` usage. It might not be installed, or linked to `sh` and then break stuff

#todo/bash

⛳ Anyway shellout now gives `Error` on failure


## `result.try` vs `result.map`

The above made me wonder when to use `result.try` and when to prefer `result.map`...

The two examples below gives the same end result. Ok situations convert the data. Error situations only returns the error.

```elm
result.try(
  shellout.command(
  ),
  fn(raw) {
    items
  },
)
```

```elm
shellout.command(
)
|> result.map(fn(raw) {
  items
})
```

Subjectively the `map` may appear simpler, but maybe these samples are two small to make a real difference


### Directory timestamp strategy

For now I have not distinguished between added or modified, but I think for directories I might need to handle this different

- newly added directory 🢡 store created timestamp
- files added to directory 🢡 update timestamp

I foresee the might be a matter of taste, and should probably be an option. If f.ex adding a long lost file to an existing collection of files, the directory should still represent the original timestamp. If adding a newly created file, it might make sense to make the directory reflect a change in content.

For now, creation timestamp will be the rule for directories

#todo/directories/timestamp


# 2024-03-27

## Restructure

Moved subversion and printing related into their own modules. Modules are real easy. Its just files (similar to python) 🏆


# 2024-03-28

## Repository argument

The repository path was hardcoded up until now. It is now expected to be first argument to each function.

## gleam

#gleam/language

Learned that handling a multiline expression in a case match, does not require to put it in a function. Don't know why I assumed that the function was needed. Oh well

```diff
case x {
-  x -> fn() {
-  }()
+  x -> {
+  }
}
```

---

#gleam/tooling

After splitting the source into multiple modules, I cannot get "go to implementation" to work in vscode. Little annoying, but the project is small so not critical


## Libraries

### json

#gleam/library/json

Found a library [gserde](https://hexdocs.pm/gserde/) that can generate code to convert gleam types to json types

### File handling

#gleam/library/file

There appears to be two libraries for file handling

- [gleam_community_path](https://hex.pm/packages/gleam_community_path)
- [filepath](https://hex.pm/packages/filepath)

Not sure which to use, but *gleam_community_path* seems to operate on a [`Path`](https://hexdocs.pm/gleam_community_path/gleam_community/path.html#Path) type

The [expand](https://hexdocs.pm/filepath/filepath.html#expand) function looks useful

```elm
expand("/usr/local/../bin")
// -> Ok("/usr/bin")
```

## Adding directories

If adding a directory tree to tinebox, I want all levels of directories to have meta data stored.

Adding `dir` is trivial, but if having sub-dirs `dir1/dir2/dir3`, then the following steps are needed:

- Split the path `dir1/dir2/dir3` 🢡 `dir1`, `dir2`, `dir3`
- Check if directory is not already in tinebox
- Collect metadata
- Add as a new item to the file/directory list

Do I need to care about that subversion can add empty directories?

- `dir1/dir2`
- `dir3/file1`

It might be that it actually doesn't matter if its a directory or a file. If it splits, then its known to have an item that needs to be handled.

There is another case that needs to be handled in this case

```sh
❱ svn st
A       dir1/dir1_file1.txt
A       dir1/dir1_file2.txt
```

It does not make sense to handle the same directory (`dir1`) multiple times, so some filtering is needed before adding to the total list.

Right now items are just stored in a list. Storing items in a [dictionary](https://hexdocs.pm/gleam_stdlib/gleam/dict.html), would make it really simple to check if a directory has already been added

```elm
dict.insert(`dir1`, metadata_dir1)
dict.insert(`dir1/dir2`, metadata_dir2)
dict.insert(`dir1/dir2/dir3`, metadata_dir3)
dict.insert(`dir1/dir2/dir3/file123`, metadata_file123)
```

Alternatively a local list could maintain handled directories


```elm
list.prepend(items, #(`dir1`, metadata_dir1))
list.prepend(items, #(`dir1/dir2`, metadata_dir2))
list.prepend(items, #(`dir1/dir2/dir3`, metadata_dir3))
list.prepend(items, #(`dir1/dir2/dir3/file123`, metadata_files123))
```

This is highly inefficient, but not sure the normal use-case requires a lot of files. Initial adding could though
