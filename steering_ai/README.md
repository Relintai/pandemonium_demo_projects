# Steering AI Framework

This demo shows the usage of [GDQuest's Godot Steering AI Framework](https://github.com/GDQuest/godot-steering-ai-framework)'s 
c++ port that is built into the engine. [See here](https://github.com/Relintai/pandemonium_engine/tree/master/modules/steering_ai)

It supports all essential steering behaviors like flee, follow, look at, but also blended behaviors, group behaviors, 
avoiding neighbors, following a path, following the leader, and much more.

## Introduction

In the 1990s, [Craig Reynolds](http://www.red3d.com/cwr/) developed algorithms for common AI behaviors. They allowed 
AI agents to seek out or flee from a target, follow a pre-defined path, or face in a particular direction. They were simple, 
repeatable tasks that could be broken down into programming algorithms, which made them easy to reuse, maintain, combine, and extend.

While an AI agent's next action is based on decision making and planning algorithms, steering behaviors dictate 
how it will move from one frame to the next. They use available information and calculate where to move at that moment.

Joining these systems together can give sophisticated and graceful movement while also being more 
efficient than complex pathfinding algorithms like A\*.

## The framework

This project takes inspiration from the excellent [GDX-AI](https://github.com/libgdx/gdx-ai) framework for the [LibGDX](https://libgdx.badlogicgames.com/) 
java-based framework.

Every class in the framework extends Godot's [Reference](https://docs.godotengine.org/en/latest/classes/class_reference.html) type. 
There is no need to have a complex scene tree; you can contain that has to do with the AI's movement inside GDScript classes.

### How it works

In GSAI, a steering agent represents a character or a vehicle. The agent stores its position, orientation, 
maximum speeds, and current velocity. The agent stores a steering behavior that calculates a linear or 
angular change in velocity based on its information.

The coder then applies that acceleration in whatever ways is appropriate to the character to change its v
elocities, like RigidBody's `apply_impulse`, or a KinematicBody's `move_and_slide`.

## Documentation

The documentation is available in-engine. Search for classes which names start with the word "GSAI".

The original framework's original documentation and code reference are available here: 
[Godot steering AI framework documentation](https://gdquest.gitbook.io/godot-3-steering-ai-framework-reference/)

