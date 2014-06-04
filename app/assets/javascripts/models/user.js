Quora.Models.User = Backbone.Model.extend({
	urlRoot: "api/users",

  questionsFollowed: function () {
    this._questionsFollowed = this._questionsFollowed ||
      new Quora.Collections.Questions
      ([], { todo: this });
    return this._comments;
  },
	// parse and association arrays
  parseObjects: function(response){
    user = this;
    user.objectsView = []
    if(response.results){
      response.results.forEach(function(result){
        switch(result.resultclass){
          case("Answer"):
            var newAnswer = new Quora.Models.QuestionAnswer(result,{parse: true});
            var answerView = new Quora.Views.AnswerFullShow({model: newAnswer});
            user.objectsView.push(answerView)
            break;
          case("Question"):
            var newQuestion = new Quora.Models.Question(result,{parse: true});
            var questionView = new Quora.Views.QuestionMiniShow({model: newQuestion})
            user.objectsView.push(questionView)
            break;
        }
      })
      delete response.results 
    }

  },

  parseUserObjects: function(response){
    user = this;
    user.userObjectsView = []
    if(response.results){
      response.results.forEach(function(result){
            var newUser = new Quora.Models.User(result);
            var userView = new Quora.Views.UserMiniShow({model: newUser})
            user.userObjectsView.push(userView)  
            if (result.user_followers_join){
              result.user_followers_join.forEach(function(following_join){
                var newFollowing = new Quora.Models.Following(following_join, {parse: true}) //can remove parse?

                var followingExists = Quora.followings.models.filter(function(model) {return model.id === newFollowing.id});
                if (followingExists.length === 0){
                  Quora.followings.add(newFollowing)
                }
              })
            }              

      })
      delete response.results 
    }
  },

  parseProfile: function(response){
    user = this;
    user.profileView = []
    // debugger
    if(response.results){
      console.log(response.results)
      response.results.forEach(function(result){
        switch(result.resultclass){
          case("Answer"):
            var newAnswer = new Quora.Models.QuestionAnswer(result,{parse: true});
            var answerView = new Quora.Views.AnswerFullShow({model: newAnswer});
            user.profileView.push(answerView)
            break;
          case("Question"):
            var newQuestion = new Quora.Models.Question(result,{parse: true});
            var questionView = new Quora.Views.QuestionMiniShow({model: newQuestion})
            user.profileView.push(questionView)
            break;
        }
      })
      delete response.results 
    }

    if (response.user_followers_join){
      response.user_followers_join.forEach(function(following_join){
        var newFollowing = new Quora.Models.Following(following_join) //can remove parse?

        var followingExists = Quora.followings.models.filter(function(model) {return model.id === newFollowing.id});
        if (followingExists.length === 0){
          Quora.followings.add(newFollowing)
        }      
      })
      delete response.user_followers_join
    }

    user.set(response)
    debugger
    console.log("USER PROFILE" + user)
    return response
  },
  
  parseFeed: function(response){
    // user = this;
    Quora.currentUser.feedView = []
    if (response.results){
      response.results.forEach(function(result){
        switch(result.resultclass){
          case("Answer"):
            var newAnswer = new Quora.Models.QuestionAnswer(result,{parse: true});
            var answerView = new Quora.Views.AnswerFullShow({model: newAnswer});
            Quora.currentUser.feedView.push(answerView)
            // debugger
            Quora.currentUser.lastFeedAnswerTime = newAnswer.sort_time
            break;
          case("Question"):
            var newQuestion = new Quora.Models.Question(result,{parse: true});
            var questionView = new Quora.Views.QuestionMiniShow({model: newQuestion})
            Quora.currentUser.feedView.push(questionView)
            Quora.currentUser.lastFeedQuestionTime = newQuestion.sort_time
            break;
        }
      })
      delete response.results
    }
    Quora.currentUser.recUserViews = []
    if (response.rec_users){
      response.rec_users.forEach(function(rec_user){
        // check to see if already followed?
        var newUser = new Quora.Models.User(rec_user,{parse: true});
        var newUserView = new Quora.Views.UserMiniShow({model: newUser});
        // debugger
        Quora.currentUser.recUserViews.push(newUserView)

        if (rec_user.user_followers_join){
          rec_user.user_followers_join.forEach(function(following_join){
            var newFollowing = new Quora.Models.Following(following_join, {parse: true}) //can remove parse?

            var followingExists = Quora.followings.models.filter(function(model) {return model.id === newFollowing.id});
            if (followingExists.length === 0){
              Quora.followings.add(newFollowing)
            }
          })
        }

      })
    }

    delete response.rec_users
    return response
  },

    parseSearch: function(response){
      // debugger
      // response
      user = this;
      user.searchView = []
      response.results.forEach(function(result){
        debugger
        console.log(result)
        if (result.main_question){
          var newQuestion = new Quora.Models.Question(result,{parse: true});

          var questionView = new Quora.Views.QuestionMiniShow({model: newQuestion})
          user.searchView.push(questionView)
        } else if (result.name){
          var newUser = new Quora.Models.User(result);
          var userView = new Quora.Views.UserMiniShow({model: newUser})
          user.searchView.push(userView)
        } else {
          var newTopic = new Quora.Models.Topic(result ,{parse: true});

          var topicView = new Quora.Views.TopicMiniShow({model: newTopic})
          user.searchView.push(topicView)
        }

      })
    },

    parseUserInfo: function(response){
      // debugger
      // Quora.currentUser = new Quora.Models.User(response)
      Quora.userFollowers = new Quora.Collections.Users();
      Quora.userFollowers.add(Quora.currentUser)
      console.log("Session loggedin")
      // debugger
      if (response.followings_join){
        response.followings_join.forEach(function(following_join){
          var newFollowing = new Quora.Models.Following(following_join, {parse: true})

          var followingExists = Quora.followings.models.filter(function(model) {return model.id === newFollowing.id});
          if (followingExists.length === 0){
            Quora.followings.add(newFollowing)
          }
        })
      }

      if (response.upvoted_join){
        response.upvoted_join.forEach(function(upvote_join){
          var newUpvote = new Quora.Models.Upvote(upvote_join , {parse: true})

          var upvoteExists = Quora.upvotes.models.filter(function(model) {return model.id === newUpvote.id});
          if (upvoteExists.length === 0){
            Quora.upvotes.add(newUpvote)
          }
        })
      }
      
    },
})
//
//   parse: function (response) {
//     var user = this;
//
//     user.profileView = [];
//     if (response.questions_created) {
//       user.questionsCreated = [];
//       (response.questions_created).forEach(function(questionCreated){
//         var newQuestion = new Quora.Models.Question(questionCreated,{parse: true});
//         var questionView = new Quora.Views.QuestionMiniShow({model: newQuestion})
//         user.profileView.push(questionView)
//       })
//
//       delete response.questions_created;
//     }
//
//     if (response.answers_created) {
//       user.answersCreated = [];
//       (response.answers_created).forEach(function(answerCreated){
//         var newAnswer = new Quora.Models.QuestionAnswer(answerCreated,{parse: true});
//         var answerView = new Quora.Views.AnswerFullShow({model: newAnswer});
//         user.profileView.push(answerView)
//       })
//
//       delete response.answers_created;
//     }
//
//     if (response.questions_followed) {
//       (response.questions_followed).forEach(function(questionFollowed){
//         var newQuestion = new Quora.Models.Question(questionFollowed,{parse: true});
//         var questionView = new Quora.Views.QuestionMiniShow({model: newQuestion})
//         user.profileView.push(questionView)
//
//         var newFollowing = new Quora.Models.Following(questionFollowed.following)
//         var followingExists = Quora.followings.models.filter(function(model) {return model.id === newFollowing.id})
//         if (followingExists.length === 0){
//           Quora.followings.add(newFollowing)
//         }
//       })
//
//       delete response.questions_followed;
//     }
//
//     if (response.topics_followed) {
//       (response.topics_followed).forEach(function(topicFollowed){
//         var newTopic = new Quora.Models.Topic(topicFollowed,{parse: true});
//         var topicView = new Quora.Views.TopicShow({model: newTopic})
//         user.profileView.push(topicView)
//
//         var newFollowing = new Quora.Models.Following(topicFollowed.following)
//         var followingExists = Quora.followings.models.filter(function(model) {return model.id === newFollowing.id})
//         if (followingExists.length === 0){
//           Quora.followings.add(newFollowing)
//         }
//       })
//
//       delete response.topics_followed;
//     }
//
//     if (response.answers_upvoted) {
//       (response.answers_upvoted).forEach(function(answerUpvoted){
//         var newAnswer = new Quora.Models.QuestionAnswer(answerUpvoted ,{parse: true});
//         var answerView = new Quora.Views.AnswerFullShow({model: newAnswer})
//         user.profileView.push(answerView)
//
//         var newUpvote = new Quora.Models.Upvote(answerUpvoted.upvote);
//         var upvoteExists = Quora.upvotes.models.filter(function(model) {return model.id === newUpvote.id});
//         if (upvoteExists.length === 0){
//           Quora.upvotes.add(newUpvote)
//         }
//       })
//         //Add authors name
//       delete response.answers_upvoted;
//     }
//
//     if (response.questions_upvoted) {
//       (response.questions_upvoted).forEach(function(questionUpvoted){
//         var newQuestion = new Quora.Models.Question(questionUpvoted ,{parse: true});
//         var questionView = new Quora.Views.QuestionMiniShow({model: newQuestion})
//         user.profileView.push(questionView)
//
//         var newUpvote = new Quora.Models.Upvote(questionUpvoted.upvote);
//         var upvoteExists = Quora.upvotes.models.filter(function(model) {return model.id === newUpvote.id});
//         if (upvoteExists.length === 0){
//           Quora.upvotes.add(newUpvote)
//         }
//       })
//         //Add authors name
//       delete response.questions_upvoted;
//     }
//
//     function getUniqueViews(viewArray) {
//        var arrayLength = viewArray.length;
//        var uniqueViews = [];
//        var uniqueIds = [];
//        for(var i = 0; i < arrayLength; i++){
//          newView = viewArray[i]
//          if (uniqueIds.indexOf(newView.model.id) === -1){
//            uniqueViews.push(newView)
//            uniqueIds.push(newView.model.id)
//          }
//        }
//
//        return uniqueViews
//     }
//     user.profileView = getUniqueViews(user.profileView)
//
//     user.profileView.sort(function(profView1, profView2){
//       var datetimeobj1 = new Date(profView1.model.attributes.created_at);
//       var datetimeobj2 = new Date(profView2.model.attributes.created_at);
//
//       // console.log(datetimeobj)
//       // console.log(datetimeobj.getMilliseconds())
//       return (datetimeobj2.getTime() - datetimeobj1.getTime())
//     });
//
//     // debugger
//     // if (response.users_followed) {
//     //   user.usersFollowed = [];
//     //   (response.users_followed).forEach(function(userFollowed){
//     //     var newUserFollowed = new Quora.Models.User(userFollowed);
//     //     user.usersFollowed.push(newUserFollowed)
//
//     //     var userView = new Quora.Views.(model: newTopic)
//     //     user.profileView.push(topicView)
//     //     })
//
//     //   delete response.questions_created;
//     // }
//
//     return response;
//   },
//
//   parseSearch: function(response){
//     // debugger
//     // response
//     user = this;
//     user.searchView = []
//     response.results.forEach(function(result){
//       debugger
//       console.log(result)
//       if (result.main_question){
//         var newQuestion = new Quora.Models.Question(result,{parse: true});
//
//         var questionView = new Quora.Views.QuestionMiniShow({model: newQuestion})
//         user.searchView.push(questionView)
//       } else if (result.name){
//         var newUser = new Quora.Models.User(result);
//         var userView = new Quora.Views.UserMiniShow({model: newUser})
//         user.searchView.push(userView)
//       } else {
//         var newTopic = new Quora.Models.Topic(result ,{parse: true});
//
//         var topicView = new Quora.Views.TopicMiniShow({model: newTopic})
//         user.searchView.push(topicView)
//       }
//
//     })
//   },
//
//   parseFeed: function (response) {
//     var user = this;
//
//     user.feedView = [];
//     if (response.questions_created) {
//       (response.questions_created).forEach(function(questionCreated){
//         var newQuestion = new Quora.Models.Question(questionCreated,{parse: true});
//         var questionView = new Quora.Views.QuestionMiniShow({model: newQuestion})
//         user.feedView.push(questionView)
//       })
//
//       delete response.questions_created;
//     }
//
//     // if (response.answers_created) {
//     //   (response.answers_created).forEach(function(answerCreated){
//     //     var newAnswer = new Quora.Models.QuestionAnswer(answerCreated,{parse: true});
//     //     var answerView = new Quora.Views.AnswerFullShow({model: newAnswer});
//     //     user.feedView.push(answerView)
//     //   })
//     //
//     //   delete response.answers_created;
//     // }
//     //
//     // if (response.questions_followed) {
//     //   (response.questions_followed).forEach(function(questionFollowed){
//     //     var newQuestion = new Quora.Models.Question(questionFollowed,{parse: true});
//     //     var questionView = new Quora.Views.QuestionMiniShow({model: newQuestion})
//     //     user.feedView.push(questionView)
//     //   })
//     //   delete response.questions_followed;
//     // }
//     //
//     // if (response.topics_followed) {
//     //   (response.topics_followed).forEach(function(topicFollowed){
//     //     var newTopic = new Quora.Models.Topic(topicFollowed,{parse: true});
//     //     var topicView = new Quora.Views.TopicShow({model: newTopic})
//     //     user.feedView.push(topicView)
//     //   })
//     //
//     //   delete response.questions_created;
//     // }
//     //
//     // if (response.answers_upvoted) {
//     //   (response.answers_upvoted).forEach(function(answerUpvoted){
//     //     var newAnswer = new Quora.Models.QuestionAnswer(answerUpvoted ,{parse: true});
//     //     var answerView = new Quora.Views.AnswerFullShow({model: newAnswer})
//     //     user.feedView.push(answerView)
//     //   })
//     //     //Add authors name
//     //   delete response.questions_followed;
//     // }
//     //
//     // if (response.questions_upvoted) {
//     //   (response.questions_upvoted).forEach(function(questionUpvoted){
//     //     var newQuestion = new Quora.Models.Question(questionUpvoted ,{parse: true});
//     //     var questionView = new Quora.Views.QuestionMiniShow({model: newQuestion})
//     //     user.feedView.push(questionView)
//     //   })
//     //     //Add authors name
//     //   delete response.questions_followed;
//     // }
//     //
//     // function getUniqueViews(viewArray) {
//     //    var arrayLength = viewArray.length;
//     //    var uniqueViews = [];
//     //    var uniqueIds = [];
//     //    for(var i = 0; i < arrayLength; i++){
//     //      newView = viewArray[i]
//     //      if (uniqueIds.indexOf(newView.model.id) === -1){
//     //        uniqueViews.push(newView)
//     //        uniqueIds.push(newView.model.id)
//     //      }
//     //    }
//     //
//     //    return uniqueViews
//     // }
//     //
//     // user.feedView = getUniqueViews(user.feedView)
//     // user.feedView.sort(function(profView1, profView2){
//     //     return (profView2.model.attributes.weightage - profView1.model.attributes.weightage)
//     // });
//     // console.log(user.feedView)
//     // // debugger
//     // // debugger
//     // // if (response.users_followed) {
//     // //   user.usersFollowed = [];
//     // //   (response.users_followed).forEach(function(userFollowed){
//     // //     var newUserFollowed = new Quora.Models.User(userFollowed);
//     // //     user.usersFollowed.push(newUserFollowed)
//     //
//     // //     var userView = new Quora.Views.(model: newTopic)
//     // //     user.profileView.push(topicView)
//     // //     })
//     //
//     // //   delete response.questions_created;
//     // // }
//
//     return response;
//   },
//
// });
