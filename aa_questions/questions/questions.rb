require "sqlite3"
require "singleton"

class QuestionsDB < SQLite3::Database 
    include Singleton 
    def initialize 
        super('questions.db')
        self.type_translation = true 
        self.results_as_hash = true 
    end 
end 

class Users 
    attr_accessor :id, :fname, :lname
    def self.all 
        data = QuestionsDB.instance.execute('SELECT * FROM users')
        data.map { |datum| Users.new(datum) }
    end
    
    def self.find_by_id(id)
        options = QuestionsDB.instance.execute(<<-SQL, id)
        SELECT * 
        FROM users
        WHERE id = ? 
        SQL
        Users.new(options.first)
    end

    def initialize(options)
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname'] 
    end 

    def self.find_by_name(fname, lname)
        options = QuestionsDB.instance.execute(<<-SQL, fname, lname)
        SELECT * 
        FROM users
        WHERE fname = ? AND lname = ?
        SQL
        Users.new(options.first)
    end

    def authored_questions
        Questions.find_by_author_id(self.id)
    end

    def authored_replies
        Replies.find_by_user_id(self.id)
    end

    def followed_questions 
        QuestionFollows.followed_questions_for_user_id(self.id)
    end 
end 

class Questions 
    attr_accessor :id, :title, :body, :user_id 
    def self.all 
        data = QuestionsDB.instance.execute('SELECT * FROM questions')
        data.map { |datum| Questions.new(datum) }
    end
    
    def self.find_by_id(id)
        options = QuestionsDB.instance.execute(<<-SQL, id)
        SELECT * 
        FROM questions
        WHERE id = ? 
        SQL
        Questions.new(options.first)
    end

    def self.find_by_author_id(author_id)
        options = QuestionsDB.instance.execute(<<-SQL, author_id)
        SELECT * 
        FROM questions
        WHERE user_id = ? 
        SQL
        
        questions = options.map {|datum| Questions.new(datum)}
        # return questions.first if questions.length == 1 
        # questions
        # Questions.new(options.first)
    end

    def initialize(options)
        @id = options['id']
        @fname = options['title']
        @lname = options['body']
        @user_id = options['user_id'] 
    end 

    def author
        Users.find_by_id(self.user_id)
    end

    def replies
        Replies.find_by_question_id(self.id)
    end

    def followers
      QuestionFollows.followers_for_question_id(self.id)
    end
end 

class QuestionFollows
    attr_accessor :id, :question_id, :user_id 
    def self.all 
        data = QuestionsDB.instance.execute('SELECT * FROM question_follows')
        data.map { |datum| QuestionFollows.new(datum) }
    end

    def self.followers_for_question_id(question_id)
        options = QuestionsDB.instance.execute(<<-SQL, question_id)
            SELECT 
            users.id, 
            users.fname,
            users.lname 
            FROM users 
            JOIN question_follows 
            ON users.id = question_follows.user_id 
            JOIN questions 
            ON question_follows.question_id = questions.id 
            WHERE questions.id = ?
        SQL
        options.map { |datum| Users.new(datum) }
    end 

    def self.followed_questions_for_user_id(user_id)
        options = QuestionsDB.instance.execute(<<-SQL, user_id )
        SELECT 
        questions.id, 
        questions.title,
        questions.body ,
        questions.user_id
        FROM users 
        JOIN question_follows 
        ON users.id = question_follows.user_id 
        JOIN questions 
        ON question_follows.question_id = questions.id 
        WHERE users.id = ?
    SQL
    options.map { |datum| Questions.new(datum) }
    end 

    def self.most_followed_questions(n)
      options = QuestionsDB.instance.execute(<<-SQL, n)
        SELECT
          questions.body, count(questions.body) 
        FROM
          question_follows
        JOIN questions
          ON question_follows.question_id = questions.id
        GROUP BY
          questions.body
        HAVING 
          count(questions.body)
        ORDER BY
          count(questions.body) DESC
        LIMIT ?                                              
      SQL
    end
    
    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @user_id = options['user_id'] 
    end 
end 

class Replies 
    attr_accessor :id, :body, :question_id, :parent_reply_id, :user_id 
    def self.all 
        data = QuestionsDB.instance.execute('SELECT * FROM replies')
        data.map { |datum| Replies.new(datum) }
    end
    
    def self.find_by_id(id)
        options = QuestionsDB.instance.execute(<<-SQL, id)
        SELECT * 
        FROM replies
        WHERE id = ? 
        SQL
        Replies.new(options.first)
    end

    def self.find_by_user_id(user_id)
        options = QuestionsDB.instance.execute(<<-SQL, user_id)
        SELECT * 
        FROM replies
        WHERE user_id = ? 
        SQL
        options.map { |datum| Replies.new(datum) }
    end

    def self.find_by_question_id(question_id)
        options = QuestionsDB.instance.execute(<<-SQL, question_id)
        SELECT * 
        FROM replies
        WHERE question_id = ? 
        SQL
        options.map { |datum| Replies.new(datum) }
    end

    def initialize(options)
        @id = options['id']
        @body = options['body']
        @question_id = options['question_id']
        @parent_reply_id = options['parent_reply_id']
        @user_id = options['user_id'] 
    end 

    def author
        Users.find_by_id(self.user_id)
    end

    def question
        Questions.find_by_id(self.question_id)
    end

    def parent_reply
        Replies.find_by_id(self.parent_reply_id)
    end

    def child_replies  
      id = self.id
      options = QuestionsDB.instance.execute(<<-SQL, id)
        SELECT
          *
        FROM
          replies
        WHERE parent_reply_id = ?
      SQL

      options.map { |datum| Replies.new(datum) } 
    end
end 

class QuestionLikes 
    attr_accessor :id, :user_id, :question_id  
    def self.all 
        data = QuestionsDB.instance.execute('SELECT * FROM questions_likes')
        data.map { |datum| QuestionLikes.new(datum) }
    end
    
    def self.find_by_id(id)
        options = QuestionLikes.instance.execute(<<-SQL, id)
        SELECT * 
        FROM question_likes
        WHERE id = ? 
        SQL
        QuestionLikes.new(options.first)
    end

    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @user_id = options['user_id'] 
    end 

    # def self.find_by_author_id(author_id)
    #     options = QuestionsDB.instance.execute(<<-SQL, author_id)
    #     SELECT * 
    #     FROM questions
    #     WHERE user_id = ? 
    #     SQL
    #     options.map {|datum| Questions.new(options)}
    # end
end 

