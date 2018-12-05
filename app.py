#!/usr/bin/env python

import pickle
import logging
import os

import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web
from tornado import gen
from tornado.options import define, options

from prolog import query_prolog

define("environment", default="development", help="Pick you environment", type=str)
define("site_title", default="Train Scheduler", help="Site Title", type=str)
define("cookie_secret", default="sooooooosecret", help="Your secret cookie dough", type=str)
define("port", default="8000", help="Listening port", type=str)

@gen.coroutine
def compute_schedule():
    query_prolog()

class MainHandler(tornado.web.RequestHandler):
    def get(self):
        compute_schedule()
        self.render("main.html")

class ScheduleHandler(tornado.web.RequestHandler):
    def get(self):
        with open('schedule.pkl', 'rb') as f:
            trains = pickle.load(f)
        self.render("schedule.html", trains=trains)

class FourOhFourHandler(tornado.web.RequestHandler):
    def get(self, slug):
        self.render("404.html")


class Application(tornado.web.Application):
    def __init__(self):
        handlers = [
           (r"/", MainHandler),
           (r"/get_schedule", ScheduleHandler),
        ]
        settings = dict(
            site_title=options.site_title,
            cookie_secret=options.cookie_secret,
            template_path=os.path.join(os.path.dirname(__file__), "templates"),
            static_path=os.path.join(os.path.dirname(__file__), "static"),
            xsrf_cookies=True,
            debug=True,
        )
        tornado.web.Application.__init__(self, handlers, **settings)


def main():
    tornado.options.parse_command_line()
    print("Server listening on port ", str(options.port))
    logging.getLogger().setLevel(logging.DEBUG)
    http_server = tornado.httpserver.HTTPServer(Application())
    http_server.listen(options.port)
    tornado.ioloop.IOLoop.instance().start()

if __name__ == "__main__":
    main()
