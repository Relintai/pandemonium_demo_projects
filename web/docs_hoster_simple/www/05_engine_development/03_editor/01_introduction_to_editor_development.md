
# Introduction to editor development

On this page, you will learn:

- The **design decisions** behind the Pandemonium editor.
- How to work efficiently on the Pandemonium editor's C++ code.

This guide is aimed at current or future engine contributors.
To create editor plugins in GDScript, see `doc_making_plugins` instead.

See also:

    If you are new to Pandemonium, we recommended you to read
    `doc_pandemonium_design_philosophy` before continuing. Since the Pandemonium editor
    is a Pandemonium project written in C++, much of the engine's philosophy applies
    to the editor.

## Technical choices

The Pandemonium editor is drawn using Pandemonium's renderer and
`UI system ( toc-gui-basics )`. It does *not* rely on a toolkit
such as GTK or Qt. This is similar in spirit to software like Blender.
While using toolkits makes it easier to achieve a "native" appearance, they are
also quite heavy and their licensing is not compatible with Pandemonium's.

The editor is fully written in C++. It can't contain any GDScript or C# code.

## Directory structure

The editor's code is fully self-contained in the
`editor/ ( https://github.com/Relintai/pandemonium_engine/tree/master/editor )` folder
of the Pandemonium source repository.

Some editor functionality is also implemented via
`modules ( doc_custom_modules_in_c++ )`. Some of these are only enabled in
editor builds to decrease the binary size of export templates. See the
`modules/ ( https://github.com/Relintai/pandemonium_engine/tree/master/modules )` folder
in the Pandemonium source repository.

Some important files in the editor are:

- `editor/editor_node.cpp ( https://github.com/Relintai/pandemonium_engine/blob/3.x/editor/editor_node.cpp )`:
  Main editor initialization file. Effectively the "main scene" of the editor.
- `editor/project_manager.cpp ( https://github.com/Relintai/pandemonium_engine/blob/3.x/editor/project_manager.cpp )`:
  Main project manager initialization file. Effectively the "main scene" of the project manager.
- `editor/plugins/canvas_item_editor_plugin.cpp ( https://github.com/Relintai/pandemonium_engine/blob/3.x/editor/plugins/canvas_item_editor_plugin.cpp )`:
  The 2D editor viewport and related functionality (toolbar at the top, editing modes, overlaid helpers/panels, …).
- `editor/plugins/spatial_editor_plugin.cpp ( https://github.com/Relintai/pandemonium_engine/blob/3.x/editor/plugins/spatial_editor_plugin.cpp )`:
  The 3D editor viewport and related functionality (toolbar at the top, editing modes, overlaid panels, …).
- `editor/spatial_editor_gizmos.cpp ( https://github.com/Relintai/pandemonium_engine/blob/3.x/editor/spatial_editor_gizmos.cpp )`:
  Where the 3D editor gizmos are defined and drawn.
  This file doesn't have a 2D counterpart as 2D gizmos are drawn by the nodes themselves.

## Editor dependencies in `scene/` files

When working on an editor feature, you may have to modify files in
Pandemonium's GUI nodes, which you can find in the `scene/` folder.

One rule to keep in mind is that you must **not** introduce new dependencies to
`editor/` includes in other folders such as `scene/`. This applies even if
you use `#ifdef TOOLS_ENABLED`.

To make the codebase easier to follow and more self-contained, the allowed
dependency order is:

- `editor/` -> `scene/` -> `servers/` -> `core/`

This means that files in `editor/` can depend on includes from `scene/`,
`servers/`, and `core/`. But, for example, while `scene/` can depend on includes
from `servers/` and `core/`, it cannot depend on includes from `editor/`.

Currently, there are some dependencies to `editor/` includes in `scene/`
files, but
`they are in the process of being removed ( https://github.com/Relintai/pandemonium_engine/issues/29730 )`.

## Development tips

To iterate quickly on the editor, we recommend to set up a test project and
`open it from the command line ( doc_command_line_tutorial )` after compiling
the editor. This way, you don't have to go through the project manager every
time you start Pandemonium.
