require "lib"
require("prototypes.technology")
require("prototypes.style")
require("prototypes.item")
require("prototypes.recipe")
require("prototypes.entities")


data:extend(
	{
		{
			type = "sprite",
			name = "train_manager",
			filename = "__train-pubsub__/graphics/icons/train_manager.png",
			width = 32,
			height = 32,
		},
		{
			type = "sprite",
			name = "priority",
			filename = "__train-pubsub__/graphics/icons/gui-arrow-small.png",
			width = 42,
			height = 55,
		},
		{
			type = "sprite",
			name = "sub_train_stop",
			filename = "__train-pubsub__/graphics/icons/train-stop-sub.png",
			width = 32,
			height = 32,
		},
		{
			type = "sprite",
			name = "publisher",
			filename = "__train-pubsub__/graphics/icons/small-lamp-pub.png",
			width = 32,
			height = 32,
		},
		{
			type = "sprite",
			name = "trains",
			filename = "__base__/graphics/icons/locomotive.png",
			width = 64,
			height = 64,
		},
		{
			type = "sprite",
			name = "key",
			filename = "__train-pubsub__/graphics/icons/key.png",
			width = 32,
			height = 32,
		},
		{
			type = "sprite",
			name = "x",
			filename = "__train-pubsub__/graphics/icons/x.png",
			width = 32,
			height = 32,
		}
	}
)
