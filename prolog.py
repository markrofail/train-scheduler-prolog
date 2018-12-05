import pickle

from pyswip import Prolog

prolog_to_python = dict([
    ("Functor", ""),
    ("(", "["),
    (")", "]"),
    ("a", "\'a\'"),
    ("b", "\'b\'"),
    ("c", "\'c\'"),
    ("d", "\'d\'"),
    ("e", "\'e\'"),
    ("f", "\'f\'"),
    ("g", "\'g\'"),
    ("h", "\'h\'"),
    ("i", "\'i\'"),
    ("j", "\'j\'"),
    ("k", "\'k\'"),
    ("l", "\'l\'"),
    ("m", "\'m\'"),
])

def parse_graph(prolog_output):
    trains = list()
    for train_path in prolog_output:
        train_path = str(train_path)

        for key, value in prolog_to_python.items():
            train_path = train_path.replace(key, value)

        train_path = eval(train_path)
        for node in train_path:
            node[1] = node[1][-1]
            node[2] = convert_time(node[2])
            node[3] = convert_time(node[3])
            node[4] = convert_time(node[4])

        trains.append(train_path)

    with open('schedule.pkl', mode='wb') as schedule_file:
        pickle.dump(trains, schedule_file, pickle.HIGHEST_PROTOCOL)

def convert_time(number):
    hour = number//60
    minute = number - hour*60
    return '{hour}h {minute}m'.format(hour=hour, minute=minute)

def query_prolog():
    print("I am working ###################################")
    prolog = Prolog()
    prolog.consult("prolog/main.pl")

    for res in prolog.query("once(dispatcher(Schedule, Tardiness))"):
        parse_graph(res['Schedule'])

if __name__ == "__main__":
    query_prolog()
