window.Quora = {
  Models: {},
  Collections: {},
  Views: {},
  Routers: {},
  createSession: function(){
    Quora.currentUser.fetch({data: {
         data_to_fetch: "user_info"
        },
        success: function(){
          Quora.navbarView = new Quora.Views.NavBar({
            model: Quora.currentUser
          });
          $("#navbar").html(Quora.navbarView.render().$el)
          // $('#notif_btn').popover({trigger: "hover"})
        }
    })

    Quora.allUsers = Quora.allUsers || new Quora.Collections.Users();
    Quora.allUsers.add(Quora.currentUser)
    Quora.users = Quora.allUsers


    Quora.numVisitsPages = {};
  },
  initialize: function() {

    Quora.allUsers = Quora.allUsers || new Quora.Collections.Users();
    Quora.answers = new Quora.Collections.Answers();
    Quora.questions = new Quora.Collections.Questions();
    Quora.topics = new Quora.Collections.Topics();
    Quora.followings = new Quora.Collections.Followings();
    Quora.upvotes = new Quora.Collections.Upvotes();
    Quora.topicQuestionJoins = new Quora.Collections.TopicQuestionJoins();
    Quora.relUserJoins = new Quora.Collections.QnRelevantUsers(); //Join table
    Quora.notifications = new Quora.Collections.Notifications();

    Quora.currentRouter = new Quora.Routers.Users({
      $rootEl: $("div#content"),
      $navbar: $("div#navbar")
    });

    if (!Backbone.History.started){
          Backbone.history.start();
    }

    Backbone.history.navigate(window.location.hash, { trigger: true }) 
    
  }
};

Backbone.CompositeView = Backbone.View.extend({
  addSubview: function (selector, subview) {
    this.subviews(selector).push(subview);
    // Try to attach the subview. Render it as a convenience.
    this.attachSubview(selector, subview.render());
  },

  attachSubview: function (selector, subview, prepend) {
    if (prepend){
      this.$(selector).prepend(subview.$el);
    } else {
      this.$(selector).append(subview.$el);
    }
    // Bind events in case `subview` has previously been removed from
    // DOM.
    subview.delegateEvents();
    if (subview.attachSubviews) {
      subview.attachSubviews();
    }
  },

  attachSubviews: function () {
    var view = this;
    _(this.subviews()).each(function (subviews, selector) {
      view.$(selector).empty();
      _(subviews).each(function (subview) {
        view.attachSubview(selector, subview);
      });
    });
  },

  remove: function () {
    if (this.filCols){
      this.filCols.forEach(function(filCol){
        filCol.trigger("unbind")
      })
    }
    Backbone.View.prototype.remove.call(this);
    _(this.subviews()).each(function (subviews) {
      _(subviews).each(function (subview) { subview.remove(); });
    });
  },

  removeSubview: function (selector, subview) {
    subview.remove();

    var subviews = this.subviews(selector);
    subviews.splice(subviews.indexOf(subview), 1);
  },

  removeAllSubviews: function(selector){
    var view = this;
    var selectorSubviews = this.subviews(selector);
    var i = 0;
    var lengthSubviews = selectorSubviews.length
    while (i < lengthSubviews){
      i += 1;
      subview = selectorSubviews["0"];
      view.removeSubview(selector, subview)
    }
  },

  subviews: function (selector) {
    // Map of selectors to subviews that live inside that selector.
    // Optionally pass a selector and I'll initialize/return an array
    // of subviews for the sel.
    this._subviews = this._subviews || {};

    if (!selector) {
      return this._subviews;
    } else {
      this._subviews[selector] = this._subviews[selector] || [];
      return this._subviews[selector];
    }
  }
});


$(document).ready(function(){
  Quora.initialize();
});

var originalRoute = Backbone.Router.prototype.route;

// Create a reusable no operation func for the case where a before
// or after filter is not set. Backbone or Underscore should have
// a global one of these in my opinion.
var nop = function(){};

// Extend the router prototype with a default before function,
// a default after function, and a pave over of _bindRoutes.
_.extend(Backbone.Router.prototype, {

  // Add default before filter.
  before: nop,

  // Add default after filter.
  after: nop,

  // Pave over Backbone.Router.prototype.route, the public method used
  // for adding routes to a router instance on the fly, and the
  // method which backbone uses internally for binding routes to handlers
  // on the Backbone.history singleton once it's instantiated.
  route: function(route, name, callback) {

    // If there is no callback present for this route, then set it to
    // be the name that was set in the routes property of the constructor,
    // or the name arguement of the route method invocation. This is what
    // Backbone.Router.route already does. We need to do it again,
    // because we are about to wrap the callback in a function that calls
    // the before and after filters as well as the original callback that
    // was passed in.
    if( !callback ){
      callback = this[ name ];
    }
    var executeFn
    // Create a new callback to replace the original callback that calls
    // the before and after filters as well as the original callback
    // internally.
    var wrappedCallback = _.bind( function() {

      // Call the before filter and if it returns false, run the
      // route's original callback, and after filter. This allows
      // the user to return false from within the before filter
      // to prevent the original route callback and after
      // filter from running.
      var callbackArgs = [ route, _.toArray(arguments) ];
      var beforeCallback;

      if ( _.isFunction(this.before) ) {

        // If the before filter is just a single function, then call
        // it with the arguments.
        beforeCallback = this.before;
      } else if ( typeof this.before[route] !== "undefined" ) {

        // otherwise, find the appropriate callback for the route name
        // and call that.
        beforeCallback = this.before[route];
      } else {

        // otherwise, if we have a hash of routes, but no before callback
        // for this route, just use a nop function.
        beforeCallback = nop;
      }

      // If the before callback fails during its execusion (by returning)
      // false, then do not proceed with the route triggering.
      executeFn = beforeCallback.apply(this, callbackArgs);
      // if (  === false ) {
      //   return;
      // }

      // If the callback exists, then call it. This means that the before
      // and after filters will be called whether or not an actual
      // callback function is supplied to handle a given route.
      if( callback ) {
        callback.apply( this, arguments );
      }

      var afterCallback;
      if ( _.isFunction(this.after) ) {

        // If the after filter is a single funciton, then call it with
        // the proper arguments.
        afterCallback = this.after;

      } else if ( typeof this.after[route] !== "undefined" ) {

        // otherwise if we have a hash of routes, call the appropriate
        // callback based on the route name.
        afterCallback = this.after[route];

      } else {

        // otherwise, if we have a has of routes but no after callback
        // for this route, just use the nop function.
        afterCallback = nop;
      }

      // Call the after filter.
      afterCallback.apply( this, callbackArgs );

    }, this);

    // Call our original route, replacing the callback that was originally
    // passed in when Backbone.Router.route was invoked with our wrapped
    // callback that calls the before and after callbacks as well as the
    // original callback.
    if (executeFn !== false){
      return originalRoute.call( this, route, name, wrappedCallback );
    }
  }

});