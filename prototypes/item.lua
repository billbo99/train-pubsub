data:extend({

  -- {
  --   type = "custom-input",
  --   name = "remove-ping-map",
  --   key_sequence = "mouse-button-1"
  -- },
  {
	type = "item-group",
	name = "tsm-virtual-signals",
	order = "t",
	icon = "__train-pubsub__/graphics/icons/TSM3.png",
	icon_size = 64
  },
  {
	type = "item-subgroup",
	name = "empty-wagons",
	group = "tsm-virtual-signals",
	order = "a"
  },
  {
	type = "item-with-tags",
	name = "train-publisher",
	icon = "__train-pubsub__/graphics/icons/small-lamp-pub.png",
	icon_size = 32,
--	flags = {"goes-to-quickbar"},
	subgroup = "transport",
	order = "a[train-system]-cc[train-publisher]",
	place_result = "train-publisher",
	stack_size = 50
  },

  {
    type = "item",
    name = "train-counter",
    icon = "__base__/graphics/icons/constant-combinator.png",
  	icon_size = 64,
    flags = { },
    subgroup = "transport",
    place_result="train-counter",
 --   order = "a[train-system]-cb[train-counter]",
    stack_size= 50,
  },
   {
    type = "constant-combinator",
    name = "train-counter",
    icon = "__base__/graphics/icons/constant-combinator.png",
	icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
 --   minable = {hardness = 0.2, mining_time = 0.5, result = "train-counter"},
    max_health = 120,
    corpse = "small-remnants",

    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},

    item_slot_count = 50,

    sprites =
    make_4way_animation_from_spritesheet({ layers =
      {
        {
          filename = "__base__/graphics/entity/combinator/constant-combinator.png",
          width = 58,
          height = 52,
          frame_count = 1,
          shift = util.by_pixel(0, 5),
          hr_version =
          {
            scale = 0.5,
            filename = "__base__/graphics/entity/combinator/hr-constant-combinator.png",
            width = 114,
            height = 102,
            frame_count = 1,
            shift = util.by_pixel(0, 5),
          },
        },
        {
          filename = "__base__/graphics/entity/combinator/constant-combinator-shadow.png",
          width = 50,
          height = 34,
          frame_count = 1,
          shift = util.by_pixel(9, 6),
          draw_as_shadow = true,
          hr_version =
          {
            scale = 0.5,
            filename = "__base__/graphics/entity/combinator/hr-constant-combinator-shadow.png",
            width = 98,
            height = 66,
            frame_count = 1,
            shift = util.by_pixel(8.5, 5.5),
            draw_as_shadow = true,
          },
        },
      },
    }),

activity_led_sprites =
  {
    north =
    {
      filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-N.png",
      width = 8,
      height = 6,
      frame_count = 1,
      shift = util.by_pixel(9, -12),
      hr_version =
      {
        scale = 0.5,
        filename = "__base__/graphics/entity/combinator/activity-leds/hr-constant-combinator-LED-N.png",
        width = 14,
        height = 12,
        frame_count = 1,
        shift = util.by_pixel(9, -11.5),
      },
    },
    east =
    {
      filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-E.png",
      width = 8,
      height = 8,
      frame_count = 1,
      shift = util.by_pixel(8, 0),
      hr_version =
      {
        scale = 0.5,
        filename = "__base__/graphics/entity/combinator/activity-leds/hr-constant-combinator-LED-E.png",
        width = 14,
        height = 14,
        frame_count = 1,
        shift = util.by_pixel(7.5, -0.5),
      },
    },
    south =
    {
      filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-S.png",
      width = 8,
      height = 8,
      frame_count = 1,
      shift = util.by_pixel(-9, 2),
      hr_version =
      {
        scale = 0.5,
        filename = "__base__/graphics/entity/combinator/activity-leds/hr-constant-combinator-LED-S.png",
        width = 14,
        height = 16,
        frame_count = 1,
        shift = util.by_pixel(-9, 2.5),
      },
    },
    west =
    {
      filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-W.png",
      width = 8,
      height = 8,
      frame_count = 1,
      shift = util.by_pixel(-7, -15),
      hr_version =
      {
        scale = 0.5,
        filename = "__base__/graphics/entity/combinator/activity-leds/hr-constant-combinator-LED-W.png",
        width = 14,
        height = 16,
        frame_count = 1,
        shift = util.by_pixel(-7, -15),
      },
    },
  },

    activity_led_light =
    {
      intensity = 0.8,
      size = 1,
      color = {r = 1.0, g = 1.0, b = 1.0}
    },

    activity_led_light_offsets =
    {
      {0.296875, -0.40625},
      {0.25, -0.03125},
      {-0.296875, -0.078125},
      {-0.21875, -0.46875}
    },

    circuit_wire_connection_points =
    {
      {
        shadow =
        {
          red = {0.15625, -0.28125},
          green = {0.65625, -0.25}
        },
        wire =
        {
          red = {-0.28125, -0.5625},
          green = {0.21875, -0.5625},
        }
      },
      {
        shadow =
        {
          red = {0.75, -0.15625},
          green = {0.75, 0.25},
        },
        wire =
        {
          red = {0.46875, -0.5},
          green = {0.46875, -0.09375},
        }
      },
      {
        shadow =
        {
          red = {0.75, 0.5625},
          green = {0.21875, 0.5625}
        },
        wire =
        {
          red = {0.28125, 0.15625},
          green = {-0.21875, 0.15625}
        }
      },
      {
        shadow =
        {
          red = {-0.03125, 0.28125},
          green = {-0.03125, -0.125},
        },
        wire =
        {
          red = {-0.46875, 0},
          green = {-0.46875, -0.40625},
        }
      }
    },

    circuit_wire_max_distance = 9
  },

  {
    type = "virtual-signal",
    name = "train-counter",
    icon = "__train-pubsub__/graphics/icons/train_manager.png",
	  icon_size = 32,
    subgroup = "virtual-signal",
    order = "e[train-controller]-a[train-counter]"
  },
  {
    type = "virtual-signal",
    name = "locomotive2",
    icon = "__train-pubsub__/graphics/icons/locomotive2.png",
	  icon_size = 64,
    subgroup = "virtual-signal",
    order = "e[train-controller]-a[train-counter]"
  },
    {
    type = "virtual-signal",
    name = "empty-cargo-wagon-coal",
    icon = "__train-pubsub__/graphics/icons/empty-cargo-wagon-coal.png",
	icon_size = 32,
    subgroup = "empty-wagons",
	order = "a[empty-wagons]"
  },
    {
    type = "virtual-signal",
    name = "empty-cargo-wagon-copper-ore",
    icon = "__train-pubsub__/graphics/icons/empty-cargo-wagon-copper-ore.png",
	icon_size = 32,
    subgroup = "empty-wagons",
	order = "b[empty-wagons]"
  },
    {
    type = "virtual-signal",
    name = "empty-cargo-wagon-iron-ore",
    icon = "__train-pubsub__/graphics/icons/empty-cargo-wagon-iron-ore.png",
	icon_size = 32,
    subgroup = "empty-wagons",
	order = "c[empty-wagons]"
  },
    {
    type = "virtual-signal",
    name = "empty-cargo-wagon-stone",
    icon = "__train-pubsub__/graphics/icons/empty-cargo-wagon-stone.png",
	icon_size = 32,
    subgroup = "empty-wagons",
	order = "d[empty-wagons]"
  },
    {
    type = "virtual-signal",
    name = "empty-cargo-wagon-uranium-ore",
    icon = "__train-pubsub__/graphics/icons/empty-cargo-wagon-uranium-ore.png",
	icon_size = 32,
    subgroup = "empty-wagons",
	order = "e[empty-wagons]"
  },
    {
    type = "virtual-signal",
    name = "empty-fluid-wagon-crude-oil",
    icon = "__train-pubsub__/graphics/icons/empty-fluid-wagon-crude-oil.png",
	icon_size = 32,
    subgroup = "empty-wagons",
	order = "f[empty-wagons]"
  },
    {
    type = "virtual-signal",
    name = "empty-fluid-wagon-heavy-oil",
    icon = "__train-pubsub__/graphics/icons/empty-fluid-wagon-heavy-oil.png",
	icon_size = 32,
    subgroup = "empty-wagons",
	order = "g[empty-wagons]"
  },
    {
    type = "virtual-signal",
    name = "empty-fluid-wagon-light-oil",
    icon = "__train-pubsub__/graphics/icons/empty-fluid-wagon-light-oil.png",
	icon_size = 32,
    subgroup = "empty-wagons",
	order = "h[empty-wagons]"
  },
    {
    type = "virtual-signal",
    name = "empty-fluid-wagon-lubricant",
    icon = "__train-pubsub__/graphics/icons/empty-fluid-wagon-lubricant.png",
	icon_size = 32,
    subgroup = "empty-wagons",
	order = "i[empty-wagons]"
  },
    {
    type = "virtual-signal",
    name = "empty-fluid-wagon-petroleum-gas",
    icon = "__train-pubsub__/graphics/icons/empty-fluid-wagon-petroleum-gas.png",
	icon_size = 32,
    subgroup = "empty-wagons",
	order = "j[empty-wagons]"
  },
  {
    type = "virtual-signal",
    name = "empty-fluid-wagon-steam",
    icon = "__train-pubsub__/graphics/icons/empty-fluid-wagon-steam.png",
	icon_size = 32,
    subgroup = "empty-wagons",
	order = "k[empty-wagons]"
  },
  {
    type = "virtual-signal",
    name = "empty-fluid-wagon-sulfuric-acid",
    icon = "__train-pubsub__/graphics/icons/empty-fluid-wagon-sulfuric-acid.png",
	icon_size = 32,
    subgroup = "empty-wagons",
	order = "l[empty-wagons]"
  },
  {
    type = "virtual-signal",
    name = "empty-fluid-wagon-water",
    icon = "__train-pubsub__/graphics/icons/empty-fluid-wagon-water.png",
	icon_size = 32,
    subgroup = "empty-wagons",
	order = "m[empty-wagons]"
  },

    {
    type = "item",
    name = "subscriber-train-stop",
    icon = "__train-pubsub__/graphics/icons/train-stop-sub.png",
    icon_size = 32,
 --   flags = {"goes-to-quickbar"},
    subgroup = "transport",
    order = "a[train-system]-ca[train-stop]",
    place_result = "subscriber-train-stop",
    stack_size = 10
  },

    {
    type = "item",
    name = "publisher-train-stop",
    icon = "__train-pubsub__/graphics/icons/train-stop-req.png",
    icon_size = 32,
  --  flags = {"goes-to-quickbar"},
    subgroup = "transport",
    order = "a[train-system]-cb[train-stop]",
    place_result = "publisher-train-stop",
    stack_size = 10
  },

{
    type = "item",
    name = "train-config",
    icon = "__train-pubsub__/graphics/icons/train-config.png", tint = {r=0.2, g=1, b=0.8, a=1},
  	icon_size = 32,
    flags = { },
    subgroup = "transport",
    place_result="train-config",
    order = "a[train-system]-cc[train-config]",
    stack_size= 50,
  },
   {
    type = "constant-combinator",
    name = "train-config",
    icon = "__train-pubsub__/graphics/icons/train-config.png", tint = {r=0.2, g=1, b=0.8, a=1},
	  icon_size = 32,
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "train-config"},
    max_health = 120,
    corpse = "small-remnants",

    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},

    item_slot_count = 18,

    sprites =
    make_4way_animation_from_spritesheet({ layers =
      {
        {
          filename = "__train-pubsub__/graphics/combinator/train-config.png",
          width = 58,
          height = 52,
          frame_count = 1,
          shift = util.by_pixel(0, 5),
		  tint = {r=0.2, g=1, b=0.8, a=1},
          hr_version =
          {
            scale = 0.5,
            filename = "__train-pubsub__/graphics/combinator/hr-train-config.png",
            width = 114,
            height = 102,
            frame_count = 1,
            shift = util.by_pixel(0, 5),
			tint = {r=0.2, g=1, b=0.8, a=1},
          },
        },
        {
          filename = "__base__/graphics/entity/combinator/constant-combinator-shadow.png",
          width = 50,
          height = 34,
          frame_count = 1,
          shift = util.by_pixel(9, 6),
          draw_as_shadow = true,
          hr_version =
          {
            scale = 0.5,
            filename = "__base__/graphics/entity/combinator/hr-constant-combinator-shadow.png",
            width = 98,
            height = 66,
            frame_count = 1,
            shift = util.by_pixel(8.5, 5.5),
            draw_as_shadow = true,
          },
        },
      },
    }),

