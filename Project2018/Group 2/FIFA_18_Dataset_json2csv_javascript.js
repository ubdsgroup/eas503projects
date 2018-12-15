var jc = require("json2csv");
var fs = require("fs");

var ls = fs.readdirSync("./");

var files = ls.filter(function(filename) {
    return filename.match(/^[0-9]+.json/) !== null;
});

var full = [];

var data = null;
for (var file of files) {
    data = fs.readFileSync(file);
    data = JSON.parse(data);

    for (var i = 0; i < data.length; i++)
        data[i]["match_id"] = file.substring(0, file.indexOf("."));

    full = full.concat(data);
    console.log("Finished reading: " + file);
}

console.log("Total rows: " + full.length);

var csv;

var columns = [
    "match_id",
    "id",
    "index",
    "period",
    "timestamp",
    "type.name",
    "possession",
    "possession_team.name",
    "play_pattern.name",
    "team.name",
    "duration",
    "related_events.0",
    "player.name",
    "position.name",
    "location.0",
    "location.1",
    "pass.recipient.id",
    "pass.recipient.name",
    "pass.length",
    "pass.angle",
    "pass.height.id",
    "pass.height.name",
    {
        label: "pass.end_location.0",
        value: "pass.end_location[0]"
    },
    {
        label: "pass.end_location.1",
        value: "pass.end_location[1]"
    },
    "pass.type.id",
    "pass.type.name",
    "under_pressure",
    "pass.aerial_won",
    "duel.type.id",
    "duel.type.name",
    "duel.outcome.id",
    "duel.outcome.name",
    "interception.outcome.id",
    "interception.outcome.name",
    "pass.switch",
    "pass.cross",
    "dribble.outcome.id",
    "dribble.outcome.nam",
    "foul_committed.type.id",
    "foul_committed.type.name",
    "clearance.aerial_won",
    "ball_recovery.recovery_failure",
    "foul_committed.advantage",
    "foul_won.advantage",
    "pass.assisted_shot_id",
    "pass.shot_assist",
    "shot.statsbomb_xg",
    {
        label: "shot.end_location.0",
        value: "shot.end_location[0]"
    },
    {
        label: "shot.end_location.1",
        value: "shot.end_location.1"
    },
    {
        label: "shot.end_location.2",
        value: "shot.end_location[2]"
    },
    "shot.body_part.id",
    "shot.body_part.name",
    "shot.outcome.id",
    "shot.outcome.name",
    "shot.type.id",
    "shot.type.name",
    {
        label: "shot.freeze_frame.0.location.0",
        value: "shot.freeze_frame[0].location[0]"
    },
    {
        label: "shot.freeze_frame.0.location.1",
        value: "shot.freeze_frame[0].location[1]"
    },
    "foul_committed.card.id",
    "foul_committed.card.name",
    "pass.goal_assist",
    "block.deflection",
    "foul_committed.penalty",
    "shot.one_on_one",
    "shot.open_goal",
];

try {
    console.log("Converting combined data to CSV...");
    csv = jc.parse(full, {
        fields: columns
    });
    console.log("Finished converting to CSV.");
} catch (err) {
    console.log("Error: " + err);
}

console.log("Writing to output file...");
fs.writeFileSync("out.csv", csv);
console.log("Finished writing to output file.");
