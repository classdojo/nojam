var jam = {
    "packages": [
        {
            "name": "async",
            "location": "jam/async",
            "main": "lib/async.js"
        },
        {
            "name": "dref",
            "location": "jam/dref",
            "main": "./lib/index.js"
        },
        {
            "name": "events",
            "location": "jam/events",
            "main": "./index.js"
        },
        {
            "name": "outcome",
            "location": "jam/outcome",
            "main": "./lib/index.js"
        },
        {
            "name": "stepc",
            "location": "jam/stepc",
            "main": "./lib/step.js"
        },
        {
            "name": "toarray",
            "location": "jam/toarray",
            "main": "./index.js"
        }
    ],
    "version": "0.2.15",
    "shim": {}
};

if (typeof require !== "undefined" && require.config) {
    require.config({
    "packages": [
        {
            "name": "async",
            "location": "jam/async",
            "main": "lib/async.js"
        },
        {
            "name": "dref",
            "location": "jam/dref",
            "main": "./lib/index.js"
        },
        {
            "name": "events",
            "location": "jam/events",
            "main": "./index.js"
        },
        {
            "name": "outcome",
            "location": "jam/outcome",
            "main": "./lib/index.js"
        },
        {
            "name": "stepc",
            "location": "jam/stepc",
            "main": "./lib/step.js"
        },
        {
            "name": "toarray",
            "location": "jam/toarray",
            "main": "./index.js"
        }
    ],
    "shim": {}
});
}
else {
    var require = {
    "packages": [
        {
            "name": "async",
            "location": "jam/async",
            "main": "lib/async.js"
        },
        {
            "name": "dref",
            "location": "jam/dref",
            "main": "./lib/index.js"
        },
        {
            "name": "events",
            "location": "jam/events",
            "main": "./index.js"
        },
        {
            "name": "outcome",
            "location": "jam/outcome",
            "main": "./lib/index.js"
        },
        {
            "name": "stepc",
            "location": "jam/stepc",
            "main": "./lib/step.js"
        },
        {
            "name": "toarray",
            "location": "jam/toarray",
            "main": "./index.js"
        }
    ],
    "shim": {}
};
}

if (typeof exports !== "undefined" && typeof module !== "undefined") {
    module.exports = jam;
}