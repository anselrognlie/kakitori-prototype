# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Running importers

rails runner \<script*name>

## Login Process

* if no current user
  * if no user
    * create 'default' user
    * make default user the current user
  * else
    * select most current user as current user

### Data design

* Kanjidic
  * glyph
  * ucs codepoint
  * meaning list
  * reading list (on, kun, nanori)
  * grade
  * stroke count
  * frequency
  * jlpt level (old 4*level system)

* Kanken
  * glyph
  * gloss list
  * level (only up to 2)

* WaniKani
  * glyph
  * level

* JLPT (new)
  * glyph
  * level
