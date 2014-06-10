feed_answers = Answer.find_by_sql ["SELECT an_list.id AS id,
        MAX(an_list.main_answer) AS main_answer,
        MAX(an_list.question_id) AS question_id,
        MAX(an_list.author_id) AS author_id,
        MAX(an_list.upvotes) AS upvotes,
        MAX(an_list.created_at) AS created_at,
        MAX(sort_time_c) AS sort_time
        FROM (
        SELECT answers.*, upvotes.created_at AS sort_time_c
        FROM answers
        INNER JOIN upvotes
        ON (upvotes.upvoteable_id = answers.id AND upvotes.upvoteable_type = 'Answer')
        WHERE (upvotes.user_id IN (:followed_ids)) 
        UNION
        SELECT answers.*, answers.created_at AS sort_time_c
                FROM answers 
                WHERE (answers.author_id IN (:followed_ids)))  AS an_list
        GROUP BY an_list.id
        HAVING max(sort_time) < :last_feed_an_time
        ORDER BY max(sort_time) DESC
        LIMIT 10",  {followed_ids: followed_user_ids, last_feed_an_time: last_an_time} ]

feed_questions = Question.find_by_sql ["SELECT qn_list.*
          FROM (
          SELECT questions.*, upvotes.created_at AS sort_time
          FROM questions
          INNER JOIN upvotes
          ON (upvotes.upvoteable_id = questions.id AND upvotes.upvoteable_type = 'Question')
          WHERE (upvotes.user_id IN (:followed_ids)) 
          UNION
          SELECT questions.*, followings.created_at AS sort_time
          FROM questions
          INNER JOIN followings
          ON (followings.followable_id = questions.id AND followings.followable_type = 'Question')
          WHERE (followings.f_id IN (:followed_ids))
          UNION
          SELECT questions.*, questions.created_at AS sort_time
                  FROM questions 
                  WHERE (questions.author_id IN (:followed_ids))
          UNION
          SELECT questions.*, topic_question_joins.created_at AS sort_time
          FROM questions
          INNER JOIN topic_question_joins
          ON (questions.id = topic_question_joins.question_id)
          WHERE (topic_question_joins.topic_id IN (:topic_ids)) )  AS qn_list
          GROUP BY qn_list.id
          HAVING max(sort_time) < :last_feed_qn_time
          ORDER BY max(sort_time) DESC
          LIMIT 5",   {followed_ids: [10], topic_ids: [], last_feed_qn_time: "3000"}  ]

p feed_questions

feed_questions = Question.find_by_sql ["SELECT qn_list.id AS id,
          MAX(qn_list.main_question) AS main_question,
          MAX(qn_list.description) AS description,
          MAX(qn_list.author_id) AS author_id,
          MAX(qn_list.upvotes) AS upvotes,
          MAX(qn_list.created_at) AS created_at,
          MAX(sort_time_c) AS sort_time
          FROM (
          SELECT questions.*, upvotes.created_at AS sort_time_c
          FROM questions
          INNER JOIN upvotes
          ON (upvotes.upvoteable_id = questions.id AND upvotes.upvoteable_type = 'Question')
          WHERE (upvotes.user_id IN (:followed_ids)) 
          UNION
          SELECT questions.*, followings.created_at AS sort_time_c
          FROM questions
          INNER JOIN followings
          ON (followings.followable_id = questions.id AND followings.followable_type = 'Question')
          WHERE (followings.f_id IN (:followed_ids))
          UNION
          SELECT questions.*, questions.created_at AS sort_time_c
                  FROM questions 
                  WHERE (questions.author_id IN (:followed_ids))
          UNION
          SELECT questions.*, topic_question_joins.created_at AS sort_time_c
          FROM questions
          INNER JOIN topic_question_joins
          ON (questions.id = topic_question_joins.question_id)
          WHERE (topic_question_joins.topic_id IN (:topic_ids)) )  AS qn_list
          GROUP BY qn_list.id
          HAVING max(sort_time_c) < :last_feed_qn_time
          ORDER BY max(sort_time_c) DESC
          LIMIT 5",  {followed_ids: followed_user_ids, topic_ids: followed_topic_ids, last_feed_qn_time: last_qn_time} ]
p feed_questions

# profile_questions = Question.find_by_sql ["SELECT qn_list.*
#           FROM (
#           SELECT questions.*, upvotes.created_at AS sort_time
#             FROM questions
#             INNER JOIN upvotes
#             ON (upvotes.upvoteable_id = questions.id AND upvotes.upvoteable_type = 'Question')
#             WHERE (upvotes.user_id IN (:profile_user_id)) 
#           UNION
#           SELECT questions.*, followings.created_at AS sort_time
#             FROM questions
#             INNER JOIN followings
#             ON (followings.followable_id = questions.id AND followings.followable_type = 'Question')
#             WHERE (followings.f_id IN (:profile_user_id))
#           UNION
#           SELECT questions.*, questions.created_at AS sort_time
#             FROM questions 
#             WHERE (questions.author_id IN (:profile_user_id)) )  AS qn_list
#           GROUP BY qn_list.id
#           ORDER BY max(sort_time) DESC", {profile_user_id: [10]} ]

# profile_answers = Answer.find_by_sql ["SELECT an_list.*
#              FROM (
#              SELECT answers.*, upvotes.created_at AS sort_time
#                FROM answers
#                INNER JOIN upvotes
#                ON (upvotes.upvoteable_id = answers.id AND upvotes.upvoteable_type = 'Answer')
#                WHERE (upvotes.user_id IN (:profile_user_id)) 
#              UNION
#              SELECT answers.*, answers.created_at AS sort_time
#                 FROM answers 
#                 WHERE (answers.author_id IN (:profile_user_id)))  AS an_list
#              GROUP BY an_list.id
#              ORDER BY max(sort_time) DESC",  {profile_user_id:  [10]} ]

# all_objects = (profile_questions + profile_answers).sort{|obj1, obj2| (obj2.sort_time <=> obj1.sort_time)}             

     #  ,

              #Change syntax for PostGRESQL LIMIT 20 OFFSET 10, SQLite: LIMIT 10, 20

# profile_user_id = 10
# profile_object_sql = "SELECT obj_list.*
#           FROM (
#           SELECT questions.*, upvotes.created_at AS sort_time, 'Question' AS obj_type, NULL AS main_answer, NULL AS question_id
#             FROM questions
#             INNER JOIN upvotes
#             ON (upvotes.upvoteable_id = questions.id AND upvotes.upvoteable_type = 'Question')
#             WHERE (upvotes.user_id = #{profile_user_id}) 
#           UNION
#           SELECT questions.*, followings.created_at AS sort_time, 'Question' AS obj_type, NULL AS main_answer, NULL AS question_id
#             FROM questions
#             INNER JOIN followings
#             ON (followings.followable_id = questions.id AND followings.followable_type = 'Question')
#             WHERE (followings.f_id = #{profile_user_id})
#           UNION
#           SELECT questions.*, questions.created_at AS sort_time, 'Question' AS obj_type, NULL AS main_answer, NULL AS question_id
#             FROM questions 
#             WHERE (questions.author_id = #{profile_user_id})
#           UNION
#           SELECT NULL AS main_question, NULL AS description, answers.*, upvotes.created_at AS sort_time, 'Answer' AS obj_type
#             FROM answers
#             INNER JOIN upvotes
#             ON (upvotes.upvoteable_id = answers.id AND upvotes.upvoteable_type = 'Answer')
#             WHERE (upvotes.user_id = #{profile_user_id}) 
#           UNION
#           SELECT answers.*, answers.created_at AS sort_time, 'Answer' AS obj_type, NULL AS main_question, NULL AS description
#             FROM answers 
#             WHERE (answers.author_id = #{profile_user_id}) )  AS obj_list
#           GROUP BY obj_list.id, obj_list.obj_type
#           ORDER BY max(sort_time) DESC
#           LIMIT 5"
# profile_objects = ActiveRecord::Base.connection.execute(profile_object_sql,  {profile_user_id: 10} )

# p profile_objects


# profile_objects = Question.find_by_sql ["SELECT obj_list.*
#           FROM (
#           SELECT questions.*, upvotes.created_at AS sort_time, 'Question' AS obj_type, NULL AS main_answer, NULL AS question_id
#             FROM questions
#             INNER JOIN upvotes
#             ON (upvotes.upvoteable_id = questions.id AND upvotes.upvoteable_type = 'Question')
#             WHERE (upvotes.user_id IN (:profile_user_id)) 
#           UNION
#           SELECT questions.*, followings.created_at AS sort_time, 'Question' AS obj_type, NULL AS main_answer, NULL AS question_id
#             FROM questions
#             INNER JOIN followings
#             ON (followings.followable_id = questions.id AND followings.followable_type = 'Question')
#             WHERE (followings.f_id IN (:profile_user_id))
#           UNION
#           SELECT questions.*, questions.created_at AS sort_time, 'Question' AS obj_type, NULL AS main_answer, NULL AS question_id
#             FROM questions 
#             WHERE (questions.author_id IN (:profile_user_id))
#           UNION
#           SELECT answers.*, upvotes.created_at AS sort_time, 'Answer' AS obj_type, NULL AS main_question, NULL AS description 
#             FROM answers
#             INNER JOIN upvotes
#             ON (upvotes.upvoteable_id = answers.id AND upvotes.upvoteable_type = 'Answer')
#             WHERE (upvotes.user_id IN (:profile_user_id)) 
#           UNION
#           SELECT answers.*, answers.created_at AS sort_time, 'Answer' AS obj_type, NULL AS main_question, NULL AS description
#             FROM answers 
#             WHERE (answers.author_id IN (:profile_user_id)) )  AS obj_list
#           GROUP BY obj_list.id, obj_list.obj_type
#           ORDER BY max(sort_time) DESC
#           LIMIT 5",  {profile_user_id: 10} ]

# p profile_objects
# # feed_questions = Question.find_by_sql ["SELECT qn_list.*
# #           FROM (
# #           SELECT questions.*, upvotes.created_at AS sort_time
# #           FROM questions
# #           INNER JOIN upvotes
# #           ON (upvotes.upvoteable_id = questions.id AND upvotes.upvoteable_type = 'Question')
# #           WHERE (upvotes.user_id IN (:followed_ids)) 
# #           UNION
# #           SELECT questions.*, followings.created_at AS sort_time
# #           FROM questions
# #           INNER JOIN followings
# #           ON (followings.followable_id = questions.id AND followings.followable_type = 'Question')
# #           WHERE (followings.f_id IN (:followed_ids))
# #           UNION
# #           SELECT questions.*, questions.created_at AS sort_time
# #                   FROM questions 
# #                   WHERE (questions.author_id IN (:followed_ids))
# #           UNION
# #           SELECT questions.*, topic_question_joins.created_at AS sort_time
# #           FROM questions
# #           INNER JOIN topic_question_joins
# #           ON (questions.id = topic_question_joins.question_id)
# #           WHERE (topic_question_joins.topic_id IN (:topic_ids)) )  AS qn_list
# #           GROUP BY qn_list.id
# #           HAVING max(sort_time) < :last_feed_qn_time
# #           ORDER BY max(sort_time) DESC
# #           LIMIT 25",  {followed_ids: [7], topic_ids: [1], last_feed_qn_time: "3"} ]
# p last_time = feed_questions.last.sort_time
# p feed_questions.map(&:id)
# feed_questions = Question.find_by_sql ["SELECT qn_list.*
#           FROM (
#           SELECT questions.*, upvotes.created_at AS sort_time
#           FROM questions
#           INNER JOIN upvotes
#           ON (upvotes.upvoteable_id = questions.id AND upvotes.upvoteable_type = 'Question')
#           WHERE (upvotes.user_id IN (:followed_ids)) 
#           UNION
#           SELECT questions.*, followings.created_at AS sort_time
#           FROM questions
#           INNER JOIN followings
#           ON (followings.followable_id = questions.id AND followings.followable_type = 'Question')
#           WHERE (followings.f_id IN (:followed_ids))
#           UNION
#           SELECT questions.*, questions.created_at AS sort_time
#                   FROM questions 
#                   WHERE (questions.author_id IN (:followed_ids))
#           UNION
#           SELECT questions.*, topic_question_joins.created_at AS sort_time
#           FROM questions
#           INNER JOIN topic_question_joins
#           ON (questions.id = topic_question_joins.question_id)
#           WHERE (topic_question_joins.topic_id IN (:topic_ids)) )  AS qn_list
#           GROUP BY qn_list.id
#           HAVING max(sort_time) < :last_feed_qn_time
#           ORDER BY max(sort_time) DESC
#           LIMIT 25",  {followed_ids: [7], topic_ids: [1], last_feed_qn_time: last_time} ]
# p feed_questions.map(&:id)

# feed_questions = Question.find_by_sql ["SELECT questions.*, topic_question_joins.created_at AS sort_time
#           FROM questions
#           INNER JOIN topic_question_joins
#           ON (questions.id = topic_question_joins.question_id)
#           WHERE (topic_question_joins.topic_id IN (:topic_ids))
#           ORDER BY topic_question_joins.created_at", {topic_ids: [1,3,6,8]}]
# p feed_questions.map(&:id)

# feed_questions = Question.find_by_sql ["SELECT qn_list.*
#          FROM (
#          SELECT questions.*, upvotes.created_at AS sort_time
#          FROM questions
#          INNER JOIN upvotes
#          ON (upvotes.upvoteable_id = questions.id AND upvotes.upvoteable_type = 'Question')
#          WHERE (upvotes.user_id IN (:followed_ids)) 
#          UNION
#          SELECT questions.*, followings.created_at AS sort_time
#          FROM questions
#          INNER JOIN followings
#          ON (followings.followable_id = questions.id AND followings.followable_type = 'Question')
#          WHERE (followings.f_id IN (:followed_ids))
#          UNION
#          SELECT questions.*, questions.created_at AS sort_time
#                   FROM questions 
#                   WHERE (questions.author_id IN (:followed_ids))
#          UNION questions.*,        )  AS qn_list
#          GROUP BY qn_list.id
#          ORDER BY max(sort_time) DESC
#          LIMIT 25",  {followed_ids: [7]} ]

#  p feed_questions.map(&:id)
#     feed_questions = Question.find_by_sql ["SELECT qn_list.*
#               FROM (
#               SELECT questions.*, upvotes.created_at AS sort_time
#               FROM questions
#               INNER JOIN upvotes
#               ON (upvotes.upvoteable_id = questions.id AND upvotes.upvoteable_type = 'Question')
#               WHERE (upvotes.user_id IN (:followed_ids)) 
#               UNION
#               SELECT questions.*, followings.created_at AS sort_time
#               FROM questions
#               INNER JOIN followings
#               ON (followings.followable_id = questions.id AND followings.followable_type = 'Question')
#               WHERE (followings.f_id IN (:followed_ids))
#               UNION
#               SELECT questions.*, questions.created_at AS sort_time
#                       FROM questions 
#                       WHERE (questions.author_id IN (:followed_ids))
#               UNION
#               SELECT questions.*, topic_question_joins.created_at AS sort_time
#               FROM questions
#               INNER JOIN topic_question_joins
#               ON (questions.id = topic_question_joins.question_id)
#               WHERE (topic_question_joins.topic_id IN (:topic_ids)) )  AS qn_list
#               GROUP BY qn_list.id
#               ORDER BY max(sort_time) DESC
#               LIMIT 25",  {followed_ids: [7], topic_ids: [1]} ]
# # topic_questions = Question.find_by_sql ["SELECT questions.*, topic_question_joins.created_at AS sort_time
# # FROM questions
# # INNER JOIN topic_question_joins
# # ON (questions.id = topic_question_joins.question_id)
# # WHERE (topic_question_joins.topic_id IN (:topic_ids))", {topic_ids: [1]}]

# p feed_questions.map(&:id)

# feed_answers = Answer.find_by_sql ["SELECT an_list.*
#        FROM (
#        SELECT answers.*, upvotes.created_at AS sort_time
#        FROM answers
#        INNER JOIN upvotes
#        ON (upvotes.upvoteable_id = answers.id AND upvotes.upvoteable_type = 'Answer')
#        WHERE (upvotes.user_id IN (:followed_ids)) 
#        UNION
#        SELECT answers.*, answers.created_at AS sort_time
#                 FROM answers 
#                 WHERE (answers.author_id IN (:followed_ids)))  AS an_list
#        GROUP BY an_list.id
#        ORDER BY max(sort_time) DESC
#        LIMIT 25",  {followed_ids: [7]} ]
# p feed_answers.map(&:id)

# created_questions = Question.find_by_sql ["SELECT *
#      FROM questions 
#      WHERE (questions.author_id IN (:followed_ids))
#      ORDER BY (questions.created_at)
#      ", {followed_ids: [7,8,9,10]} ]


# created_qn_join =Question.find_by_sql ["SELECT DISTINCT questions.*
#      FROM questions 
#      LEFT OUTER JOIN upvotes  
#      ON (upvotes.upvoteable_id = questions.id AND upvotes.upvoteable_type = 'Question')
#      WHERE (questions.author_id IN (:followed_ids))
#      ORDER BY (questions.created_at)
#      ", {followed_ids: [7,8,9,10]} ]

# # created_qn_join =Question.find_by_sql ["SELECT *
# #      FROM questions 
# #      LEFT OUTER JOIN answers  
# #      ON (answers.question_id = questions.id)"]

# p created_questions.length
# # p created_qn_join.length

# upvoted_questions = Question.find_by_sql ["SELECT questions.*, upvotes.created_at AS fct
#          FROM questions 
#          LEFT JOIN upvotes  
#          ON (upvotes.upvoteable_id = questions.id AND upvotes.upvoteable_type = 'Question')
#          LEFT JOIN followings
#          ON (followings.followable_id = questions.id AND followings.followable_type = 'Question')
#          WHERE ( (upvotes.user_id IN (:followed_ids)) OR (questions.author_id IN (:followed_ids)) OR 
#           (followings.f_id IN (:followed_ids)) )
#          ORDER BY  CASE 
#                             WHEN ((upvotes.user_id IN (:followed_ids)) AND (followings.f_id IN (:followed_ids)))
#                             THEN (CASE 
#                                   WHEN (upvotes.created_at > followings.created_at)
#                                   THEN upvotes.created_at
#                                   ELSE followings.created_at
#                                   END)
#                             WHEN (upvotes.user_id IN (:followed_ids))
#                             THEN (upvotes.created_at)
#                             WHEN (followings.f_id IN (:followed_ids))
#                             THEN (followings.created_at)
#                             WHEN (questions.author_id IN (:followed_ids))
#                             THEN (questions.created_at)
#                     END DESC                   
#          LIMIT 5", {followed_ids: [7]} ]

# p upvoted_questions.first.fct
# p upvoted_questions[1].fct

# p upvoted_questions[2].fct
# p upvoted_questions[3].fct

# .map{|uq| uq.followings.created_at}
# upvoted_questions = Question.find_by_sql ["SELECT DISTINCT questions.*
#          FROM questions 
#          LEFT JOIN upvotes  
#          ON (upvotes.upvoteable_id = questions.id AND upvotes.upvoteable_type = 'Question')"]

# # p upvoted_questions.select{|upvoted_qn| upvoted_qn.id == 47}
# # p upvoted_questions.select{|upvoted_qn| upvoted_qn.id == 49}
# p upvoted_questions.select{|uq| (uq.id == 1 )}.length

# upvoted_questions = Question.find_by_sql ["SELECT DISTINCT questions.*, upvotes.*
#          FROM questions 
#          LEFT JOIN upvotes  
#          ON (upvotes.upvoteable_id = questions.id AND upvotes.upvoteable_type = 'Question')
#          LEFT JOIN followings
#          ON (followings.followable_id = questions.id AND followings.followable_type = 'Question')
#          WHERE ( (upvotes.user_id IN (:followed_ids)))
#          ORDER BY  upvotes.created_at DESC                   
#          LIMIT 5", {followed_ids: [7]} ]

# p upvoted_questions
# Upvote.where(user_id: 7, upvoteable_type: "Question").order(:created_at).reverse[0..5].map(&:upvoteable_id)

# SELECT DISTINCT ON ( all of the table)
# upvoted_questions = Question.find_by_sql ["SELECT DISTINCT sortedqns.qid AS stg
#          FROM (SELECT questions.id AS qid
#          FROM questions 
#          LEFT JOIN upvotes  
#          ON (upvotes.upvoteable_id = questions.id AND upvotes.upvoteable_type = 'Question')
         # LEFT JOIN followings
         # ON (followings.followable_id = questions.id AND followings.followable_type = 'Question')
#          WHERE ( (upvotes.user_id IN (:followed_ids)) OR (questions.author_id IN (:followed_ids)) OR 
#           (followings.f_id IN (:followed_ids)) )
         # ORDER BY  CASE 
         #                    WHEN ((upvotes.user_id IN (:followed_ids)) AND (followings.f_id IN (:followed_ids)))
         #                    THEN (CASE 
         #                          WHEN (upvotes.created_at > followings.created_at)
         #                          THEN upvotes.created_at
         #                          ELSE followings.created_at
         #                          END)
         #                    WHEN (upvotes.user_id IN (:followed_ids))
         #                    THEN (upvotes.created_at)
         #                    WHEN (followings.f_id IN (:followed_ids))
         #                    THEN (followings.created_at)
         #                    WHEN (questions.author_id IN (:followed_ids))
         #                    THEN (questions.created_at)
         #            END DESC) AS sortedqns                   
#          LIMIT 5", {followed_ids: [7]} ]

# p upvoted_questions.map(&:stg)
#  upvoted_questions = Question.find_by_sql ["SELECT questions.*
#  FROM questions 
#  LEFT JOIN upvotes  
#  ON (upvotes.upvoteable_id = questions.id AND upvotes.upvoteable_type = 'Question')
#  FULL OUTER JOIN (SELECT questions.*
#  FROM questions 
#  LEFT JOIN followings  
#  ON (followings.followable_id = questions.id AND followings.followable_type = 'Question') )"]

# p upvoted_questions.length

# upvoted_questions = Question.find_by_sql ["SELECT DISTINCT sortedqns.qid AS stg
#          FROM (SELECT questions.id AS qid
#          FROM questions 
#          LEFT JOIN upvotes  
#          ON (upvotes.upvoteable_id = questions.id AND upvotes.upvoteable_type = 'Question')
#          LEFT JOIN followings
#          ON (followings.followable_id = questions.id AND followings.followable_type = 'Question')         
#          WHERE ( (questions.author_id IN (:followed_ids)) OR (upvotes.user_id IN (:followed_ids)) OR (followings.f_id IN (:followed_ids)) )
#          ORDER BY upvotes.created_at DESC) AS sortedqns", {followed_ids: [7]} ]
# p upvoted_questions.map(&:stg)
# CASE 
#                             WHEN ((upvotes.user_id IN (:followed_ids)) AND (followings.f_id IN (:followed_ids)))
#                             THEN (CASE 
#                                   WHEN (upvotes.created_at > followings.created_at)
#                                   THEN upvotes.created_at
#                                   ELSE followings.created_at
#                                   END)
#                             WHEN (upvotes.user_id IN (:followed_ids))
#                             THEN (upvotes.created_at)
#                             WHEN (followings.f_id IN (:followed_ids))
#                             THEN (followings.created_at)
#                             WHEN (questions.author_id IN (:followed_ids))
#                             THEN (questions.created_at)
#                     END DESC

# CASE 
#                             WHEN ((upvotes.user_id IN (:followed_ids)) AND (followings.f_id IN (:followed_ids)))
#                             THEN (CASE 
#                                   WHEN (upvotes.created_at > followings.created_at)
#                                   THEN upvotes.created_at
#                                   ELSE followings.created_at
#                                   END)
#                             WHEN (upvotes.user_id IN (:followed_ids))
#                             THEN (upvotes.created_at)
#                             WHEN (followings.f_id IN (:followed_ids))
#                             THEN (followings.created_at)
#                             WHEN (questions.author_id IN (:followed_ids))
#                             THEN (questions.created_at)
#                     END

# upvoted_questions = Question.find_by_sql ["SELECT DISTINCT sortedqns.qid AS stg
#          FROM (SELECT questions.id AS qid
#          FROM questions 
#          LEFT JOIN upvotes  
#          ON (upvotes.upvoteable_id = questions.id AND upvotes.upvoteable_type = 'Question')
#          LEFT JOIN followings
#          ON (followings.followable_id = questions.id AND followings.followable_type = 'Question')         
#          WHERE ( (questions.author_id IN (:followed_ids)) OR (upvotes.user_id IN (:followed_ids)) OR (followings.f_id IN (:followed_ids)) )
#          ORDER BY upvotes.created_at DESC) AS sortedqns", {followed_ids: [7]} ]
# p upvoted_questions.map(&:stg)

