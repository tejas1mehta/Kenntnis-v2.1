window.Quora = {
  Models: {},
  Collections: {},
  Views: {},
  Routers: {},
  createSession: function(){
    console.log("Creating Session")
    Quora.userSession = new Quora.Models.Session({ email: Quora.currentUser.get("email")});
    // debugger
    $.ajax({
      type: "GET",
      url: "/api/users/" + Quora.currentUser.id + "/userinfo",
      success: function(response){
        console.log("Got User Info")
        Quora.currentUser.parseUserInfo(response)
      }
    })
    var navbarView = new Quora.Views.NavBar({
      model: Quora.currentUser
    });
    $("#navbar").html(navbarView.render().$el)

    Quora.numVisitsPages = {};
  },
  initialize: function() {
    console.log('Hello from Backbone!');
    Quora.currentRouter = new Quora.Routers.Users({
      $rootEl: $("div#content"),
      $navbar: $("div#navbar")
    });

    Backbone.history.start();
    console.log("NEW")
    Quora.relevantQnUsers = new Quora.Collections.Users();
    Quora.userFollowers = new Quora.Collections.Users();
    Quora.answers = new Quora.Collections.Answers();
    Quora.questions = new Quora.Collections.Questions();
    Quora.topics = new Quora.Collections.Answers();
    Quora.followings = new Quora.Collections.Followings();
    Quora.upvotes = new Quora.Collections.Upvotes();
    Quora.relUserJoins = new Quora.Collections.QnRelevantUsers(); //Join table
  }
};



Backbone.CompositeView = Backbone.View.extend({
  addSubview: function (selector, subview) {
    this.subviews(selector).push(subview);
    // Try to attach the subview. Render it as a convenience.
    this.attachSubview(selector, subview.render());
  },

  attachSubview: function (selector, subview) {
    this.$(selector).append(subview.$el);
    // Bind events in case `subview` has previously been removed from
    // DOM.
    subview.delegateEvents();
    if (subview.attachSubviews) {
      subview.attachSubviews();
    }
  },

  attachSubviews: function () {
    // I decided I didn't want a function that renders ALL the
    // subviews together. Instead, I think:
    //
    // * The user of CompositeView should explicitly render the
    //   subview themself when they build the subview object.
    // * The subview should listenTo relevant events and re-render
    //   itself.
    //
    // All that is necessary is "attaching" the subview `$el`s to the
    // relevant points in the parent CompositeView.

    var view = this;
    _(this.subviews()).each(function (subviews, selector) {
      view.$(selector).empty();
      _(subviews).each(function (subview) {
        view.attachSubview(selector, subview);
      });
    });
  },

  remove: function () {
    // $(window).undelegateEvents() //My addition
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

