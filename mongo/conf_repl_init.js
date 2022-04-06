rs.initiate(
	{
		_id: "replconfig01",
		configsvr: true,
		members: [
			{ _id : 0, host : "server1:57040" },
			{ _id : 1, host : "server2:57040" }
		]
	}
)
