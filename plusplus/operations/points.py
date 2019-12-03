from plusplus.models import db, Thing
import json
import random


def update_points(thing, end, is_self=False):
    if is_self and end != '==':  # don't allow someone to plus themself
        operation = "self"
    elif end == "++":
        operation = "plus"
        thing.increment()
    elif end == "--":
        return "That's not very nice of you, would you like us to decrement your own points instead?  Didn't think so."
    else:
        operation = "equals"
    db.session.add(thing)
    db.session.commit()
    return generate_string(thing, operation)


def generate_string(thing, operation):
    if thing.user:
        formatted_thing = f"<@{thing.item.upper()}>"
    else:
        formatted_thing = thing.item
    points = thing.points
    with open("plusplus/strings.json", "r") as strings:
        parsed = json.load(strings)
        if operation in ["plus", "minus"]:
            exclamation = random.choice(parsed[operation])
            points = random.choice(parsed[operation + "_points"]).format(thing=formatted_thing, points=points)
            return f"{exclamation} {points}"
        elif operation == "self":
            return random.choice(parsed[operation]).format(thing=formatted_thing)
        elif operation == "equals":
            return random.choice(parsed[operation]).format(thing=formatted_thing, points=points)
        else:
            return ""  # probably unnecessary, but here as a fallback
