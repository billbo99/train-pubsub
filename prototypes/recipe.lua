
data:extend({
  {
	type = "recipe",
	name = "train-counter",
	enabled = false,
	ingredients =
	{
		{"small-lamp", 1},
		{"electronic-circuit", 4}
	},
	result = "train-counter"
  },
  {
	type = "recipe",
	name = "train-publisher",
	enabled = false,
	ingredients =
	{
		{"small-lamp", 1},
		{"electronic-circuit", 4}
	},
	result = "train-publisher"
  },
   {
    type = "recipe",
    name = "subscriber-train-stop",
    enabled = false,
    ingredients =
    {
      {"train-stop", 1},
	  {"electronic-circuit", 2}
    },
    result = "subscriber-train-stop"
  },
     {
    type = "recipe",
    name = "publisher-train-stop",
    enabled = false,
    ingredients =
    {
      {"train-stop", 1},
	  {"electronic-circuit", 2}
    },
    result = "publisher-train-stop"
  },
  {
	type = "recipe",
	name = "train-config",
	enabled = false,
	ingredients =
	{
		{"constant-combinator", 1},
		{"electronic-circuit", 2}
	},
	result = "train-config"
  },
--[[   {
	type = "recipe",
	name = "circuit-requester",
	enabled = false,
	ingredients =
	{
		{"constant-combinator", 1},
		{"electronic-circuit", 4}
	},
	result = "circuit-requester"
  },   ]]

})
