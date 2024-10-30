data:extend({
    {
        type = "recipe",
        name = "train-counter",
        enabled = false,
        ingredients =
        {
            { name = "small-lamp",         amount = 1, type = "item" },
            { name = "electronic-circuit", amount = 4, type = "item" }
        },
        results = { { name = "train-counter", amount = 1, type = "item" } }
    },
    {
        type = "recipe",
        name = "train-publisher",
        enabled = false,
        ingredients =
        {
            { name = "small-lamp",         amount = 1, type = "item" },
            { name = "electronic-circuit", amount = 4, type = "item" }
        },
        results = { { name = "train-publisher", amount = 1, type = "item" } }
    },
    {
        type = "recipe",
        name = "subscriber-train-stop",
        enabled = false,
        ingredients =
        {
            { name = "train-stop",         amount = 1, type = "item" },
            { name = "electronic-circuit", amount = 2, type = "item" }
        },
        results = { { name = "subscriber-train-stop", amount = 1, type = "item" } }
    },
    {
        type = "recipe",
        name = "publisher-train-stop",
        enabled = false,
        ingredients =
        {
            { name = "train-stop",         amount = 1, type = "item" },
            { name = "electronic-circuit", amount = 2, type = "item" }
        },
        results = { { name = "publisher-train-stop", amount = 1, type = "item" } }
    },
    {
        type = "recipe",
        name = "train-config",
        enabled = false,
        ingredients =
        {
            { name = "constant-combinator", amount = 1, type = "item" },
            { name = "electronic-circuit",  amount = 2, type = "item" }
        },
        results = { { name = "train-config", amount = 1, type = "item" } }
    },
})