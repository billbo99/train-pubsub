require("util")

local train_counter = util.table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
train_counter.name = "train-counter"
train_counter.minable = { mining_time = 0.1, result = "constant-combinator" }

data:extend({ train_counter })

data:extend(
    {
        {
            type = "lamp",
            name = "train-publisher",
            icon = "__train-pubsub__/graphics/icons/small-lamp-pub.png",
            icon_size = 32,
            flags = { "placeable-neutral", "player-creation" },
            minable = { hardness = 0.2, mining_time = 0.1, result = "train-publisher" },
            max_health = 100,
            corpse = "small-remnants",
            collision_box = { { -0.15, -0.15 }, { 0.15, 0.15 } },
            selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
            vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
            energy_source =
            {
                type = "electric",
                usage_priority = "secondary-input"
            },
            energy_usage_per_tick = "5kW",
            light = { intensity = 0.9, size = 2, color = { r = 1.0, g = 1.0, b = 1.0 } },
            light_when_colored = { intensity = 1, size = 2, color = { r = 1.0, g = 1.0, b = 1.0 } },
            glow_size = 2,
            glow_color_intensity = 0.135,
            picture_off =
            {
                filename = "__train-pubsub__/graphics/small-lamp/light-off-pub.png",
                priority = "high",
                width = 67,
                height = 58,
                frame_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = { -0.015625, 0.15625 },
            },
            picture_on =
            {
                filename = "__train-pubsub__/graphics/small-lamp/light-on-patch.png",
                priority = "high",
                width = 62,
                height = 62,
                frame_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = { -0.03125, -0.03125 },
            },
            signal_to_color_mapping =
            {
                { type = "virtual", name = "signal-red",    color = { r = 1, g = 0, b = 0 } },
                { type = "virtual", name = "signal-green",  color = { r = 0, g = 1, b = 0 } },
                { type = "virtual", name = "signal-blue",   color = { r = 0, g = 0, b = 1 } },
                { type = "virtual", name = "signal-yellow", color = { r = 1, g = 1, b = 0 } },
                { type = "virtual", name = "signal-pink",   color = { r = 1, g = 0, b = 1 } },
                { type = "virtual", name = "signal-cyan",   color = { r = 0, g = 1, b = 1 } },
            },

            circuit_wire_connection_point =
            {
                shadow =
                {
                    red = { 0.734375, 0.578125 },
                    green = { 0.609375, 0.640625 },
                },
                wire =
                {
                    red = { 0.40625, 0.34375 },
                    green = { 0.40625, 0.5 },
                }
            },
            --	circuit_connector_sprites = get_circuit_connector_sprites({0.1875, 0.28125}, {0.1875, 0.28125}, 18),
            circuit_wire_connection_point = circuit_connector_definitions["lamp"].points,
            circuit_connector_sprites = circuit_connector_definitions["lamp"].sprites,
            circuit_wire_max_distance = default_circuit_wire_max_distance
            -- circuit_wire_max_distance = 9
        },
        {
            type = "constant-combinator",
            name = "train-config",
            icon = "__train-pubsub__/graphics/icons/train-config.png",
            tint = { r = 0.2, g = 1, b = 0.8, a = 1 },
            icon_size = 32,
            flags = { "placeable-neutral", "player-creation" },
            minable = { hardness = 0.2, mining_time = 0.1, result = "train-config" },
            max_health = 120,
            corpse = "small-remnants",

            collision_box = { { -0.35, -0.35 }, { 0.35, 0.35 } },
            selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },

            item_slot_count = 18,

            sprites =
                make_4way_animation_from_spritesheet({
                    layers =
                    {
                        {
                            filename = "__train-pubsub__/graphics/combinator/train-config.png",
                            width = 58,
                            height = 52,
                            frame_count = 1,
                            shift = util.by_pixel(0, 5),
                            tint = { r = 0.2, g = 1, b = 0.8, a = 1 },
                            hr_version =
                            {
                                scale = 0.5,
                                filename = "__train-pubsub__/graphics/combinator/hr-train-config.png",
                                width = 114,
                                height = 102,
                                frame_count = 1,
                                shift = util.by_pixel(0, 5),
                                tint = { r = 0.2, g = 1, b = 0.8, a = 1 },
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
                color = { r = 1.0, g = 1.0, b = 1.0 }
            },

            activity_led_light_offsets =
            {
                { 0.296875,  -0.40625 },
                { 0.25,      -0.03125 },
                { -0.296875, -0.078125 },
                { -0.21875,  -0.46875 }
            },

            circuit_wire_connection_points =
            {
                {
                    shadow =
                    {
                        red = { 0.15625, -0.28125 },
                        green = { 0.65625, -0.25 }
                    },
                    wire =
                    {
                        red = { -0.28125, -0.5625 },
                        green = { 0.21875, -0.5625 },
                    }
                },
                {
                    shadow =
                    {
                        red = { 0.75, -0.15625 },
                        green = { 0.75, 0.25 },
                    },
                    wire =
                    {
                        red = { 0.46875, -0.5 },
                        green = { 0.46875, -0.09375 },
                    }
                },
                {
                    shadow =
                    {
                        red = { 0.75, 0.5625 },
                        green = { 0.21875, 0.5625 }
                    },
                    wire =
                    {
                        red = { 0.28125, 0.15625 },
                        green = { -0.21875, 0.15625 }
                    }
                },
                {
                    shadow =
                    {
                        red = { -0.03125, 0.28125 },
                        green = { -0.03125, -0.125 },
                    },
                    wire =
                    {
                        red = { -0.46875, 0 },
                        green = { -0.46875, -0.40625 },
                    }
                }
            },

            circuit_wire_max_distance = 9
        },
    }
)

local supply = table.deepcopy(data.raw["train-stop"]["train-stop"])
supply.name = "subscriber-train-stop"
supply.fast_replaceable_group = "station"
supply.icon = "__train-pubsub__/graphics/icons/train-stop-sub.png"
supply.icon_size = 32
supply.minable.result = "subscriber-train-stop"

supply.animations = make_4way_animation_from_spritesheet({
    layers =
    {
        {
            filename = "__train-pubsub__/graphics/train-stop/train-stop-bottom-sub.png",
            --    line_length = 4,
            width = 71,
            height = 146,
            direction_count = 4,
            shift = util.by_pixel(-0.5, -27),
            hr_version =
            {
                filename = "__train-pubsub__/graphics/train-stop/hr-train-stop-bottom-sub.png",
                --        line_length = 4,
                width = 140,
                height = 291,
                direction_count = 4,
                shift = util.by_pixel(-0.5, -26.75),
                scale = 0.5
            }
        },
        {
            filename = "__base__/graphics/entity/train-stop/train-stop-shadow.png",
            --    filename = "__train-pubsub__/graphics/train-stop/train-stop-shadow.png",
            --    line_length = 4,
            width = 361,
            height = 304,
            direction_count = 4,
            shift = util.by_pixel(-7.5, 18),
            draw_as_shadow = true,
            hr_version =
            {
                filename = "__base__/graphics/entity/train-stop/hr-train-stop-shadow.png",
                --       filename = "__train-pubsub__/graphics/train-stop/hr-train-stop-shadow.png",
                --       line_length = 4,
                width = 720,
                height = 607,
                direction_count = 4,
                shift = util.by_pixel(-7.5, 17.75),
                draw_as_shadow = true,
                scale = 0.5
            }
        }
    }
})

local publish = table.deepcopy(data.raw["train-stop"]["train-stop"])
publish.name = "publisher-train-stop"
publish.minable.result = "publisher-train-stop"
publish.icon = "__train-pubsub__/graphics/icons/train-stop-req.png"
publish.icon_size = 32
publish.fast_replaceable_group = "station"
publish.animations = make_4way_animation_from_spritesheet({
    layers =
    {
        {
            filename = "__train-pubsub__/graphics/train-stop/train-stop-bottom-req.png",
            --    line_length = 4,
            width = 71,
            height = 146,
            direction_count = 4,
            shift = util.by_pixel(-0.5, -27),
            hr_version =
            {
                filename = "__train-pubsub__/graphics/train-stop/hr-train-stop-bottom-req.png",
                --        line_length = 4,
                width = 140,
                height = 291,
                direction_count = 4,
                shift = util.by_pixel(-0.5, -26.75),
                scale = 0.5
            }
        },
        {
            filename = "__base__/graphics/entity/train-stop/train-stop-shadow.png",
            --    filename = "__train-pubsub__/graphics/train-stop/train-stop-shadow.png",
            --    line_length = 4,
            width = 361,
            height = 304,
            direction_count = 4,
            shift = util.by_pixel(-7.5, 18),
            draw_as_shadow = true,
            hr_version =
            {
                filename = "__base__/graphics/entity/train-stop/hr-train-stop-shadow.png",
                --       filename = "__train-pubsub__/graphics/train-stop/hr-train-stop-shadow.png",
                --       line_length = 4,
                width = 720,
                height = 607,
                direction_count = 4,
                shift = util.by_pixel(-7.5, 17.75),
                draw_as_shadow = true,
                scale = 0.5
            }
        }
    }
})

local station = table.deepcopy(data.raw["train-stop"]["train-stop"])
station.fast_replaceable_group = "station"

data:extend(
    {
        supply,
        publish,
        station
    }
)