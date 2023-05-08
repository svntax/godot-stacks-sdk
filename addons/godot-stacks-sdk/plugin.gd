tool
extends EditorPlugin

const AUTOLOAD_STACKS = "Stacks"
const AUTOLOAD_STACKS_GLOBALS = "StacksGlobals"

func _enter_tree():
	add_autoload_singleton(AUTOLOAD_STACKS, "res://addons/godot-stacks-sdk/Stacks.gd")
	add_autoload_singleton(AUTOLOAD_STACKS_GLOBALS, "res://addons/godot-stacks-sdk/StacksGlobals.gd")

func _exit_tree():
	remove_autoload_singleton(AUTOLOAD_STACKS)
	remove_autoload_singleton(AUTOLOAD_STACKS_GLOBALS)
