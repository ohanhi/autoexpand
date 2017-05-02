# AutoExpand

Autoexpanding textarea in Elm.

This is a simple reusable view for those times when you want to show a small
text box to begin with, but want the space to grow as the user types in more
stuff.

For now, the box can only grow but not shrink back to a smaller size.

For packaging this, I took a lot of influence from the evancz/elm-sortable-table
package. This means the same two general rules apply:

- Always put AutoExpand.State in your model.
- Never put AutoExpand.Config in your model.


# Usage

Take a look at the example to get a good idea of how to use this.

- [Runnable version on Ellie](https://ellie-app.com/35rzD8CvHh9a1/1)
- [Source code on GitHub](https://github.com/ohanhi/autoexpand/blob/master/examples/Simple.elm)
