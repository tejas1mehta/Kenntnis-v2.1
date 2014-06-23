Quora.Models.User = Backbone.Model.extend({
	urlRoot: "api/users",
  
  parse: function(response){
    var user = this;

    if (response.followings_join){
      Quora.followings.add(response.followings_join, {merge: true, parse:true})//, parse: true
      delete response.followings_join
    }

    if (response.upvoted_join){
      Quora.upvotes.add(response.upvoted_join,{merge:true, parse: true})
      delete response.upvoted_join
    }

    if (response.notifications){
      Quora.notifications.add(response.notifications,{merge:true, parse: true})
      delete response.notifications
    }

    if (response.user_followers_join){
      Quora.followings.add(response.user_followers_join, {merge: true})//, parse: true
      delete response.user_followers_join
    }

    if(response.last_an_time){
      user.lastFeedAnTime = response.last_an_time; 
      delete response.last_an_time
    }
    
    if(response.last_qn_time){
      user.lastFeedQnTime = response.last_qn_time;
      delete response.last_qn_time

    }

    if(response.last_obj_time){
      user.lastObjTime = response.last_obj_time;
      delete response.last_obj_time
    }

    if (response.rec_users){
      user.recUserViews = [];
      response.rec_users.forEach(function(rec_user){
        Quora.allUsers.add(rec_user,{merge: true, parse: true})
        var newUser = Quora.allUsers.get(rec_user.id)
        var newUserView = new Quora.Views.UserMiniShow({model: newUser});
        user.recUserViews.push(newUserView)
      })
      delete response.rec_users
    } 

    if(response.results){
      user.objectsView = [];
      response.results.forEach(function(result){
        switch(result.resultclass){
          case("Answer"):
            Quora.questions.add(result.question,{merge: true})
            var question = Quora.questions.get(result.question.id)
            question.answers().add(result, {merge: true, parse: true})
            var answer = question.answers().get(result.id)
            var answerView = new Quora.Views.AnswerShow({model: answer, includeQuestion: true});
            user.objectsView.push(answerView)
            break;
          case("Question"):
            Quora.questions.add(result,{merge: true, parse: true})
            var question = Quora.questions.get(result.id)
            var questionView = new Quora.Views.QuestionShow({model: question})
            user.objectsView.push(questionView)
            break;
          case("User"):
            Quora.allUsers.add(result,{merge: true, parse: true})
            var addUser = Quora.allUsers.get(result.id);
            var userView = new Quora.Views.UserMiniShow({model: addUser})
            user.objectsView.push(userView)         
        }
      })

      
      delete response.results 
      this.trigger("objectsReceived")
    }

    return response
  },

  parseSearch: function(response){
    user = this;
    user.searchView = []
    response.results.forEach(function(result){
      debugger
      console.log(result)
      if (result.main_question){
        var newQuestion = new Quora.Models.Question(result,{parse: true});

        var questionView = new Quora.Views.QuestionShow({model: newQuestion})
        user.searchView.push(questionView)
      } else if (result.name){
        var newUser = new Quora.Models.User(result);
        var userView = new Quora.Views.UserMiniShow({model: newUser})
        user.searchView.push(userView)
      } else {
        var newTopic = new Quora.Models.Topic(result ,{parse: true});

        var topicView = new Quora.Views.TopicShow({model: newTopic})
        user.searchView.push(topicView)
      }

    })
  },

  // parseUserInfo: function(response){
  //   // debugger
  //   // Quora.currentUser = new Quora.Models.User(response)
  //   // Quora.userFollowers = new Quora.Collections.Users();
  //   // Quora.userFollowers.add(Quora.currentUser)
  //   Quora.allUsers.add(Quora.currentUser)

  //   console.log("Session loggedin")
  //   // debugger
  //   if (response.followings_join){
  //     Quora.followings.add(response.followings_join, {merge: true, parse:true})//, parse: true
  //   }

  //   if (response.upvoted_join){
  //     Quora.upvotes.add(response.upvoted_join,{merge:true, parse: true})
  //   }
    
  // },
})