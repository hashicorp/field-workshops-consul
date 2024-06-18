# How to safely test Instruqt tracks

Instruqt can be a bit finicky when it comes to testing tracks, because
it appears internally to use track and challenge IDs and embeds them
in your `track.yml` and `assigment.md` files when you push tracks. This
can cause a problem when trying to make a test version of the track; if
you are not careful you can confuse Instruqt or cause it to overwrite
the production version of a track. 

What follows is our standard flow and procedure for making a test 
version of the track.

# Standard Flow

1. Create a Jira ticket for your work—all work should be logged and
   documented in a Jira ticket anyways, and we use the ticket identifier
   to provide context when committing changes. For this document, we're
   going to assume you have a ticket number of `IL-99999`
1. Ensure you are on the `master` branch of this repo (the current default
   branch) and do not have uncommited changes. Pull the latest from 
   `origin` (e.g. `git pull origin master`)
1. Create a branch for this work, e.g. `git checkout -b IL-99999`
1. In the track directory, run the command
   `make jira=IL-99999 alternate_track`
   - This removes the `track.yml` id and checksum fields, and all
     of the `assignment.md` id fields
   - It also changes the track slug so it starts with 
     `wip-il-99999-<original slug`, and the track title to start
     with `WIL IL-99999 - <Original Title>`
   - The end result of this is that Instruqt will treat this like
     an entirely independent track, as well as make it easy to
     distinguish this as a test track
1. Do whatever work you need to do. You can safely `instruqt track push`
   to test your track
1. When it becomes time to merge, change the track slug and title 
   to remove the `wip-il-99999-` and `WIP IL-99999 - ` prefixes. If there
   are any track or challenge 'id:' fields, or any track 'checksum:' fields
   you should remove them; `make clean_id_and_checksums` will do that for
   you

*Note* it is our convention that all commit messages start with the
jira ticket number, e.g.:

> IL-99999 Add support for HashiCups
>
> Update the Fizbin track to show HashiCups usage
