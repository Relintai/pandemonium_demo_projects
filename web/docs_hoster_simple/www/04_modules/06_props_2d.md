# Prop2Ds Module

This is a c++ engine module for the Pandemonium Engine.

It gives you props, and editor utilities to convert scenes to props.

# Optional Dependencies

[Mesh Data Resource](https://github.com/Relintai/mesh_data_resource): Support for merged meshes, even in gles2.\
[Texture Packer](https://github.com/Relintai/texture_packer): Prop2D Instance will use this to merge textures.

# Prop2DData

Prop2Ds are basically 3D scenes in a simple format, so other things can easily process them without instancing.

For example if you create a building from MeshDataInstances, and then convert that scene to a prop, Voxelman
can spawn it, merge it's meshes, and create lods without any scene instancing.

Prop2DData is the main class you'll use, it's main purpose it to store a list of Prop2DDataEntries.

# Prop2DDataEntries

These are the classes that actually store data.

They contain 4 methods for scene->prop conversion, namely:

```
//Whether or not this Prop2DDataEntry can process the given Node.
virtual bool _processor_handles(Node *node);

//Save the given Node into the given prop_data any way you like, at transform.
virtual void _processor_process(Ref<Prop2DData> prop_data, Node *node, const Transform &transform);

//Turn Prop2DDataEntry back into a Node
virtual Node *_processor_get_node_for(const Transform &transform);

//Whether the system should skip evaluating the children of a processes Node or not. See Prop2DDataScene, or Prop2DDataProp2D.
virtual bool _processor_evaluate_children();
```

# Prop2DInstances

Prop2DInstances are not yet finished.

They will be able to merge meshes, texture etc from a Prop2D, and also generate lods for it.

Essentially they will be a more advanced MeshInstance.

Voxelman implements all of this, just haven't finished porting it yet.

# Prop2DUtils Singleton

The Prop2DUtils singleton helps with scene->prop conversion.

You can register new Prop2DDataEntries as processors, should you need to.

# Scene conversion

You can either click the new "To Prop2D" button on the menubar of the 3D scene for a quick conversion,
or look into Project->Tools.

