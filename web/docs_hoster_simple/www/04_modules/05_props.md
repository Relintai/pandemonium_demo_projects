# Props Module

This is a c++ engine module for the Pandemonium Engine.

It gives you props, and editor utilities to convert scenes to props.

# Optional Dependencies

[Mesh Data Resource](https://github.com/Relintai/mesh_data_resource): Support for merged meshes, even in gles2.\
[Texture Packer](https://github.com/Relintai/texture_packer): Prop Instance will use this to merge textures.

# PropData

Props are basically 3D scenes in a simple format, so other things can easily process them without instancing.

For example if you create a building from MeshDataInstances, and then convert that scene to a prop, Voxelman
can spawn it, merge it's meshes, and create lods without any scene instancing.

PropData is the main class you'll use, it's main purpose it to store a list of PropDataEntries.

# PropDataEntries

These are the classes that actually store data.

They contain 4 methods for scene->prop conversion, namely:

```
//Whether or not this PropDataEntry can process the given Node.
virtual bool _processor_handles(Node *node);

//Save the given Node into the given prop_data any way you like, at transform.
virtual void _processor_process(Ref<PropData> prop_data, Node *node, const Transform &transform);

//Turn PropDataEntry back into a Node
virtual Node *_processor_get_node_for(const Transform &transform);

//Whether the system should skip evaluating the children of a processes Node or not. See PropDataScene, or PropDataProp.
virtual bool _processor_evaluate_children();
```

# PropInstances

PropInstances are not yet finished.

They will be able to merge meshes, texture etc from a Prop, and also generate lods for it.

Essentially they will be a more advanced MeshInstance.

Voxelman implements all of this, just haven't finished porting it yet.

# PropUtils Singleton

The PropUtils singleton helps with scene->prop conversion.

You can register new PropDataEntries as processors, should you need to.

# Scene conversion

You can either click the new "To Prop" button on the menubar of the 3D scene for a quick conversion,
or look into Project->Tools.