activity_led_sprites =
  {
    north =
    {
      filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-N.png",
      width = 8,
      height = 6,
      frame_count = 1,
      shift = util.by_pixel(9, -12),
      hr_version =
      {
        scale = 0.5,
        filename = "__base__/graphics/entity/combinator/activity-leds/hr-constant-combinator-LED-N.png",
        width = 14,
        height = 12,
        frame_count = 1,
        shift = util.by_pixel(9, -11.5),
      },
    },
    east =
    {
      filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-E.png",
      width = 8,
      height = 8,
      frame_count = 1,
      shift = util.by_pixel(8, 0),
      hr_version =
      {
        scale = 0.5,
        filename = "__base__/graphics/entity/combinator/activity-leds/hr-constant-combinator-LED-E.png",
        width = 14,
        height = 14,
        frame_count = 1,
        shift = util.by_pixel(7.5, -0.5),
      },
    },
    south =
    {
      filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-S.png",
      width = 8,
      height = 8,
      frame_count = 1,
      shift = util.by_pixel(-9, 2),
      hr_version =
      {
        scale = 0.5,
        filename = "__base__/graphics/entity/combinator/activity-leds/hr-constant-combinator-LED-S.png",
        width = 14,
        height = 16,
        frame_count = 1,
        shift = util.by_pixel(-9, 2.5),
      },
    },
    west =
    {
      filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-W.png",
      width = 8,
      height = 8,
      frame_count = 1,
      shift = util.by_pixel(-7, -15),
      hr_version =
      {
        scale = 0.5,
        filename = "__base__/graphics/entity/combinator/activity-leds/hr-constant-combinator-LED-W.png",
        width = 14,
        height = 16,
        frame_count = 1,
        shift = util.by_pixel(-7, -15),
      },
    },
  },

    activity_led_light =
    {
      intensity = 0.8,
      size = 1,
      color = {r = 1.0, g = 1.0, b = 1.0}
    },

    activity_led_light_offsets =
    {
      {0.296875, -0.40625},
      {0.25, -0.03125},
      {-0.296875, -0.078125},
      {-0.21875, -0.46875}
    },

    circuit_wire_connection_points =
    {
      {
        shadow =
        {
          red = {0.15625, -0.28125},
          green = {0.65625, -0.25}
        },
        wire =
        {
          red = {-0.28125, -0.5625},
          green = {0.21875, -0.5625},
        }
      },
      {
        shadow =
        {
          red = {0.75, -0.15625},
          green = {0.75, 0.25},
        },
        wire =
        {
          red = {0.46875, -0.5},
          green = {0.46875, -0.09375},
        }
      },
      {
        shadow =
        {
          red = {0.75, 0.5625},
          green = {0.21875, 0.5625}
        },
        wire =
        {
          red = {0.28125, 0.15625},
          green = {-0.21875, 0.15625}
        }
      },
      {
        shadow =
        {
          red = {-0.03125, 0.28125},
          green = {-0.03125, -0.125},
        },
        wire =
        {
          red = {-0.46875, 0},
          green = {-0.46875, -0.40625},
        }
      }
    },

    circuit_wire_max_distance = 9
  },
  {
		type = "shortcut",
		name = "TSM-priority-transfer",
		action = "lua",
		toggleable = true,
		icon =
		{
		  filename = "__train-pubsub__/graphics/icons/train_manager.png",
		  priority = "extra-high-no-scale",
		  size = 32,
		  scale = 1,
		  flags = {"icon"}
		}
    }

})
