# nginXtra

Let's try out all the directives in nginx!

## Getting Started

You'll need nginx.

Then, run some scripts:

```
$ ./scripts/setup.sh
$ ./scripts/enable-configuration.sh PICK_A_CONFIG_FILE.conf
$ ./scripts/develop.sh
```

Now every time you change your configuration file, nginx will receive a
SIGHUP signal and reload the configuration.

This isn't necessarily foolproof, so if it doesn't reload and you think it
should, go ahead and open an issue.

## The Goal

At the end, it's my hope that we'll have a collection of readable,
complete examples of every directive in nginx, which will be faster to
navigate and understand than the hyperlinked online docs. There will be a
config file containing _every_ directive, and a config file containing as
few as possible, and a lot of config files in-between.

Maybe, these configuration files can serve as well-explained defaults for
new installations of nginx. The explanations aren't just good for newbies,
after all - they also work as reminders for those of us who can never
quite remember exactly how the config works. :)

## The Smallest Config

Is just an `events` context:

```
events {}
```

I determined this by starting with an empty file, and fixing all the
errors during `nginx` startup.

- Is this actually the smallest *usable* configuration?
- Why is the events context the *only* mandatory syntax?

So far as I can tell, these questions aren't answered by the
documentation. They also aren't very useful questions. Curious, though.

## The Largest Config

Should contain an example of every directive and commonplace configuration
in nginx, and should clearly document every directive's type(s) and
default value(s). A reference sheet, if you will.

The Largest nginx.conf is the goal of this project. Starting from the
smallest, we'll slowly add until we've used every directive.

As every directive is added, commentary in the config file will provide an
annotated, hopefully somewhat flavorful and interesting, rundown of the
official documentation for that directive.
