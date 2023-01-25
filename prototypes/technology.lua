data:extend({
  {
      type = "technology",
      name = "train-manager",
      icon = "__train-pubsub__/graphics//technology/train-supply-manager.png",
      icon_size = 128,
      prerequisites = {"circuit-network", "automated-rail-transportation", "optics"},
      effects =
      {
        {
            type = "unlock-recipe",
            recipe = "subscriber-train-stop"
        },
       {
            type = "unlock-recipe",
            recipe = "publisher-train-stop"
        },
	    	{
            type = "unlock-recipe",
            recipe = "train-publisher"
        },
		    {
            type = "unlock-recipe",
            recipe = "train-config"
        },
--[[         {
          type = "unlock-recipe",
          recipe = "circuit-requester"
       },	         ]]
      },
      unit =
      {
        count = 50,
        ingredients =
        {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
        },
        time = 20
      }
  }
})
