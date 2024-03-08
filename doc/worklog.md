

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

```gleam
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


```gleam
let file_info = simplifile.file_info(file)
```
This give me a result wrapped 'FileInfo`.
For now I just store it in a meta record

```gleam
type MetaData {
  MetaData(filename: String, mtime: Result(String, simplifile.FileError))
]
```


## Gleam formatting bug

Found a bug in the formatter

```gleam
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

```gleam
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

