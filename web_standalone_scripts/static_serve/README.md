# Static Serve Demo

This is a small script that parses a simple folder structure into a static site.

It's derived from the SceneTree, so you don't need to run this as a project, 
instead you need to get the engine, and run it with the `-s` (`--script`) option like so:

`./pandemonium -s ./static_serve.gd test_site_1`

`./pandemonium -s ./static_serve.gd test_site_2`

## Folder structure that it supports:

```
<PROJECT_ROOT>
    www_root <- this directory will be served / set as the www_root. If you have more in subfolders those are not.
    ... other folders / files
```

It parses the other folders and files into a WebNode hierarchy.

It creates StaticWebPageFile from all files, also it strips .html from the file names when setting uri_segments.

In every folder it parses index.html-s directly into that folder's root WebNode.

It will render out .md files to HTML.
