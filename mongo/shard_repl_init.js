rs.initiate(
	{
		_id: "replshard1",
		members: [
			{ _id : 0, host : "server2:37017" }
		]
	}
)
