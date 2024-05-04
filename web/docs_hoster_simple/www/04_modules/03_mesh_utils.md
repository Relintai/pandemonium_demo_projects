# Mesh Utils Module

This is a c++ engine module for the Pandemonium engine, containing my mesh merging utilities.

# Optional Dependencies

[Mesh Data Resource](https://github.com/Relintai/mesh_data_resource): Support for merged meshes, even in gles2.
Adds MeshMerger a few helper methods.

# MeshUtils Singleton

Contains generic algorithms that manipulate meshes.

# Mesh Merger

Works similarly to SurfaceTool, but it has more utility functions.

# Fast Quadratic Mesh Simplifier

A port of https://github.com/Whinarn/UnityMeshSimplifier .
For future reference it's based on e8ff4e8862735197c3308cfe926eeba68e0d2edb.
Porting is mostly done, but it does needs some debugging (it has a crash if smart linking is enabled).

I might just return to using the original FQMS. As if meshes are merged together using `MeshUtils.merge_mesh_array`, or
`bake_mesh_array_uv` the original algorithm will work fine. Still on the fence about it.
