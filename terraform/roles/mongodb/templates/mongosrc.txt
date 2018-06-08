use dashboarddb

db.createUser(
    {
        user: "dashboarduser",
        pwd: "dashboardpw",
        roles: [
            {role: "readWrite", db: "dashboard"}
        ]
    })
db.dummmyCollection.insert({x: 1});
